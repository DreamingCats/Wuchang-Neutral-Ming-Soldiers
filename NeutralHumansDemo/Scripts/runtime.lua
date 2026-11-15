-- Sensory-gating prototype. Native global-team writes are intentionally absent.
local M = {}
local S = {records = {}, hooks = false}
local targets = require("targets")
local damageHook = "/Game/DynamicCombatSystem/Blueprints/AI/BP_BaseAIController.BP_BaseAIController_C:AfterTakeDamage"
local initHook = "/Game/DynamicCombatSystem/Blueprints/AI/BP_BaseAI.BP_BaseAI_C:InitGlobalTeamInfo"

local function log(s) print("[NeutralHumansDemo] " .. s .. "\n") end
local function key(actor) return tostring(actor:GetAddress()) .. actor:GetFullName() end
local function behavior(actor)
    local out = {}
    actor:GetMyBehavior(out)
    return out.BehaviorComp
end
local function relation(component, target)
    local out = {}
    component:CheckRelation(target, out)
    return out.Result
end
local function selected(actor)
    return actor:IsValid() and actor:GetFullName():find(":PersistentLevel.", 1, true)
        and targets[actor:GetClass():GetFullName():lower()]
end
local function guarded(fn)
    local ok, err = pcall(fn)
    if not ok then log("ERROR " .. tostring(err)) end
end
local function setSenses(controller, sight, hearing)
    controller.DisableSight = sight
    controller.DisableHearing = hearing
    controller:ChangeAlertStatu(controller.AlertStatu, true)
end

function M.apply(actor)
    if not selected(actor) then return end
    local id = key(actor)
    local existing = S.records[id]
    if existing then
        if not existing.retaliating and existing.controller:IsValid()
            and (not existing.controller.DisableSight or not existing.controller.DisableHearing) then
            setSenses(existing.controller, true, true)
        end
        return
    end
    local comp = behavior(actor)
    if not comp or not comp:IsValid() then return end
    local original = comp.Camp:ToString()
    if original == "" then return end
    local player = FindFirstOf("BP_CombatCharacter_Player_Final_C")
    if not player:IsValid() then return end
    local playerCamp = player.BehaviorComponent.Camp:ToString()
    local before = relation(comp, playerCamp)
    if before ~= -1 then return end -- Already neutral/friendly NPCs need no change.
    local controller = actor.BaseAIController
    if not controller:IsValid() then return end
    S.records[id] = {actor = actor, controller = controller,
        sight = controller.DisableSight, hearing = controller.DisableHearing, retaliating = false}
    controller:ClearAllTargets()
    controller:SetIsInCombat(false)
    setSenses(controller, true, true)
    log("passive " .. actor:GetFullName())
end

function M.damage(controller)
    local actor = controller.PossesedAI
    if not actor:IsValid() then return end
    local record = S.records[key(actor)]
    if record and not record.retaliating then
        record.retaliating = true
        setSenses(controller, record.sight, record.hearing)
        log("retaliation " .. actor:GetFullName())
    end
end

function M.ensureHooks()
    if not StaticFindObject(damageHook):IsValid() then return end
    if not S.hooks then
        RegisterHook(damageHook, function(context)
            guarded(function() M.damage(context:get()) end)
        end)
        RegisterHook(initHook, function(context)
            guarded(function() M.apply(context:get()) end)
        end)
        S.hooks = true
        log("damage and initialization hooks installed")
    end
    if not S.configHook then
        RegisterHook(damageHook:gsub(":AfterTakeDamage", ":LoadGlobalConfig"), function(context)
            guarded(function()
                local actor = context:get().PossesedAI
                if actor:IsValid() then M.apply(actor) end
            end)
        end)
        S.configHook = true
    end
end

function M.scan(quiet)
    M.ensureHooks()
    local selectedCount = 0
    for _, actor in ipairs(FindAllOf("BP_BaseAI_C") or {}) do
        if selected(actor) then
            selectedCount = selectedCount + 1
            guarded(function() M.apply(actor) end)
        end
    end
    if not quiet then log("scan candidates=" .. selectedCount) end
end

function M.inspect()
    log("inspect config-enabled runtime")
    for _, actor in ipairs(FindAllOf("BP_BaseAI_C") or {}) do
        if selected(actor) then
            guarded(function()
                local comp = behavior(actor)
                local controller = actor.BaseAIController
                local senses = controller:IsValid() and (" DisableSight=" .. tostring(controller.DisableSight)
                    .. " DisableHearing=" .. tostring(controller.DisableHearing)) or " no_controller"
                log(actor:GetFullName() .. " id=" .. actor["怪物ID"]:ToString()
                    .. " camp=" .. comp.Camp:ToString() .. " player100="
                    .. tostring(relation(comp, "100")) .. senses)
            end)
        end
    end
end

function M.install()
    M.ensureHooks()
    if not S.bound then
        RegisterBeginPlayPostHook(function(context)
            guarded(function()
                local actor = context:get()
                if selected(actor) then
                    M.ensureHooks()
                    M.apply(actor)
                end
            end)
        end)
        S.bound = true
    end
    if not S.polling then
        LoopAsync(1000, function()
            ExecuteInGameThread(function()
                guarded(function() M.scan(true) end)
            end)
            return false
        end)
        S.polling = true
    end
    log("ready v0.3.0: enabled=true from Scripts/config.lua; no hotkeys")
end

return M
