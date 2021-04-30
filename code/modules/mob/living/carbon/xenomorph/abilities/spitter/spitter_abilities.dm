/datum/action/xeno_action/onclick/spitter_frenzy
	name = "Frenzy"
	action_icon_state = "spitter_frenzy"
	ability_name = "dodge"
	macro_path = /datum/action/xeno_action/verb/verb_spitter_frenzy
	ability_primacy = XENO_PRIMARY_ACTION_2
	action_type = XENO_ACTION_ACTIVATE
	plasma_cost = 20
	xeno_cooldown = 80

	// Config
	var/duration = 35
	var/speed_buff_amount = 1.2 // Go from shit slow to superfast

	var/buffs_active = FALSE
	default_ai_action = TRUE

	var/prob_chance = 20

/datum/action/xeno_action/onclick/spitter_frenzy/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(DT_PROB(prob_chance, delta_time))
		use_ability_async(X.current_target)

/datum/action/xeno_action/activable/spray_acid/spitter
	macro_path = /datum/action/xeno_action/verb/verb_spray_acid
	ability_primacy = XENO_PRIMARY_ACTION_3
	action_type = XENO_ACTION_CLICK

	plasma_cost = 50
	xeno_cooldown = 80

	// Configurable options
	spray_type = ACID_SPRAY_LINE	// Enum for the shape of spray to do
	spray_distance = 6 				// Distance to spray
	spray_effect_type = /obj/effect/xenomorph/spray/weak
	activation_delay = FALSE		    // Is there an activation delay?
	var/datum/action/xeno_action/spit_combo_ai

	default_ai_action = TRUE

/datum/action/xeno_action/activable/spray_acid/spitter/ai_unregistered(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(spit_combo_ai)
		UnregisterSignal(spit_combo_ai, COMSIG_PARENT_QDELETING)
		spit_combo_ai = null

/datum/action/xeno_action/activable/spray_acid/spitter/ai_registered(mob/living/carbon/Xenomorph/X)
	. = ..()
	spit_combo_ai = get_xeno_action_by_type(X, /datum/action/xeno_action/activable/xeno_spit)
	if(spit_combo_ai)
		RegisterSignal(spit_combo_ai, COMSIG_PARENT_QDELETING, .proc/cleanup_combo)

/datum/action/xeno_action/activable/spray_acid/spitter/Destroy()
	cleanup_combo(spit_combo_ai)
	return ..()

/datum/action/xeno_action/activable/spray_acid/spitter/proc/cleanup_combo(var/datum/D)
	SIGNAL_HANDLER
	if(spit_combo_ai == D)
		spit_combo_ai = null

/datum/action/xeno_action/activable/spray_acid/spitter/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	// Able to fire acid spray if spit is on cooldown.
	if(DT_PROB(prob_chance, delta_time) && (!spit_combo_ai || spit_combo_ai.action_cooldown_check()))
		use_ability_async(X.current_target)
