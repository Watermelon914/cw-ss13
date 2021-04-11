/datum/caste_datum/runner
	caste_type = XENO_CASTE_RUNNER
	display_icon = XENO_CASTE_RUNNER
	display_name = XENO_CASTE_RUNNER
	caste_desc = "A fast, four-legged terror, but weak in sustained combat."
	tier = 1
	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_2
	plasma_gain = XENO_PLASMA_GAIN_TIER_1
	plasma_max = XENO_NO_PLASMA
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_NO_ARMOR
	max_health = XENO_HEALTH_RUNNER
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_RUNNER
	attack_delay = -4
	evolves_to = list(XENO_CASTE_LURKER)
	deevolves_to = "Larva"

	tackle_min = 3
	tackle_max = 4
	tackle_chance = 40
	tacklestrength_min = 3
	tacklestrength_max = 4

	heal_resting = 1.75

/mob/living/carbon/Xenomorph/Runner
	caste_type = XENO_CASTE_RUNNER
	name = XENO_CASTE_RUNNER
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon_state = "Runner Walking"
	icon_size = 64
	layer = MOB_LAYER
	plasma_types = list(PLASMA_CATECHOLAMINE)
	tier = 1
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	pull_speed = -0.5
	viewsize = 9

	mob_size = MOB_SIZE_XENO_SMALL

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/onclick/xenohide,
		/datum/action/xeno_action/activable/pounce/runner,
		/datum/action/xeno_action/activable/runner_skillshot,
		/datum/action/xeno_action/onclick/toggle_long_range/runner,
	)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
	)
	mutation_type = RUNNER_NORMAL

	var/turf/travelling_turf
	var/linger_range = 5
	var/pull_direction

/mob/living/carbon/Xenomorph/Runner/initialize_pass_flags(var/datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_pass = PASS_FLAGS_CRAWLER


/mob/living/carbon/Xenomorph/Runner/process_ai(delta_time, game_evaluation)
	. = ..()

	if(.)
		return

	a_intent = INTENT_HARM
	create_hud()

	if(throwing)
		return

	if(pulling && can_move_and_apply_move_delay())
		Move(get_step(loc, pull_direction), pull_direction)
		current_path = null
	else
		if(!(src in view(world.view, current_target)))
			travelling_turf = get_turf(current_target)
		else if(!travelling_turf || get_dist(travelling_turf, src) <= 0)
			travelling_turf = get_random_turf_in_range(current_target, linger_range, linger_range)
			if(!travelling_turf)
				travelling_turf = get_turf(current_target)

		if(!move_to_next_turf(travelling_turf))
			travelling_turf = null
			return

		if(get_dist(src, current_target) <= RUNNER_POUNCE_RANGE && DT_PROB(RUNNER_POUNCE, delta_time))
			var/turf/last_turf = loc
			var/clear = TRUE
			add_temp_pass_flags(PASS_OVER_THROW_MOB)
			for(var/i in getline2(src, current_target, FALSE))
				var/turf/new_turf = i
				if(LinkBlocked(src, last_turf, new_turf, list(current_target, src)))
					clear = FALSE
					break
			remove_temp_pass_flags(PASS_OVER_THROW_MOB)

			if(clear)
				var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce)
				A.use_ability_async(current_target)
				SSxeno_pathfinding.stop_calculating_path(src)
				//stop_calculating_path()
				current_path = null
				pull_direction = turn(dir, 180)

	zone_selected = pick(GLOB.warrior_target_limbs)
	if(get_dist(src, current_target) <= 1)
		if(DT_PROB(XENO_SLASH, delta_time))
			INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())
		if(current_target.is_mob_incapacitated() && !isXeno(current_target.pulledby) && !pulling && DT_PROB(RUNNER_GRAB, delta_time))
			CallAsync(src, /mob.proc/start_pulling, list(current_target))
			swap_hand()
