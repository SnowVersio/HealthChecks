--Health Reminder addon for World of Warcraft (Tested on retail and built for 10.2.7)
--This is my first addon and I barely write Lua. It is likely very inefficient. Don't bully me for it >:C
print("Congratulations! HealthChecks has successfuly enabled!")

-- Creates the Window for the reminder 
local frame = CreateFrame("Frame")

-- Creates Timer and values including postponing timer
local postureInterval = 3600 -- Initial 60 minute timer for interval
local postponeInterval = 900 -- 15 minutes for postpone timer
local finalReminder = 0 -- Used in loop checks
local initialCheck = 0 -- Utilised for startup checking. This was originally a boolean, but fuck Lua, it's easier to use numbers.

-- Window frame for how often the player is reminded for posture
StaticPopupDialogs["SET_REMINDER_POSTURE_POPUP"] =
{
    text = "Please select how often you wish to be checked for your posture:",
    button1 = "30 minutes",
    button2 = "60 minutes",
    button3 = "120 minutes",
    OnButton1 = function()
        postureInterval = 1800
        initialCheck = 3
        finalReminder = time() + postureInterval
        print("HealthChecks: Posture check set for 30 minutes")
    end,
    OnButton2 = function()
        postureInterval = 3600
        initialCheck = 3
        finalReminder = time() + postureInterval
        print("HealthChecks: Posture check set for 60 minutes")
    end,
    OnButton3 = function ()
        postureInterval = 7200
        initialCheck = 3
        finalReminder = time() + postureInterval
        print("HealthChecks: Posture check set for 120 minutes")
    end,
    timeout = 3600,
    hideOnEscape = true,
    preferredIndex = 100,
}

-- Window frame for posture check, cancelling resets the clock by 15 minutes
StaticPopupDialogs["POSTURE_CHECK_POPUP"] =
{
    text = "Check your posture you fucking goofy goober",
    button1 = "Aight bet,",
    button2 = "Ping me in 30 mins",
    OnAccept = function()
        print("Your spine is thanking you!")
    end,
    OnCancel = function()
        finalReminder = time() + postponeInterval
    end,
    timeout = 900,
    hideOnEscape = true,
    preferredIndex = 100,
}

-- Loop to check the time is reporting properly and begins posture reminder
local function PostureCheckReminder()
    local currentTime = time()
-- Checks if player is in combat, ignoring the reminder if player is in combat
if InCombatLockdown() then
    return
end
-- Checks current session, if it's the first login it prompts the interval frame, if it's an ongoing session then it runs the reminder frame
    -- Initial check is the control for how this works, as it's default value is 0. This WILL reset on a /reload
if initialCheck < 1 then
    StaticPopup_Show("SET_REMINDER_POSTURE_POPUP")
    finalReminder = currentTime
    initialCheck = 1
    elseif initialCheck > 2 then
        if currentTime - finalReminder >= postureInterval then
        StaticPopup_Show("POSTURE_CHECK_POPUP")
        finalReminder = currentTime
        end
    end
end

-- Function controlling the starting of script upon login, placing down here to ensure everything sets up smoothly
local function OnLogin()
    frame:RegisterEvent("PLAYER_LOGOUT")
    frame:SetScript("OnUpdate", PostureCheckReminder)
end
local function OnLogout()
    frame:UnregisterEvent("PLAYER_LOGOUT")
    frame:SetScript("OnUpdate", nil)
end

-- Loop to check if the player is online to run the above functions
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        OnLogin()
    elseif event == "PLAYER_LOGOUT" then
        OnLogout()
    end
end)

-- Final line is checking if the player is logged in, if so it runs all the above. Placing at the end for ordering reasons.
frame:RegisterEvent("PLAYER_LOGIN")