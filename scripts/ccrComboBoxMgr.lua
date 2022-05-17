function onInit()
    CCR.dbg("++ccrComboBoxMgr:onInit()")
    super.onInit();
    rActor = ActorManager.resolveActor(window.getDatabaseNode())
    if rActor == nil then
        CCR.dbg("--ccrComboBoxMgr:onInit(): rActor==nil")
        return
    end
    addItems(DataCommon.psabilitydata)
    local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
    CCR.dbg("  sNodeType=["..sNodeType.."]")
    if sNodeType ~= "pc" then
        CCR.dbg("--ccrComboBoxMgr:onInit(): sNodeType~=pc")
        return
    end
    addItems(DataCommon.psskilldata)
    CCR.dbg("--ccrComboBoxMgr:onInit()")
end

function onValueChanged()
    sSelection = getValue()
    CCR.dbg("++ccrComboBoxMgr:onValueChanged(): sSelection=["..sSelection.."]")
    rActor = ActorManager.resolveActor(window.getDatabaseNode())
    if rActor == nil then
        CCR.dbg("--ccrComboBoxMgr:onValueChanged(): rActor==nil")
        return
    end

    nMod = 0

    -- Determine if new value is Ability or Skill
    if StringManager.contains(DataCommon.abilities, sSelection:lower()) then
        nMod = ActorManager5E.getCheck(rActor,sSelection:lower())
    else
        sAbility = DataCommon.skilldata[sSelection].stat;
        CCR.dbg("--ccrComboBoxMgr:onValueChanged(): sAbility==["..sAbility.."]")
        nMod = ActorManager5E.getCheck(rActor,sAbility,DataCommon.skilldata[sSelection].lookup)
    end
    

    CCR.dbg("  nMod=["..nMod.."]")
    window["ccr_adjust"].setValue(nMod)
end
