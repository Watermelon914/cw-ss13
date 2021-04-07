/datum/caste_datum/defender
	caste_type = XENO_CASTE_DEFENDER
	display_icon = XENO_CASTE_DEFENDER
	display_name = XENO_CASTE_DEFENDER
	caste_desc = "A sturdy front line combatant."
	tier = 1

	melee_damage_lower = XENO_DAMAGE_TIER_3
	melee_damage_upper = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_5
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_PLASMA_TIER_1
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_7
	armor_deflection = XENO_ARMOR_TIER_4
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_6

	evolves_to = list(XENO_CASTE_WARRIOR)
	deevolves_to = "Larva"
	can_vent_crawl = 0

	tackle_min = 2
	tackle_max = 4

/mob/living/carbon/Xenomorph/Defender
	caste_type = XENO_CASTE_DEFENDER
	name = XENO_CASTE_DEFENDER
	desc = "A alien with an armored head crest."
	icon_size = 64
	icon_state = "Defender Walking"
	plasma_types = list(PLASMA_CHITIN)
	pixel_x = -16
	old_x = -16
	tier = 1
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/onclick/toggle_crest_defense,
		/datum/action/xeno_action/activable/headbutt,
		/datum/action/xeno_action/onclick/tail_sweep,
		/datum/action/xeno_action/activable/fortify
	)
	mutation_type = DEFENDER_NORMAL

/mob/living/carbon/Xenomorph/Defender/update_icons()
	if (stat == DEAD || lying)
		return ..()

	. = ..()

	if(caste.caste_type != caste.display_icon)
		return

	if (fortify)
		icon_state = "[mutation_type] [caste.display_icon] Fortify"
	else if (crest_defense)
		icon_state = "[mutation_type] [caste.display_icon] Crest"

/mob/living/carbon/Xenomorph/Defender/process_ai(delta_time, game_evaluation)
	. = ..()

	if(.)
		return

	a_intent = INTENT_HARM

	var/turf/T = get_turf(current_target)
	if(get_dist(src, current_target) <= 1)
		T = pick(RANGE_TURFS(1, T))

	if(!move_to_next_turf(T))
		current_target = null
		return

	zone_selected = pick(GLOB.warrior_target_limbs)
	if(get_dist(src, current_target) <= 1)
		if(DT_PROB(XENO_SLASH, delta_time))
			INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())
		if(DT_PROB(DEFENDER_TAILWHIP, delta_time))
			var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/onclick/tail_sweep)
			A.use_ability_async(current_target)
		if(DT_PROB(DEFENDER_HEADBUTT, delta_time))
			var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/headbutt)
			A.use_ability_async(current_target)
