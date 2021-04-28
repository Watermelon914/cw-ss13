
// toggle agility
/datum/action/xeno_action/onclick/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
	ability_name = "toggle agility"
	macro_path = /datum/action/xeno_action/verb/verb_toggle_agility
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 10

/datum/action/xeno_action/onclick/toggle_agility/can_use_action()
	var/mob/living/carbon/Xenomorph/X = owner
	if(X && !X.buckled && !X.is_mob_incapacitated())
		return TRUE

// Warrior Fling
/datum/action/xeno_action/activable/fling
	name = "Fling"
	action_icon_state = "fling"
	ability_name = "Fling"
	macro_path = /datum/action/xeno_action/verb/verb_fling
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 55

	default_ai_action = TRUE

	// Configurables
	var/fling_distance = 4
	var/stun_power = 1
	var/weaken_power = 1

	var/prob_chance = 25

/datum/action/xeno_action/activable/fling/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(DT_PROB(prob_chance, delta_time) && get_dist(X, X.current_target) <= 1)
		use_ability_async(X.current_target)

// Warrior Lunge
/datum/action/xeno_action/activable/pounce/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	ability_name = "lunge"
	macro_path = /datum/action/xeno_action/verb/verb_lunge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 100
	plasma_cost = 0

	// Configurables
	distance = 6
	knockdown = FALSE
	freeze_self = FALSE

	var/click_miss_cooldown = 15
	var/twitch_message_cooldown = 0 //apparently this is necessary for a tiny code that makes the lunge message on cooldown not be spammable, doesn't need to be big so 5 will do.
	prob_chance = 40

/datum/action/xeno_action/activable/pounce/lunge/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(X.pulling || get_dist(X, X.current_target) > distance || !DT_PROB(prob_chance, delta_time))
		return

	var/turf/last_turf = X.loc
	var/clear = TRUE
	X.add_temp_pass_flags(PASS_OVER_THROW_MOB)
	for(var/i in getline2(X, X.current_target, FALSE))
		var/turf/new_turf = i
		if(LinkBlocked(X, last_turf, new_turf, list(X.current_target, X)))
			clear = FALSE
			break
	X.remove_temp_pass_flags(PASS_OVER_THROW_MOB)

	if(clear)
		use_ability_async(X.current_target)
		X.swap_hand()

// Warrior Agility

/datum/action/xeno_action/activable/warrior_punch
	name = "Punch"
	action_icon_state = "punch"
	ability_name = "punch"
	macro_path = /datum/action/xeno_action/verb/verb_punch
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 40

	// Configurables
	var/base_damage = 20
	var/boxer_punch_damage = 20
	var/base_punch_damage_synth = 30
	var/boxer_punch_damage_synth = 30
	var/base_punch_damage_pred = 25
	var/boxer_punch_damage_pred = 25
	var/damage_variance = 5

	default_ai_action = TRUE
	var/prob_chance = 15

/datum/action/xeno_action/activable/warrior_punch/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(DT_PROB(prob_chance, delta_time) && get_dist(X, X.current_target) <= 1)
		use_ability_async(X.current_target)

/datum/action/xeno_action/activable/uppercut
	name = "Uppercut"
	action_icon_state = "rav_clothesline"
	ability_name = "uppercut"
	macro_path = /datum/action/xeno_action/verb/verb_uppercut
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 100
	var/base_damage = 15
	var/base_knockback = 40
	var/base_knockdown = 0.25
	var/knockout_power = 11 // 11 seconds
	var/base_healthgain = 5 // in percents of health per ko point

/datum/action/xeno_action/activable/jab
	name = "Jab"
	action_icon_state = "pounce"
	ability_name = "jab"
	macro_path = /datum/action/xeno_action/verb/verb_jab
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 40

