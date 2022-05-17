function onInit()
    uncontested = window["ccr_uncontested"].getValue()
    CCR.dbg("+-ccrUnContestantMgr:onInit() uncontested=["..uncontested.."]")
    if (uncontested == 0) then
        setVisible(false)
    else
        setVisible(true)
    end
end

function onDrop(x,y,dd)
    CCR.dbg("+-ccrUnContestantMgr:onDrop()")
    if dd.getType() ~= "combattrackerentry" then return false end
    window["ccr_defender"].setValue("ccr_contestant",dd.getCustomData())
    window["ccr_uncontested"].setValue(0)
    bHandled = true
    return true
end