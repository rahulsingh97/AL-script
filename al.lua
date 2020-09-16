
local current_weapon = "none"

local R99 = 10
local R301 =11

local set_off_key = 7  ---- off everything ----

local fire_key = "Pause"
local mode_switch_key = "capslock"


---- ignore key ----
---- can use "lalt", "ralt", "alt"  "lshift", "rshift", "shift"  "lctrl", "rctrl", "ctrl"

local ignore_key = "lalt"

--- Sensitivity in Game
--- default is 50.0

local target_sensitivity = 50
local scope_sensitivity = 50
local scope4x_sensitivity = 50

---- Obfs setting
---- Two firing time intervals = weapon_speed * interval_ratio * ( 1 + random_seed * ( 0 ~ 1))
local weapon_speed_mode = false
-- local obfs_mode = false--mouse =3.0 ads=1.0
local obfs_mode = true
local interval_ratio = 0.75
local random_seed = 0  --1--

local recoil_table = {}
--4--
recoil_table["R-99 SMG"] = {
basic={20,20,20,20,20.20,20,12,12,12,15,12,2,2,2,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2},
quadruple={0,-10,-10,-10,0,0,3,2,1,2,3,-6,10,0,0,0,0,0,0,0,0,0,0,0,0},
	speed = 90
}
--5--
recoil_table["R-301 CARBINE"] = {
      basic={15,15,16,16,12,12,12,5,5,5,5,5,5,5,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2},
	  quadruple={-3,-10,0,0,0,-5,-20,0,25,20,-15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    speed = 90
}
recoil_table["none"] = {
    basic={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    quadruple={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    speed = 60
}

--------------------------------------------------------------------------
----------------          Function          ------------------------------
--------------------------------------------------------------------------


function convert_sens(unconvertedSens) 
    return 0.002 * math.pow(10, unconvertedSens / 50)
end

function calc_sens_scale(sensitivity)
    return convert_sens(sensitivity)/convert_sens(50)
end

local target_scale = calc_sens_scale(target_sensitivity)
local scope_scale = calc_sens_scale(scope_sensitivity)
local scope4x_scale = calc_sens_scale(scope4x_sensitivity)

function recoil_mode()
        return "basic";
end
function recoil_modea()
       return "quadruple";
end


function recoil_value(_weapon,_duration,abcd)
    local _mode = recoil_mode()
	local _modea = recoil_modea()
	--OutputLogMessage("mode = %s\n", _mode)
	--OutputLogMessage("mode = %s\n", _modea)
    local step = (math.floor(_duration/100)) + 1
    if step > 40 then
        step = 40
    end
	local stepa=step
	--OutputLogMessage("step = %s\n", step)
	--OutputLogMessage("step = %s\n", stepa)
	OutputLogMessage("Weapon = %s\n",_weapon)
	local weapon_recoil = recoil_table[_weapon][_mode][step]
    OutputLogMessage("Preset Vertical= %s\n",weapon_recoil)
	local weapon_recoila = recoil_table[_weapon][_modea][stepa]
	OutputLogMessage("preset Horizontal= %s\n",weapon_recoila)
    local weapon_speed = 30
    if weapon_speed_mode then
        weapon_speed = recoil_table[_weapon]["speed"]
    end


    local weapon_intervals = weapon_speed
	--OutputLogMessage("weapon_intervals before = %s\n", weapon_intervals)
    if obfs_mode then

        local coefficient = interval_ratio * ( 1 + random_seed * math.random())
        weapon_intervals = math.floor(coefficient  * weapon_speed) 
    end


    recoil_recovery = weapon_recoil * weapon_intervals / 100
	local wl=weapon_intervals
	eat = weapon_recoila * wl / 100
	--OutputLogMessage("weapon_intervals after = %s\n", weapon_intervals)


    return weapon_intervals,recoil_recovery,eat
end

-----------------------------------------------------------------
------------------------------------------------------------------

--------------------------------------------------------------------------
----------------          OnEvent          ------------------------------
--------------------------------------------------------------------------


function OnEvent(event, arg)
   --OutputLogMessage("event = %s, arg = %d\n", event, arg)
    if (event == "PROFILE_ACTIVATED") then
        EnablePrimaryMouseButtonEvents(true)
    elseif event == "PROFILE_DEACTIVATED" then
        current_weapon = "none"
        shoot_duration = 0.0
        ReleaseKey(fire_key)
        ReleaseMouseButton(1)
    end

    if (event == "MOUSE_BUTTON_PRESSED" and arg == set_off_key) then
        current_weapon = "none"
    elseif (event == "MOUSE_BUTTON_PRESSED" and arg == R301) then
        current_weapon = "R-301 CARBINE"
    elseif (event == "MOUSE_BUTTON_PRESSED" and arg == R99) then
        current_weapon = "R-99 SMG"		

    elseif (event == "MOUSE_BUTTON_PRESSED" and arg == 1) then
        -- button 1 : Shoot
        if ((current_weapon == "none") or IsModifierPressed(ignore_key)) then
            PressKey(fire_key)
            repeat
                Sleep(30)
            until not IsMouseButtonPressed(1)
            ReleaseKey(fire_key)
        else
            local shoot_duration = 0.0
            repeat
				local dsda=left_right
                local intervals,recovery,recoverya = recoil_value(current_weapon,shoot_duration,bat)

				--OutputLogMessage("Computed Horizontal= %s\n", recovery)
				--OutputLogMessage("Computed Verticle= %s\n", recoverya)
				OutputLogMessage("EXECUTED SUCCESSFULLY\n")
				OutputLogMessage("\n")

                PressAndReleaseKey(fire_key)
	      MoveMouseRelative(recoverya, recovery )	 
                -- MoveMouseRelative(0, -8 )--
	      Sleep(intervals)
                shoot_duration = shoot_duration + intervals
            until not IsMouseButtonPressed(1)
        end
    elseif (event == "MOUSE_BUTTON_RELEASED" and arg == 1) then
        ReleaseKey(fire_key)
    end
end
