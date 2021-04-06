/datum/caste_datum/sentinel
	caste_type = XENO_CASTE_SENTINEL
	display_icon = XENO_CASTE_SENTINEL
	display_name = XENO_CASTE_SENTINEL
	tier = 1

	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_2
	max_health = XENO_HEALTH_TIER_5
	plasma_gain = XENO_PLASMA_GAIN_TIER_5
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_1
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_7

	caste_desc = "A weak ranged combat alien."
	spit_types = list(/datum/ammo/xeno/toxin, /datum/ammo/xeno/toxin/burst)
	evolves_to = list(XENO_CASTE_SPITTER)
	deevolves_to = "Larva"
	acid_level = 1

	tackle_min = 2
	tackle_max = 6
	tackle_chance = 50
	tacklestrength_min = 4
	tacklestrength_max = 5

	spit_delay = 20

/mob/living/carbon/Xenomorph/Sentinel
	caste_type = XENO_CASTE_SENTINEL
	name = XENO_CASTE_SENTINEL
	desc = "A slithery, spitting kind of alien."
	icon_size = 48
	icon_state = "Sentinel Walking"
	plasma_types = list(PLASMA_NEUROTOXIN)
	pixel_x = -12
	old_x = -12
	tier = 1
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/corrosive_acid/weak,
		/datum/action/xeno_action/activable/xeno_spit, //first macro
		/datum/action/xeno_action/onclick/shift_spits, //second macro
	)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
	)
	mutation_type = SENTINEL_NORMAL
	var/turf/travelling_turf
	var/potential_turf_range = 6
	var/min_range = 2
	var/last_spit = 0

/mob/living/carbon/Xenomorph/Spitter/process_ai(delta_time, game_evaluation)
	. = ..()

	if(.)
		return

	a_intent = INTENT_HARM

	if(!current_target.is_mob_incapacitated() || !move_to_next_turf(get_turf(current_target)))
		if(!travelling_turf || !(get_turf(src) in view(world.view, current_target)))
			travelling_turf = get_turf(current_target)
		else if(get_dist(src, travelling_turf) <= min_range)
			travelling_turf = loc

		if(!move_to_next_turf(travelling_turf) || get_dist(travelling_turf, src) <= 0)
			var/list/potential_turfs = RANGE_TURFS(potential_turf_range, travelling_turf)
			potential_turfs -= loc
			while(length(potential_turfs))
				var/turf/target_turf = pick(potential_turfs)
				potential_turfs -= target_turf

				if(get_dist(target_turf, current_target) <= min_range)
					continue

				if(target_turf in view(4, current_target))
					travelling_turf = target_turf
					break


	if(DT_PROB(SENTINEL_SPIT, delta_time) && (loc in view(4, current_target)))
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/xeno_spit)
		if(A.can_use_action())
			last_spit = world.time
		A.use_ability_async(current_target)

	if(get_dist(src, current_target) <= 1 && DT_PROB(XENO_SLASH, delta_time))
		INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())
