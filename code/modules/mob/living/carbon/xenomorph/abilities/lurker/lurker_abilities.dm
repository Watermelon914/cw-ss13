/datum/action/xeno_action/activable/pounce/lurker
	macro_path = /datum/action/xeno_action/verb/verb_pounce
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 60
	plasma_cost = 20

	// Config options
	distance = 6
	knockdown = FALSE
	knockdown_duration = 2.5
	freeze_self = TRUE
	freeze_time = 15
	can_be_shield_blocked = TRUE

	var/datum/action/xeno_action/onclick/lurker_invisibility/ai_combo_ability
	prob_chance = 75

/datum/action/xeno_action/activable/pounce/lurker/ai_registered(mob/living/carbon/Xenomorph/X)
	. = ..()
	ai_combo_ability = get_xeno_action_by_type(X, /datum/action/xeno_action/onclick/lurker_invisibility)
	if(ai_combo_ability)
		RegisterSignal(ai_combo_ability, COMSIG_PARENT_QDELETING, .proc/cleanup_combo)

/datum/action/xeno_action/activable/pounce/lurker/ai_unregistered(mob/living/carbon/Xenomorph/X)
	if(ai_combo_ability)
		UnregisterSignal(ai_combo_ability, COMSIG_PARENT_QDELETING)
		ai_combo_ability = null
	return ..()

/datum/action/xeno_action/activable/pounce/lurker/proc/cleanup_combo(var/datum/D)
	SIGNAL_HANDLER
	if(D == ai_combo_ability)
		ai_combo_ability = null

/datum/action/xeno_action/activable/pounce/lurker/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if((ai_combo_ability && ai_combo_ability.invis_timer_id == TIMER_ID_NULL) || get_dist(X, X.current_target) > distance || !DT_PROB(prob_chance, delta_time))
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

/datum/action/xeno_action/activable/pounce/lurker/additional_effects_always()
	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	if (X.mutation_type == LURKER_NORMAL)
		var/found = FALSE
		for (var/mob/living/carbon/human/H in get_turf(X))
			found = TRUE
			break

		if (found)
			var/datum/action/xeno_action/onclick/lurker_invisibility/LIA = get_xeno_action_by_type(X, /datum/action/xeno_action/onclick/lurker_invisibility)
			if (istype(LIA))
				LIA.invisibility_off()

/datum/action/xeno_action/activable/pounce/lurker/additional_effects(mob/living/L)
	var/mob/living/carbon/Xenomorph/X = owner
	if (!istype(X))
		return

	if (X.mutation_type == LURKER_NORMAL)
		RegisterSignal(X, COMSIG_XENO_SLASH_ADDITIONAL_EFFECTS_SELF, .proc/remove_freeze, TRUE)

/datum/action/xeno_action/activable/pounce/lurker/proc/remove_freeze(mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER

	var/datum/behavior_delegate/lurker_base/BD = X.behavior_delegate
	if (istype(BD))
		UnregisterSignal(X, COMSIG_XENO_SLASH_ADDITIONAL_EFFECTS_SELF)
		if (freeze_timer_id != TIMER_ID_NULL)
			end_pounce_freeze()
			to_chat(X, SPAN_XENONOTICE("Slashing frenzies you! You feel free to move immediately!"))

/datum/action/xeno_action/onclick/lurker_invisibility
	name = "Turn Invisible"
	action_icon_state = "lurker_invisibility"
	ability_name = "turn invisible"
	macro_path = /datum/action/xeno_action/verb/verb_lurker_invisibility
	ability_primacy = XENO_PRIMARY_ACTION_2
	action_type = XENO_ACTION_CLICK
	xeno_cooldown = 1 // This ability never goes off cooldown 'naturally'. Cooldown is applied manually as a super-large value in the use_ability proc
								 // and reset by the behavior_delegate whenever the ability ends (because it can be ended by things like slashes, that we can't easily track here)
	plasma_cost = 20

	var/duration = 30 SECONDS 			// 30 seconds base
	var/invis_timer_id = TIMER_ID_NULL
	var/alpha_amount = 80
	var/speed_buff = 0

	var/speed_buff_mod_max = 0.25
	var/speed_buff_pct_per_ten_tiles = 0.25 // get a quarter of our buff per ten tiles
	var/curr_speed_buff = 0

	var/prob_chance = 100
	default_ai_action = TRUE


/datum/action/xeno_action/onclick/lurker_invisibility/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(DT_PROB(LURKER_INVISIBLE, delta_time))
		use_ability_async()


// tightly coupled 'buff next slash' action
/datum/action/xeno_action/onclick/lurker_assassinate
	name = "Crippling Strike"
	action_icon_state = "lurker_inject_neuro"
	ability_name = "crippling strike"
	macro_path = /datum/action/xeno_action/verb/verb_crippling_strike
	ability_primacy = XENO_PRIMARY_ACTION_3
	action_type = XENO_ACTION_ACTIVATE
	xeno_cooldown = 100
	plasma_cost = 20

	var/buff_duration = 50
	var/prob_chance = 50

/datum/action/xeno_action/onclick/lurker_assassinate/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(get_dist(X, X.current_target) <= 1 && DT_PROB(prob_chance, delta_time))
		use_ability_async()
