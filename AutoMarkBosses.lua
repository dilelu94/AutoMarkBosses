-- AutoMarkBosses: Silently marks the 4 corner lair guardians with raid target icons
-- (Skull, Cross, Square, Moon) upon spawning across all maps in Azeroth Survivors (WoW 1.12.1).

local ICONS = {
    [1] = 8, -- Lair 1: Calavera (Skull)
    [2] = 7, -- Lair 2: X (Cross)
    [3] = 6, -- Lair 3: Cuadrado (Square)
    [4] = 5, -- Lair 4: Luna (Moon)
}

local markedGuardians = {}
local lastPhase = nil

local function CanMarkTarget()
    if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
        return true
    end
    if GetNumRaidMembers() > 0 then
        return IsRaidLeader() or IsRaidOfficer()
    end
    return UnitIsPartyLeader("player")
end

local function ResetRunState()
    markedGuardians = {}
end

local function ApplyMark(unit, icon)
    if GetRaidTargetIndex(unit) ~= icon then
        SetRaidTarget(unit, icon)
    end
end

local function IsClosestLair(targetLair)
    if type(AZS_RUN) ~= "table" or not AZS_RUN.px or not AZS_RUN.py then
        return true
    end
    local px = tonumber(AZS_RUN.px)
    local py = tonumber(AZS_RUN.py)
    if not px or not py then return true end

    local targetLx = tonumber(targetLair.x) or 0
    local targetLy = tonumber(targetLair.y) or 0
    local targetDist = (px - targetLx) * (px - targetLx) + (py - targetLy) * (py - targetLy)

    if type(AZS_LAIRS) == "table" then
        for i = 1, table.getn(AZS_LAIRS) do
            local other = AZS_LAIRS[i]
            if other and other ~= targetLair and other.name == targetLair.name and other.state ~= "empty" then
                local ox = tonumber(other.x) or 0
                local oy = tonumber(other.y) or 0
                local otherDist = (px - ox) * (px - ox) + (py - oy) * (py - oy)
                if otherDist < targetDist then
                    return false
                end
            end
        end
    end
    return true
end

local function TryMarkGuardian(lair, icon)
    local name = lair.name
    local lairId = tonumber(lair.id) or 0

    -- 1. Check if the player already targets this guardian
    if UnitName("target") == name then
        if not AZS_TARGET or AZS_TARGET.id == lairId or IsClosestLair(lair) then
            ApplyMark("target", icon)
            return true
        end
    end

    -- 2. Check party member targets
    local numParty = GetNumPartyMembers()
    for i = 1, numParty do
        local unit = "party" .. i .. "target"
        if UnitName(unit) == name and IsClosestLair(lair) then
            ApplyMark(unit, icon)
            return true
        end
    end

    -- 3. Check mouseover
    if UnitName("mouseover") == name and IsClosestLair(lair) then
        ApplyMark("mouseover", icon)
        return true
    end

    -- 4. Attempt targeting by exact name if in range
    local hadTarget = UnitExists("target")
    TargetByName(name, true)
    if UnitName("target") == name then
        if not AZS_TARGET or AZS_TARGET.id == lairId or IsClosestLair(lair) then
            ApplyMark("target", icon)
            if hadTarget then
                TargetLastTarget()
            else
                ClearTarget()
            end
            return true
        end
        -- Target matched another lair with identical name; restore
        if hadTarget then
            TargetLastTarget()
        else
            ClearTarget()
        end
    end

    return false
end

local function ProcessGuardians()
    if type(AZS_GetPhase) == "function" and AZS_GetPhase() ~= "playing" then
        return
    end

    if not CanMarkTarget() then
        return
    end

    local lairs = AZS_LAIRS
    if type(lairs) ~= "table" then return end

    local count = table.getn(lairs)
    if count == 0 then return end

    -- Purge slain guardians so that upon respawn they get marked again
    local activeIds = {}
    for i = 1, count do
        local l = lairs[i]
        local lid = l and tonumber(l.id)
        if lid and lid > 0 and l.state ~= "empty" then
            activeIds[lid] = true
        end
    end
    for id in pairs(markedGuardians) do
        if not activeIds[id] then
            markedGuardians[id] = nil
        end
    end

    -- Mark active guardians for each of the 4 corner lairs
    for i = 1, count do
        local lair = lairs[i]
        if lair and lair.state ~= "empty" and lair.name and lair.name ~= "" then
            local lairIdx = tonumber(lair.index) or i
            local icon = ICONS[lairIdx] or 8
            local spawnId = tonumber(lair.id) or 0

            if spawnId > 0 and not markedGuardians[spawnId] then
                if TryMarkGuardian(lair, icon) then
                    markedGuardians[spawnId] = true
                end
            end
        end
    end
end

-- Hidden driver frame
local frame = CreateFrame("Frame", "AutoMarkBossesFrame")
local updateInterval = 0.3
local elapsed = 0

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CHAT_MSG_ADDON")

frame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        ResetRunState()
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == "AZSZONE" or arg1 == "AZSEND" then
            ResetRunState()
        elseif arg1 == "AZSLAIRS" or arg1 == "AZSUNITS" or arg1 == "AZSTGT" then
            ProcessGuardians()
        end
    end
end)

frame:SetScript("OnUpdate", function()
    elapsed = elapsed + arg1
    if elapsed >= updateInterval then
        elapsed = 0

        local phase = type(AZS_GetPhase) == "function" and AZS_GetPhase()
        if phase ~= lastPhase then
            if lastPhase == "victory" or lastPhase == "dead" or phase == "ready" then
                ResetRunState()
            end
            lastPhase = phase
        end

        if phase == "playing" then
            ProcessGuardians()
        end
    end
end)
