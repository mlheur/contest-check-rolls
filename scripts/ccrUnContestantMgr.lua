function onInit()
    uncontested = window["ccr_uncontested"].getValue()
    CCR.dbg("+-ccrUnContestantMgr:onInit() uncontested=["..uncontested.."]")
    if (uncontested == 0) then
        setVisible(false)
    else
        setVisible(true)
    end
end

function goContested(noderef)
    window["ccr_defender"].setValue("ccr_contestant",noderef)
    window["ccr_uncontested"].setValue(0)
    return true
end

function onDrop(x,y,dd)
    ddtype = dd.getType()
    CCR.dbg("++ccrUnContestantMgr:onDrop(x=["..x.."],y=["..y.."],dd.getType()=["..ddtype.."])")
    bHandled = false
    if (ddtype == "combattrackerentry") then
        bHandled = goContested(dd.getCustomData())
    end
    CCR.dbg("--ccrUnContestantMgr:onDrop()")
    return(bHandled)
end