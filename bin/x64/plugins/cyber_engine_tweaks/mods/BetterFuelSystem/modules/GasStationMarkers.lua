-- GasStationMarkers.lua
-- Creates map pins for gas stations from coordinates

local M = {
  _cfg = {
    points_path         = "gas_stations.json",
    cluster_radius      = 10.0,
    clampToGround       = true,
    visibleThroughWalls = true,
    trace               = false,
    title               = "PETROCHEM",
    desc                = "Fuel Station",
  },
  _handles = {},
  _lastHash = 0,
  _wm_patched = false,
}

-- ─────────── logging ───────────
local function _log(level, msg)
  if level ~= "TRACE" then print("[BetterFuelSystem GasMarkers] "..tostring(msg)) end
end
local function TRACE(fmt, ...) if M._cfg.trace then _log("TRACE", string.format(fmt, ...)) end end

-- ─────────── whitelist: show WanderingMerchant under Service Points (and All) ───────────
local function _ensureWMInServicePoints()
  if M._wm_patched then return end
  M._wm_patched = true

  local variant = TweakDBID.new('Mappins.PointOfInterest_WanderingMerchantVariant')

  local function addIfArray(groupFlat)
    local ok, id = pcall(function() return TweakDBID.new(groupFlat) end)
    if not ok or not id then 
      --_log("WARN", "Failed to create TweakDBID for: " .. tostring(groupFlat))
      return false 
    end
    
    local ok2, arr = pcall(function() return TweakDB:GetFlat(id) end)
    if not ok2 or type(arr) ~= 'table' then 
      --_log("WARN", "Failed to get flat or not array: " .. tostring(groupFlat))
      return false 
    end
    
    local want = tostring(variant)
    for i=1,#arr do 
      if tostring(arr[i]) == want then 
        --_log("INFO", "Variant already in: " .. tostring(groupFlat))
        return true 
      end 
    end
    
    arr[#arr+1] = variant
    local ok3 = pcall(function() TweakDB:SetFlat(id, arr) end)
    if ok3 then
      --_log("INFO", "Added variant to: " .. tostring(groupFlat))
      return true
    else
      --_log("WARN", "Failed to set flat for: " .. tostring(groupFlat))
      return false
    end
  end

  -- Ensure visibility where players expect it:
  local added = 0
  if addIfArray('WorldMap.ServicePointsFilterGroup.mappins') then added = added + 1 end
  if addIfArray('WorldMap.AllServicePointsFilterGroup.mappins') then added = added + 1 end
  if addIfArray('WorldMap.AllFilterGroup.mappins') then added = added + 1 end
  if addIfArray('WorldMap.CommonFilterGroup.mappins') then added = added + 1 end
  
  --_log("INFO", "Added WanderingMerchant variant to " .. tostring(added) .. " filter groups")
end

-- ─────────── JSON helpers ───────────
local function _readFile(p)
  -- Try multiple path variants
  local paths = {
    p,  -- direct path
    "bin/x64/plugins/cyber_engine_tweaks/mods/BetterFuelsystem/" .. p,  -- from game root
  }
  
  -- Try GetMod if available
  local mod = nil
  if type(GetMod) == "function" then
    mod = GetMod("BetterFuelsystem")
    if not mod then mod = GetMod("BetterFuelSystem") end
    if mod and mod.path then
      table.insert(paths, 1, mod.path .. "/" .. p)
    end
  end
  
  for _, path in ipairs(paths) do
    local f = io.open(path, "r")
    if f then
      local s = f:read("*a")
      f:close()
      if s and #s > 0 then
        --_log("INFO", "Loaded file from: " .. path)
        return s
      end
    else
      if M._cfg.trace then
        --_log("TRACE", "Failed to open: " .. path)
      end
    end
  end
  
  --_log("WARN", "All path attempts failed for: " .. tostring(p))
  return nil
end

local function _json_decode(str)
  if type(str) ~= "string" then return nil end
  local pos = 1
  local function skip() local _, e = str:find("^[ \t\r\n]*", pos); pos = (e or pos-1) + 1 end
  local function parse()
    skip()
    local c = str:sub(pos,pos)
    if c == "{" then
      pos=pos+1; skip(); local t={}
      if str:sub(pos,pos) == "}" then pos=pos+1; return t end
      while true do
        skip(); if str:sub(pos,pos) ~= '"' then return nil end
        pos=pos+1; local ss=pos
        while true do local ch=str:sub(pos,pos); if ch=='"' then break elseif ch=='\\' then pos=pos+1 end; pos=pos+1 end
        local key=str:sub(ss,pos-1):gsub("\\n","\n"):gsub('\\"','"'):gsub('\\\\','\\')
        pos=pos+1; skip(); if str:sub(pos,pos) ~= ":" then return nil end
        pos=pos+1; local val=parse(); if val==nil and str:sub(pos-4,pos-1)~="null" then return nil end
        t[key]=val; skip(); local ch=str:sub(pos,pos)
        if ch=="}" then pos=pos+1; return t elseif ch=="," then pos=pos+1 else return nil end
      end
    elseif c == "[" then
      pos=pos+1; skip(); local a={}
      if str:sub(pos,pos) == "]" then pos=pos+1; return a end
      local i=1
      while true do
        local v=parse(); if v==nil and str:sub(pos-4,pos-1)~="null" then return nil end
        a[i]=v; i=i+1; skip(); local ch=str:sub(pos,pos)
        if ch=="]" then pos=pos+1; return a elseif ch=="," then pos=pos+1 else return nil end
      end
    elseif c == '"' then
      pos=pos+1; local ss=pos
      while true do local ch=str:sub(pos,pos); if ch=='"' then break elseif ch=='\\' then pos=pos+1 end; pos=pos+1 end
      local s=str:sub(ss,pos-1); pos=pos+1
      return s:gsub("\\n","\n"):gsub('\\"','"'):gsub('\\\\','\\')
    else
      local lit = str:match("^[^,%]%}%s]+", pos); if not lit then return nil end
      pos = pos + #lit
      if lit=="true" then return true elseif lit=="false" then return false elseif lit=="null" then return nil end
      return tonumber(lit)
    end
  end
  return parse()
end

-- ─────────── clustering (XY only) ───────────
local function _clusterXY(points, radius)
  radius = tonumber(radius) or 0
  if radius <= 0 then return points end
  local used, out = {}, {}
  local r2 = radius * radius
  for i=1,#points do
    if not used[i] then
      local sx, sy, sz, n = points[i].x, points[i].y, points[i].z or 0, 1
      used[i] = true
      local changed = true
      while changed do
        changed = false
        local cx, cy = sx/n, sy/n
        for j=1,#points do
          if not used[j] then
            local dx = points[j].x - cx
            local dy = points[j].y - cy
            if (dx*dx + dy*dy) <= r2 then
              used[j] = true
              sx, sy, sz, n = sx + points[j].x, sy + points[j].y, sz + (points[j].z or 0), n + 1
              changed = true
            end
          end
        end
      end
      out[#out+1] = { x = sx/n, y = sy/n, z = sz/n }
    end
  end
  return out
end

-- ─────────── points + hash ───────────
local function _loadPoints(path)
  local raw = _readFile(path)
  if not raw or #raw == 0 then 
    --_log("WARN", "Could not load points file: " .. tostring(path))
    return {} 
  end
  local t = _json_decode(raw)
  if type(t) ~= "table" then return {} end
  local out = {}
  for i=1,#t do
    local p = t[i]
    if type(p) == "table" and tonumber(p.x) and tonumber(p.y) then
      out[#out+1] = { x = tonumber(p.x), y = tonumber(p.y), z = tonumber(p.z) or 0 }
    end
  end
  return out
end

local function _hashPoints(pts)
  local h = 0
  for i=1,#pts do
    h = h + math.floor((pts[i].x or 0) * 1000)
          + 31  * math.floor((pts[i].y or 0) * 1000)
          + 997 * math.floor((pts[i].z or 0) * 1000)
  end
  return h
end

-- ─────────── register/unregister ───────────
local function _unregisterAll(self)
  local ms = Game.GetMappinSystem()
  if not ms then self._handles = {}; return end
  for _, h in ipairs(self._handles) do
    pcall(function() ms:UnregisterMappin(h) end)
  end
  self._handles = {}
end

-- ─────────── spawn pin ───────────
local function _spawnOne(self, pos, idx)
  local ms = Game.GetMappinSystem()
  if not ms then return nil end

  local md
  pcall(function() md = NewObject('gamemappinsMappinData') end)
  if not md then md = NewObject('MappinData') end

  md.mappinType = TweakDBID.new('Mappins.DefaultStaticMappin')
  local variant = (gamemappinsMappinVariant and gamemappinsMappinVariant.WanderingMerchantVariant)
               or (gamedataMappinVariant    and gamedataMappinVariant.WanderingMerchantVariant)
  if variant then md.variant = variant end

  local title = self._cfg.title
  local desc  = self._cfg.desc

  if type(self._cfg.caption) == "function" then
    local ok, t, d = pcall(self._cfg.caption, pos, idx)
    if ok then
      if t ~= nil then title = t end
      if d ~= nil then desc  = d end
    else
      _log("WARN", "caption() failed: "..tostring(t))
    end
  end

  md.debugCaption = string.format("BetterFuelSystem|%s|%s",
    tostring(title):gsub("|","/"),
    tostring(desc):gsub("|","/"))

  pcall(function() md.active = true end)
  pcall(function() md.visibleThroughWalls = self._cfg.visibleThroughWalls ~= false end)
  pcall(function() md.clampToGround      = self._cfg.clampToGround       ~= false end)

  local v4 = Vector4.new(pos.x, pos.y, pos.z or 0.0, 1.0)

  local id
  local ok = pcall(function() id = ms:RegisterMappin(md, v4) end)
  if not ok or not id then pcall(function() id = ms:CreateMappin(md, v4, nil) end) end

  if id then
    local activeOk = pcall(function() ms:SetMappinActive(id, true) end)
    local revealOk = pcall(function() ms:RevealMappin(id, true)   end)
    local refreshOk = pcall(function() ms:RefreshMappin(id)        end)
    -- Force show on map
    local visibilityOk = pcall(function() 
      if ms.SetMappinVisibility then
        ms:SetMappinVisibility(id, true)
      end
    end)
    
    -- _log("INFO", string.format("Spawned pin id=%s at (%.1f, %.1f, %.1f) - active:%s reveal:%s refresh:%s visibility:%s", 
    --   tostring(id), pos.x, pos.y, pos.z or 0, 
    --   tostring(activeOk), tostring(revealOk), tostring(refreshOk), tostring(visibilityOk)))
    
    if self._cfg.trace then _log("TRACE", "spawned id="..tostring(id).." variant=WanderingMerchantVariant") end
    return id
  else
    --_log("WARN", string.format("Failed to create pin at (%.1f, %.1f, %.1f)", pos.x, pos.y, pos.z or 0))
  end
  return nil
end

-- ─────────── API ───────────
function M.setup(opts)
  opts = opts or {}
  for k,v in pairs(opts) do M._cfg[k] = v end
  pcall(_ensureWMInServicePoints)
  M:refresh(true)
  TRACE("using points file: %s; clamp=%s", tostring(M._cfg.points_path), tostring(M._cfg.clampToGround ~= false))
end

function M.refresh(force)
  local pts = _loadPoints(M._cfg.points_path or "gas_stations.json")
  local clustered = _clusterXY(pts, M._cfg.cluster_radius or 0)
  local newHash = _hashPoints(clustered)

  if not force and newHash == M._lastHash and #M._handles > 0 then
    TRACE("refresh skipped (same hash)")
    return
  end

  _unregisterAll(M)
  M._lastHash = newHash

  local ms = Game.GetMappinSystem()
  if not ms then
    --_log("WARN", "MappinSystem not available yet; will retry later.")
    return
  end

  for i=1,#clustered do
    local h = _spawnOne(M, clustered[i], i)
    if h then table.insert(M._handles, h) end
  end

  -- _log("INFO", string.format("Gas markers: %d points → %d clusters → %d pins", #pts, #clustered, #M._handles))
end

function M.shutdown()
  _unregisterAll(M)
  TRACE("shutdown done")
end

return M

