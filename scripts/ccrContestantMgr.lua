function onInit()
    CCR.dbg("++ccrContestantMgr:onInit()")
    myName = getName()
    if myName == nil then
        CCR.dbg("  myName is nil")
        return
    end
    if not User.isHost() then
        CCR.dbg("  adding handlers")
        if myName == "ccr_aggressor" then
            DB.addHandler("CCR."..myName.."_noderef","onAdd",updateClientAggressor)
            DB.addHandler("CCR."..myName.."_noderef","onUpdate",updateClientAggressor)
        elseif myName == "ccr_defender" then
            DB.addHandler("CCR."..myName.."_noderef","onAdd",updateClientDefender)
            DB.addHandler("CCR."..myName.."_noderef","onUpdate",updateClientDefender)
        end
    end
    if myName == "ccr_defender" and window["ccr_uncontested"].getValue() == 1 then
        setVisible(false)
    else
        setVisible(true)
    end

    noderef = DB.getChild("CCR",myName.."_noderef")
    if noderef ~= nil then
        setValue("ccr_contestant",noderef.getValue())
    end

    CCR.dbg("--ccrContestantMgr:onInit()")
end

function onValueChanged()
    if not User.isHost() then return end
    local _,noderef = getValue()
    noderef_node = DB.createChild("CCR",getName().."_noderef","string")
    noderef_node.setPublic(true)
    noderef_node.setValue(noderef)
end

function updateClientAggressor(noderef)
    CCR.dbg("+-ccrContestantMgr:updateClientAggressor()")
    window["ccr_aggressor"].setValue("ccr_contestant",noderef.getValue())
end

function updateClientDefender(noderef)
    CCR.dbg("+-ccrContestantMgr:updateClientDefender()")
    window["ccr_defender"].setValue("ccr_contestant",noderef.getValue())
end

function onDrop(x,y,dd)
    ddtype = dd.getType()
    CCR.dbg("++ccrContestantMgr:onDrop(x=["..x.."],y=["..y.."],dd.getType()=["..ddtype.."])")
    bHandled = false
    sclass,srecord = getValue()
    if srecord == nil then srecord = "nil" end
    if sclass ~= nil then
        CCR.dbg("  sclass=["..sclass.."], srecord=["..srecord.."]")
        if (ddtype == "combattrackerentry") then
            setValue(sclass,dd.getCustomData())
            bHandled = true
        elseif (ddtype == "shortcut") then
            nclass,nvalue = dd.getShortcutData()
            CCR.dbg("  nclass=["..nclass.."], nvalue=["..nvalue.."]")
            setValue(sclass,nvalue)
            bHandled = true
        end
    end
    sclass,srecord = getValue()
    CCR.dbg("--ccrContestantMgr:onDrop() srecord=["..srecord.."]")
    return(bHandled)
end
