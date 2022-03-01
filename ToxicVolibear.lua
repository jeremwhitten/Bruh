if game.local_player.champ_name ~= "Volibear" then
	return
end

local sprite = nil

-- [ AutoUpdate ]
local Version = 2
do  
    local function AutoUpdate()
		--console:clear()
		local file_name = "ToxicVolibear.lua"
		local url = "https://raw.githubusercontent.com/jeremwhitten/Bruh/main/ToxicVolibear.lua"        
        local web_version = http:get("https://raw.githubusercontent.com/jeremwhitten/Bruh/main/ToxicVolibear.version")
        console:log("ToxicVolibear.Lua Vers: "..Version)
		console:log("ToxicVolibear.Web Vers: "..tonumber(web_version))
		if tonumber(web_version) == Version then
            console:log("ToxicVolibear successfully loaded.....")
        else
			http:download_file(url, file_name)
            console:log("New ToxicVolibear Update available.....")
			console:log("Please reload via F5.....")
        end
    
    end
	
    local function Check()
		if not file_manager:file_exists("PKDamageLib.lua") then
			local file_name = "PKDamageLib.lua"
			local url = "https://raw.githubusercontent.com/Astraanator/test/main/Champions/PKDamageLib.lua"   	
			http:download_file(url, file_name)
			console:log("PkDamageLib download: Please reload via F5.....")	
			return
		end

		if not file_manager:directory_exists("PoptartFolder") then
			file_manager:create_directory("PoptartFolder")
		end

		if file_manager:directory_exists("PoptartFolder") then
			if not file_manager:file_exists("PoptartFolder/ToxicImage") then
				local file_name = "PoptartFolder/ToxicImage.png"
				local url = "https://raw.githubusercontent.com/jeremwhitten/Bruh/main/3.png"   	
				http:download_file(url, file_name)
			else
				sprite = renderer:add_sprite("PoptartFolder/ToxicImage.png", 2000, 2000)
			end	
		end					

		if not file_manager:file_exists("Prediction.lib") then
		   local file_name = "Prediction.lib"
		   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
		   http:download_file(url, file_name)
		   console:log("ArkPred. download: Please reload via F5.....")
		end		
    end		
    
    AutoUpdate()
	Check()
end

if not file_manager:file_exists("PoptartFolder/ToxicImage.png") then
	console:log("Please reload via F5.....")
	return
end
		
require "PKDamageLib"
pred:use_prediction()
arkpred = _G.Prediction

local myHero = game.local_player

local function Ready(spell)
	return spellbook:can_cast(spell)
end

local function IsValid(unit)
        if unit
        and unit.is_valid 
        and unit.is_targetable 
        and unit.is_alive 
        and unit.is_visible 
        and unit.object_id ~= 0 
        and unit.health > 0 
        and unit.is_enemy
        and not unit:has_buff_type(4)
        and not unit:has_buff_type(16) 
        and not unit:has_buff_type(17) 
        and not unit:has_buff_type(18) 
        and not unit:has_buff_type(38) 
        and not unit:has_buff("sionpassivezombie") 
        and not unit:has_buff("kindredrnodeathbuff") then
            return true
        end
        return false
    end

local function MyHeroReady()
	if myHero.is_recalling or game.is_chat_opened or game.is_shop_opened or evade:is_evading() then
		return false
	end
	return true
end

local function GetEnemyHeroes()
	local _EnemyHeroes = {}
	players = game.players	
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end	
	return _EnemyHeroes
end

local function IsImmobileTarget(unit)
	if unit:has_buff_type(5) or unit:has_buff_type(8) or unit:has_buff_type(11) or unit:has_buff_type(12) or unit:has_buff_type(22) or unit:has_buff_type(23) or unit:has_buff_type(25) or unit:has_buff_type(30) then
		return true
	end
	return false	
end

local function GetAllyHeroes()
	local _AllyHeroes = {}
	players = game.players	
	for i, unit in ipairs(players) do
		if unit and not unit.is_enemy and unit.object_id ~= myHero.object_id then
			table.insert(_AllyHeroes, unit)
		end
	end
	return _AllyHeroes
end

function GetDistanceSqr(p1, p2)
	return (p1.x - p2.x) *  (p1.x - p2.x) + ((p1.z or p1.y) - (p2.z or p2.y)) * ((p1.z or p1.y) - (p2.z or p2.y)) 
end

local function GetDistance(p1, p2)
	return math.sqrt(GetDistanceSqr(p1, p2))
end

local function GetEnemyCount(range, unit)
	count = 0
	for i, hero in ipairs(GetEnemyHeroes()) do
	Range = range * range
		if unit.object_id ~= hero.object_id and GetDistanceSqr(unit.origin, hero.origin) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

local function MyHeroReady()
	if myHero.is_recalling or game.is_chat_opened or game.is_shop_opened or evade:is_evading() then
		return false
	end
	return true
end

ToxicVolibear_category = menu:add_category_sprite("ToxicVolibear", "PoptartFolder/ToxicImage.png")
ToxicVolibear_enabled = menu:add_checkbox("Enabled",ToxicVolibear_category,1)
ComboMenu = menu:add_subcategory("Combo Features", ToxicVolibear_category)
Pcombo_combokey = menu:add_keybinder("Combo Key",ToxicVolibear_category,32)

---Prediction---
Ppred = menu:add_subcategory("Prediction Features", ToxicVolibear_category)
	pred_table = {}
	pred_table[1] = "Bruh Pred."
	pred_table[2] = "Ark Pred."
	Ppred_mode = menu:add_combobox("Pred. Selection", Ppred, pred_table, 1)

	Ppred_ark = menu:add_subcategory("Ark Pred. Settings", Ppred)
		Ppred_e = menu:add_subcategory("E Settings", Ppred_ark)
			e_hitchance = menu:add_slider("HitChance [%]", Ppred_e, 1, 99, 50)
			e_range = menu:add_slider("Max-Range", Ppred_e, 500, 1300, 1250)
			e_radius = menu:add_slider("Radius >> Default = 60 <<", Ppred_e, 30, 90, 60)
			e_speed = menu:add_slider("Speed >> Default = 1150 <<", Ppred_e, 1050, 1250, 1150)			
		
		Ppred_r = menu:add_subcategory("R Settings", Ppred_ark)
			r_hitchance = menu:add_slider("HitChance [%]", Ppred_r, 1, 99, 50)
			r_range = menu:add_slider("Max-Range", Ppred_r, 700, 25000, 3000)
			r_radius = menu:add_slider("Radius >> Default = 180 <<", Ppred_r, 150, 210, 180)
			r_speed = menu:add_slider("Speed >> Default = 20000 <<", Ppred_r, 19000, 21000, 20000)	

---Combo---
Pcombo = menu:add_subcategory("Combo Features", ComboMenu)
	Pcombo_useq = menu:add_checkbox("Use Q", ComboMenu, 1)
	Pcombo_usew = menu:add_checkbox("Use W", ComboMenu, 1)
	Pcombo_usee = menu:add_checkbox("Use E", ComboMenu, 1)
	Pcombo_user1 = menu:add_checkbox("Use R Enemy Count", ComboMenu, 1)
	Pcombo_rcount = menu:add_slider("Use R min Enemies", ComboMenu, 1, 5, 2)
	Pcombo_user = menu:add_checkbox("Use R", ComboMenu, 1)

---Clear---	
Pclear = menu:add_subcategory("JungleClear Features", ToxicVolibear_category)
	Pclear_useq = menu:add_checkbox("Use Q", Pclear, 1)
	Pclear_usew = menu:add_checkbox("Use W", Pclear, 1)
	Pclear_usee = menu:add_checkbox("Use E", Pclear, 1)
	
---Drawings---
PSpell_range = menu:add_subcategory("Drawing Features)", ToxicVolibear_category)
	Pdraw_cd = menu:add_checkbox("Draw only if ready", PSpell_range, 1)
	Pdraw_q = menu:add_checkbox("Draw Q range", PSpell_range, 0)	
	Pdraw_e = menu:add_checkbox("Draw E range", PSpell_range, 0)
	Pdraw_r = menu:add_checkbox("Draw R range", PSpell_range, 0)
	
	local EPred_input = {
    source = myHero,
    speed = 1200, 
	range = menu:get_value(e_range),
    delay = 2, 
	radius = menu:get_value(e_radius),
    collision = {},
    type = "circular", 
	hitbox = false
}

local RPred_input = {
    source = myHero,
    speed = menu:get_value(r_speed), 
	range = menu:get_value(r_range),
    delay = 0.25, 
	radius = menu:get_value(r_radius),
    collision = {},
    type = "circular", 
	hitbox = false
}

local function CastQ(unit)             
	spellbook:cast_spell(SLOT_Q, 0.2, unit.origin.x, unit.origin.y, unit.origin.z) 
end

local function CastW(unit)             
	spellbook:cast_spell(SLOT_W, 0.2, unit.origin.x, unit.origin.y, unit.origin.z)
end

local function CastE(unit)
	if menu:get_value(Ppred_mode) == 0 then
		pred_output = pred:predict(math.huge, 0.25, 900, 270, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_E, 0.2, castPos.x, castPos.y, castPos.z) 
		end	
	else
		pred_output = arkpred:get_prediction(EPred_input, unit)
		if pred_output.hit_chance >= menu:get_value(e_hitchance)/100 then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_E, 0.2, castPos.x, castPos.y, castPos.z)
			LastCast = game.game_time
		end
	end		
end

local function AutoE(unit)
if Ready(SLOT_E) and menu:get_value(Pcombo_usee) == 1 then
		for i, target in ipairs(GetEnemyHeroes()) do
			if myHero:distance_to(target.origin) <= 1200 and IsValid(target) then
				local Immobile = IsImmobileTarget(target)
				if Immobile then
					CastE(target)					
				end
			end
		end	
	end
end

local function CastR(unit)
if menu:get_value(Ppred_mode) == 0 then
		pred_output = pred:predict(math.huge, 0.25, 700, 270, unit, false, false)
		if pred_output.can_cast then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_R, 0.2, castPos.x, castPos.y, castPos.z) 
		end	
	else
		pred_output = arkpred:get_prediction(EPred_input, unit)
		if pred_output.hit_chance >= menu:get_value(r_hitchance)/100 then
			castPos = pred_output.cast_pos
			spellbook:cast_spell(SLOT_R, 0.2, castPos.x, castPos.y, castPos.z)
			LastCast = game.game_time
		end
	end	
end	


local function Combo()
	target = selector:find_target(1600, mode_health)
	if IsValid(target) then
        
		if menu:get_value(Pcombo_user1) == 1 and Ready(SLOT_R) then
			local count = GetEnemyCount(575, myHero)
			if count >= menu:get_value(Pcombo_rcount) then
				CastR(target)
				LastCast = game.game_time
			end	
		end
	
		if menu:get_value(Pcombo_user) == 1 and myHero:distance_to(target.origin) < 700 and Ready(SLOT_R) then
			CastR(target)
        end
		
		if menu:get_value(Pcombo_useq) == 1 and myHero:distance_to(target.origin) < 500 and IsValid(target) and Ready(SLOT_Q) then
			CastQ(target)
        end
		
		if menu:get_value(Pcombo_usew) == 1 and myHero:distance_to(target.origin) < 380 and IsValid(target) and Ready(SLOT_W) then
			CastW(target)
        end
		
		if menu:get_value(Pcombo_usee) == 1 and myHero:distance_to(target.origin) < 425 and IsValid(target) and Ready(SLOT_E) then
			CastE(target)						
        end
		else
		if myHero:distance_to(target.origin) < 1300 then
		CastE(target)
		end
		
			
		
		
					
	end
end

local function JungleClear()
	minions = game.jungle_minions
	for i, target in ipairs(minions) do              
	
		if menu:get_value(Pclear_useq) == 1 and Ready(SLOT_Q) and myHero:distance_to(target.origin) < 500 and IsValid(target) then				
			spellbook:cast_spell(SLOT_Q, 0.2, target.origin.x, target.origin.y, target.origin.z)
		
		elseif menu:get_value(Pclear_usee) == 1 and Ready(SLOT_E) and myHero:distance_to(target.origin) < 1200 and IsValid(target) then			
			spellbook:cast_spell(SLOT_E, 0.2, target.origin.x, target.origin.y, target.origin.z)
			LastCast = game.game_time
		elseif menu:get_value(Pclear_usew) == 1 and Ready(SLOT_W) and myHero:distance_to(target.origin) < 380 and IsValid(target) then
			spellbook:cast_spell(SLOT_W, 0.2, target.origin.x, target.origin.y, target.origin.z)	
			
		end	
	end	
end

local function on_draw()		
	screen_size = game.screen_size	
	local_player = game.local_player
	if local_player.object_id ~= 0 then
		origin = local_player.origin
		x, y, z = origin.x, origin.y, origin.z		
		
		if menu:get_value(Pdraw_q) == 1 then
			renderer:draw_circle(x, y, z, 500, 0, 137, 255, 255)
		end						
		
		if menu:get_value(Pdraw_e) == 1 then
			renderer:draw_circle(x, y, z, 1200, 0, 225, 180, 255)
		end

		if menu:get_value(Pdraw_r) == 1 then
			renderer:draw_circle(x, y, z, 700, 0, 191, 255, 255)
		end	
			
	end		
end

local function on_tick()
	
	if MyHeroReady() then
		AutoE()
		local Mode = combo:get_mode()			
		if game:is_key_down(menu:get_value(Pcombo_combokey)) then
		Combo()
		elseif Mode == MODE_LANECLEAR then
		JungleClear()
		end
			
	end	
end

client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_tick", on_tick)
