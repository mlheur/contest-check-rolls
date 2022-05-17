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

--------------------------------------------------------------------------------
function doProf(rActor,sSkill)
    CCR.dbg("++ccrComboBoxMgr:doProf()")
	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
	for _,nodeSkill in pairs(DB.getChildren(nodeActor, "skilllist")) do
		if DB.getValue(nodeSkill, "name", "") == sSkill then
            CCR.dbg("  found nodeSkill")
            nodeChar = nodeSkill.getChild("...");
	        nProf = DB.getValue(nodeSkill, "prof", 0);
	        if nProf == 1 then
                CCR.dbg("--ccrComboBoxMgr:doProf(): [nProf==1]")
		        return DB.getValue(nodeChar, "profbonus", 0);
	        elseif nProf == 2 then
                CCR.dbg("--ccrComboBoxMgr:doProf(): [nProf==2]")
		        return (2 * DB.getValue(nodeChar, "profbonus", 0));
	        elseif nProf == 3 then
                CCR.dbg("--ccrComboBoxMgr:doProf(): [nProf==3]")
		        return math.floor(DB.getValue(nodeChar, "profbonus", 0) / 2);
            end
	    end
    end
    CCR.dbg("--ccrComboBoxMgr:doProf(): 0 [end]")
    return 0
end

function onValueChanged()
    CCR.dbg("++ccrComboBoxMgr:onValueChanged()")
    sSelection = getValue()
    CCR.dbg("  sSelection==["..sSelection.."]")
    rActor = ActorManager.resolveActor(window.getDatabaseNode())
    if rActor == nil then
        CCR.dbg("--ccrComboBoxMgr:onValueChanged(): rActor==nil")
        return
    end

    nMod = 0
    nProf = 0

    -- Determine if new value is Ability or Skill
    if StringManager.contains(DataCommon.abilities, sSelection:lower()) then
        nMod = ActorManager5E.getCheck(rActor,sSelection:lower())
    else
        sAbility = DataCommon.skilldata[sSelection].stat;
        sSkill = DataCommon.skilldata[sSelection].lookup
        CCR.dbg("  sAbility==["..sAbility.."]")
        CCR.dbg("  sSkill==["..sSkill.."]")
        nProf = doProf(rActor,sSelection)
        nMod,bADV,bDIS,sDesc = ActorManager5E.getCheck(rActor,sAbility,sSkill)
        window["ccr_advantage"].setValue(bADV)
        window["ccr_disadvantage"].setValue(bDIS)
    end

    CCR.dbg("  nMod=["..nMod.."], nProf=["..nProf.."]")
    window["ccr_adjust"].setValue(nMod+nProf)
    CCR.dbg("--ccrComboBoxMgr:onValueChanged()")
end
