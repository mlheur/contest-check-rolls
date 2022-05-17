DEBUG = false;
function dbg(...) if CCR.DEBUG then print("[CCR] "..unpack(arg)) end end

--------------------------------------------------------------------------------
-- Main Entry Point
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function onInit()
	CCR.dbg("++CCR:onInit()");
    tButton = {}
    tButton["tooltipres"] = "CCR_title"
    tButton["class"]      = "ccr_wndclass"
    tButton["path"]       = "CCR"
    tButton["icon"]       = "CCR_button_up"
    tButton["icon_down"]  = "CCR_button_dn"
    DesktopManager.registerSidebarStackButton(tButton)
    if User.isHost() then
        ActionsManager.registerResultHandler("CCR",CCR.onRoll) -- if rRoll["sType"] == "CCR" then call ccrThrowMgr.onRoll after throwing dice.
        Interface.openWindow("ccr_wndclass", "CCR")
        DB.setPublic("CCR",true)
    end
    CCR.dbg("--CCR:onInit()");
end

function Uncontested()
    return CCR.hWnd["ccr_uncontested"].getValue() == 1
end

--------------------------------------------------------------------------------
-- PRE Callback
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function mkRoll(swNode,sRole)
	CCR.dbg("++CCR:mkRoll()")    
	local r = {}
	r["aDice"]   = { "d20" } -- lookup? put a d20 in the XML?
	r["nMod"]    = swNode.subwindow["ccr_adjust"].getValue()
	r["sType"]   = "CCR" -- must match ActionsManager.registerResultHandler("CCR", ...) for our callback to be called
	r["sDesc"]   = swNode.subwindow["ccr_skillability"].getValue()
	r["bSecret"] = false -- these are immersive, never show the players.
	r["sRole"]   = sRole -- this gets passed on blindly to our onRoll function
	CCR.dbg("--CCR:mkRoll()")    
	return r
end

--------------------------------------------------------------------------------
function doAdvDis(swNode,rRoll)
    CCR.dbg("++CCR:doAdvDis()")
    bADV = swNode.subwindow["ccr_advantage"].getValue() == 1 or false
    bDIS = swNode.subwindow["ccr_disadvantage"].getValue() == 1 or false
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end
	if (bADV and not bDIS) or (bDIS and not bADV) then
		table.insert(rRoll.aDice, 2, "d20");
		rRoll.aDice.expr = nil;
	end
    CCR.dbg("--CCR:doAdvDis()")
end

--------------------------------------------------------------------------------
function rollActor(swNode,sRole)
    CCR.dbg("++CCR:rollActor()")

    local _,sActor = swNode.getValue()
    if sActor == nil then
        CCR.dbg("--CCR:rollActor(): bailling sActor==nil")
        return
    end
    local rActor = ActorManager.resolveActor(sActor)
    if rActor == nil then
        CCR.dbg("--CCR:rollActor(): unable to resolve actor, rActor==nil")
        return
    end

    CCR.dbg("  have resolved actor, sRole=["..sRole.."]")
    rRoll = mkRoll(swNode,sRole)
    doAdvDis(swNode,rRoll)
    rThrow = ActionsManager.buildThrow(rActor, {}, rRoll, false)
	Comm.throwDice(rThrow)

    CCR.dbg("--CCR:rollActor()")
end

--------------------------------------------------------------------------------
function rollNow(hWnd)
    CCR.dbg("++CCR:rollNow()")
    if not User.isHost() then return end
    if hWnd == nil then return end
    CCR.hWnd = hWnd

    CCR.dbg("  rollNow() passed initial checks")
    oREVL = OptionsManager.getOption("REVL")
    OptionsManager.setOption("REVL", "on");
    
    -- fresh start
    CCR.results = {
        ["aggressor"] = nil,
        ["defender"] = nil
    }

    if Uncontested() then
        CCR.results["aggressor"] = CCR.hWnd["ccr_nobody"].subwindow["ccr_dc_uncontested"].getValue()
        rollActor(CCR.hWnd["ccr_aggressor"], "defender")
    else
        rollActor(CCR.hWnd["ccr_aggressor"], "aggressor")
        rollActor(CCR.hWnd["ccr_defender"], "defender")
    end

    CCR.dbg("--CCR:rollNow()")
end

--------------------------------------------------------------------------------
-- POST Callback
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function showWinner()
    CCR.dbg("++CCR:showWinner()")

    sMsg = CCR.hWnd["ccr_contestname"].getValue()
    if sMsg == "" then sMsg = "Contest" end
    sMsg = sMsg.." "
    
    if CCR.results["defender"] >= CCR.results["aggressor"] then
        sMsg = sMsg .. "Winner: "
        if Uncontested() then
            sMsg = sMsg .. CCR.hWnd["ccr_aggressor"].subwindow["name"].getValue() .. "!"
        else
            sMsg = sMsg .. CCR.hWnd["ccr_defender"].subwindow["name"].getValue() .. "!"
        end
    else
        if Uncontested() then
            sMsg = sMsg .. "Loser: "
        else
            sMsg = sMsg .. "Winner: "
        end
        sMsg = sMsg .. CCR.hWnd["ccr_aggressor"].subwindow["name"].getValue() .. "!"
    end
    CCR.dbg("  Result sMsg ["..sMsg.."]")
    chatMsg = {
        text = sMsg,
        mode = "story",
        sender = "",
        icon = "CCR_icon",
        font = "chatfont"
    }
    Comm.deliverChatMessage(chatMsg)
    OptionsManager.setOption("REVL", oREVL);
    CCR.results = nil
end

--------------------------------------------------------------------------------
function onRoll(rSource, rTarget, rRoll)
    rRoll.bSecret = false
    ActionsManager2.decodeAdvantage(rRoll);
    CCR.results[rRoll.sRole] = ActionsManager.total(rRoll)
    Comm.deliverChatMessage(ActionsManager.createActionMessage(rSource, rRoll));
    if CCR.results["aggressor"] ~= nil and CCR.results["defender"] ~= nil then
        showWinner()
    end
end