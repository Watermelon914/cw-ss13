/datum/caste_datum/spitter
	caste_type = XENO_CASTE_SPITTER
	display_icon = XENO_CASTE_SPITTER
	display_name = XENO_CASTE_SPITTER
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_1
	melee_damage_upper = XENO_DAMAGE_TIER_3
	max_health = XENO_HEALTH_TIER_6
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_6
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_ARMOR_MOD_MED
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_5

	caste_desc = "Ptui!"
	spit_types = list(/datum/ammo/xeno/acid/medium)
	evolves_to = list(XENO_CASTE_BOILER)
	deevolves_to = XENO_CASTE_SENTINEL
	acid_level = 2

	behavior_delegate_type = /datum/behavior_delegate/spitter_base

	spit_delay = 40

	tackle_min = 2
	tackle_max = 6
	tackle_chance = 45
	tacklestrength_min = 4
	tacklestrength_max = 5

/mob/living/carbon/Xenomorph/Spitter
	caste_type = XENO_CASTE_SPITTER
	name = XENO_CASTE_SPITTER
	desc = "A gross, oozing alien of some kind."
	icon_size = 48
	icon_state = "Spitter Walking"
	plasma_types = list(PLASMA_NEUROTOXIN)
	pixel_x = -12
	old_x = -12

	tier = 2
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/onclick/spitter_frenzy,
		/datum/action/xeno_action/activable/spray_acid/spitter,
	)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
	)
	mutation_type = SPITTER_NORMAL

	var/turf/travelling_turf
	var/potential_turf_range = 6
	var/min_range = 3
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

				if(target_turf in view(current_target))
					travelling_turf = target_turf
					break

	if(DT_PROB(SPITTER_FRENZY, delta_time))
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/onclick/spitter_frenzy)
		A.use_ability_async(current_target)

	if(DT_PROB(SPITTER_SPIT, delta_time) && (loc in view(current_target)))
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/xeno_spit)
		if(A.can_use_action())
			last_spit = world.time
		A.use_ability_async(current_target)

	if(DT_PROB(SPITTER_SPRAY, delta_time) && (last_spit + SPITTER_SPRAY_SPIT_PERIOD) > world.time)
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/spray_acid/spitter)
		A.use_ability_async(current_target)

	if(get_dist(src, current_target) <= 1 && DT_PROB(XENO_SLASH, delta_time))
		INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())


/datum/behavior_delegate/spitter_base
	name = "Base Spitter Behavior Delegate"

	// list of atoms that we cannot apply a DoT effect to
	var/list/dot_cooldown_atoms = list()
	var/dot_cooldown_duration = 120 // every 12 seconds

/datum/behavior_delegate/spitter_base/ranged_attack_additional_effects_target(atom/A)
	if (ishuman(A))
		var/mob/living/carbon/human/H = A
		if (H.stat == DEAD)
			return

	for (var/atom/dotA in dot_cooldown_atoms)
		if (dotA == A)
			return

	dot_cooldown_atoms += A
	addtimer(CALLBACK(src, .proc/dot_cooldown_up, A), dot_cooldown_duration)

	new /datum/effects/acid(A, bound_xeno, initial(bound_xeno.caste_type))

	if (ismob(A))
		var/datum/action/xeno_action/onclick/spitter_frenzy/SFA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/spitter_frenzy)
		if (istype(SFA) && !SFA.action_cooldown_check())
			SFA.end_cooldown()

/datum/behavior_delegate/spitter_base/proc/dot_cooldown_up(var/atom/A)
	if (A != null && !QDELETED(src))
		dot_cooldown_atoms -= A
		if (istype(bound_xeno))
			to_chat(bound_xeno, SPAN_XENOWARNING("You can soak [A] in acid again!"))
