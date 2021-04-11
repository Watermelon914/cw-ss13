/datum/caste_datum/lurker
	caste_type = XENO_CASTE_LURKER
	display_icon = XENO_CASTE_LURKER
	display_name = XENO_CASTE_LURKER
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_4
	max_health = XENO_HEALTH_TIER_5
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_NO_ARMOR
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_8

	attack_delay = 2 // VERY high slash damage, but attacks relatively slowly

	behavior_delegate_type = /datum/behavior_delegate/lurker_base

	deevolves_to = XENO_CASTE_RUNNER
	caste_desc = "A fast, powerful backline combatant."
	evolves_to = list(XENO_CASTE_RAVAGER)

	heal_resting = 1.5

/mob/living/carbon/Xenomorph/Lurker
	caste_type = XENO_CASTE_LURKER
	name = XENO_CASTE_LURKER
	desc = "A beefy, fast alien with sharp claws."
	icon_size = 48
	icon_state = "Lurker Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -12
	old_x = -12
	tier = 2
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/pounce/lurker,
		/datum/action/xeno_action/onclick/lurker_invisibility,
		/datum/action/xeno_action/onclick/lurker_assassinate
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
	mutation_type = LURKER_NORMAL
	claw_type = CLAW_TYPE_SHARP

	tackle_min = 2
	tackle_max = 6

	var/turf/travelling_turf
	var/linger_range = 5

/datum/behavior_delegate/lurker_base
	name = "Base Lurker Behavior Delegate"

	// Config
	var/invis_recharge_time = 150      // 15 seconds to recharge invisibility.
	var/invis_start_time = -1 // Special value for when we're not invisible
	var/invis_duration = 300  // so we can display how long the lurker is invisible to it
	var/buffed_slash_damage_ratio = 1.2
	var/slash_slow_duration = 35

	// State
	var/next_slash_buffed = FALSE
	var/can_go_invisible = TRUE

/datum/behavior_delegate/lurker_base/melee_attack_modify_damage(original_damage, atom/A = null)
	if (!isXenoOrHuman(A))
		return original_damage

	var/mob/living/carbon/H = A
	if (next_slash_buffed)
		to_chat(bound_xeno, SPAN_XENOHIGHDANGER("You significantly strengthen your attack, slowing [H]!"))
		to_chat(H, SPAN_XENOHIGHDANGER("You feel a sharp pain as [bound_xeno] slashes you, slowing you down!"))
		original_damage *= buffed_slash_damage_ratio
		H.SetSuperslowed(get_xeno_stun_duration(H, 3))
		next_slash_buffed = FALSE

	return original_damage

/datum/behavior_delegate/lurker_base/melee_attack_additional_effects_target(atom/A)
	if (!isXenoOrHuman(A))
		return

	var/mob/living/carbon/H = A
	if (H.knocked_down)
		new /datum/effects/xeno_slow(H, bound_xeno, null, null, get_xeno_stun_duration(slash_slow_duration))

	return

/datum/behavior_delegate/lurker_base/melee_attack_additional_effects_self()
	..()

	var/datum/action/xeno_action/onclick/lurker_invisibility/LIA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
	if (LIA && istype(LIA))
		LIA.invisibility_off()

// What to do when we go invisible
/datum/behavior_delegate/lurker_base/proc/on_invisibility()
	var/datum/action/xeno_action/activable/pounce/lurker/LPA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/lurker)
	if (LPA && istype(LPA))
		LPA.knockdown = TRUE // pounce knocks down
		LPA.freeze_self = TRUE
	can_go_invisible = FALSE
	invis_start_time = world.time

/datum/behavior_delegate/lurker_base/proc/on_invisibility_off()
	var/datum/action/xeno_action/activable/pounce/lurker/LPA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/lurker)
	if (LPA && istype(LPA))
		LPA.knockdown = FALSE // pounce no longer knocks down
		LPA.freeze_self = FALSE

	// SLIGHTLY hacky because we need to maintain lots of other state on the lurker
	// whenever invisibility is on/off CD and when it's active.
	addtimer(CALLBACK(src, .proc/regen_invisibility), invis_recharge_time)

	invis_start_time = -1

/datum/behavior_delegate/lurker_base/proc/regen_invisibility()
	if (can_go_invisible)
		return

	can_go_invisible = TRUE
	if(bound_xeno)
		var/datum/action/xeno_action/onclick/lurker_invisibility/LIA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
		if(LIA && istype(LIA))
			LIA.end_cooldown()

/datum/behavior_delegate/lurker_base/append_to_stat()
	. = list()
	var/invis_message = (invis_start_time == -1) ? "N/A" : "[(invis_duration-(world.time - invis_start_time))/10] seconds."
	. += "Invisibility Time Left: [invis_message]"

/mob/living/carbon/Xenomorph/Lurker/process_ai(delta_time, game_evaluation)
	. = ..()

	if(.)
		return

	a_intent = INTENT_HARM
	create_hud()

	if(throwing)
		return

	if(current_target.is_mob_incapacitated())
		travelling_turf = get_turf(current_target)
		var/list/turfs = RANGE_TURFS(1, travelling_turf)
		while(length(turfs))
			travelling_turf = pick(turfs)
			turfs -= travelling_turf
			if(!travelling_turf.density)
				break

			if(travelling_turf == get_turf(current_target))
				break

	else if(!(src in view(world.view, current_target)))
		travelling_turf = get_turf(current_target)
	else if(!travelling_turf || get_dist(travelling_turf, src) <= 0)
		travelling_turf = get_random_turf_in_range(current_target, linger_range, linger_range)
		if(!travelling_turf)
			travelling_turf = get_turf(current_target)

	if(!move_to_next_turf(travelling_turf))
		travelling_turf = null
		return

	var/datum/action/xeno_action/onclick/lurker_invisibility/invis = get_xeno_action_by_type(src, /datum/action/xeno_action/onclick/lurker_invisibility)

	if(DT_PROB(LURKER_INVISIBLE, delta_time))
		invis.use_ability_async()

	if(invis.invis_timer_id != TIMER_ID_NULL && get_dist(src, current_target) <= LURKER_POUNCE_RANGE && DT_PROB(LURKER_POUNCE, delta_time))
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
			var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce/lurker)
			A.use_ability_async(current_target)
			SSxeno_pathfinding.stop_calculating_path(src)
			//stop_calculating_path()
			current_path = null

	zone_selected = pick(GLOB.warrior_target_limbs)
	if(get_dist(src, current_target) <= 1)
		if(DT_PROB(XENO_SLASH, delta_time))
			if(DT_PROB(LURKER_POWER_SLASH, delta_time))
				var/datum/action/xeno_action/power_slash = get_xeno_action_by_type(src, /datum/action/xeno_action/onclick/lurker_assassinate)
				power_slash.use_ability_async()
			INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())
