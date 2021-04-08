/datum/caste_datum/crusher
	caste_type = XENO_CASTE_CRUSHER
	display_icon = XENO_CASTE_CRUSHER
	display_name = XENO_CASTE_CRUSHER
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_5
	melee_damage_upper = XENO_DAMAGE_TIER_5
	max_health = XENO_HEALTH_TIER_7
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_10
	armor_deflection = XENO_ARMOR_TIER_3
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_3
	heal_standing = 0.66

	behavior_delegate_type = /datum/behavior_delegate/crusher_base

	tackle_min = 2
	tackle_max = 6
	tackle_chance = 25

	evolution_allowed = FALSE
	deevolves_to = XENO_CASTE_WARRIOR
	caste_desc = "A huge tanky xenomorph."

/mob/living/carbon/Xenomorph/Crusher
	caste_type = XENO_CASTE_CRUSHER
	name = XENO_CASTE_CRUSHER
	desc = "A huge alien with an enormous armored head crest."
	icon_size = 64
	icon_state = "Crusher Walking"
	plasma_types = list(PLASMA_CHITIN)
	tier = 3
	drag_delay = 6 //pulling a big dead xeno is hard

	small_explosives_stun = FALSE

	mob_size = MOB_SIZE_IMMOBILE

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3

	rebounds = FALSE // no more fucking pinball crooshers

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/pounce/crusher_charge,
		/datum/action/xeno_action/onclick/crusher_stomp,
		/datum/action/xeno_action/onclick/crusher_shield
	)

	mutation_type = CRUSHER_NORMAL
	claw_type = CLAW_TYPE_VERY_SHARP

	var/turf/travelling_turf
	var/linger_range = 6

/mob/living/carbon/Xenomorph/Crusher/make_ai()
	. = ..()
	var/datum/action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce/crusher_charge)
	A.hide_from(src)

	A = new /datum/action/xeno_action/activable/pounce/crusher_charge/ai()
	A.give_to(src)

/mob/living/carbon/Xenomorph/Crusher/remove_ai()
	qdel(get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce/crusher_charge/ai))
	give_action(src, /datum/action/xeno_action/activable/pounce/crusher_charge)
	return

// Refactored to handle all of crusher's interactions with object during charge.
/mob/living/carbon/Xenomorph/proc/handle_collision(atom/target)
	if(!target)
		return FALSE

	//Barricade collision
	else if (istype(target, /obj/structure/barricade))
		var/obj/structure/barricade/B = target
		visible_message(SPAN_DANGER("[src] rams into [B] and skids to a halt!"), SPAN_XENOWARNING("You ram into [B] and skid to a halt!"))

		B.Collided(src)
		. =  FALSE

	else if (istype(target, /obj/vehicle/multitile))
		var/obj/vehicle/multitile/M = target
		visible_message(SPAN_DANGER("[src] rams into [M] and skids to a halt!"), SPAN_XENOWARNING("You ram into [M] and skid to a halt!"))

		M.Collided(src)
		. = FALSE

	else if (istype(target, /obj/structure/machinery/m56d_hmg))
		var/obj/structure/machinery/m56d_hmg/HMG = target
		visible_message(SPAN_DANGER("[src] rams [HMG]!"), SPAN_XENODANGER("You ram [HMG]!"))
		playsound(loc, "punch", 25, 1)
		HMG.CrusherImpact()
		. =  FALSE

	else if (istype(target, /obj/structure/window))
		var/obj/structure/window/W = target
		if (W.unacidable)
			. = FALSE
		else
			W.shatter_window(1)
			. =  TRUE // Continue throw

	else if (istype(target, /obj/structure/machinery/door/airlock))
		var/obj/structure/machinery/door/airlock/A = target

		if (A.unacidable)
			. = FALSE
		else
			A.destroy_airlock()

	else if (istype(target, /obj/structure/grille))
		var/obj/structure/grille/G = target
		if(G.unacidable)
			. =  FALSE
		else
			G.health -=  80 //Usually knocks it down.
			G.healthcheck()
			. = TRUE

	else if (istype(target, /obj/structure/surface/table))
		var/obj/structure/surface/table/T = target
		T.Crossed(src)
		. = TRUE

	else if (istype(target, /obj/structure/machinery/defenses))
		var/obj/structure/machinery/defenses/DF = target
		visible_message(SPAN_DANGER("[src] rams [DF]!"), SPAN_XENODANGER("You ram [DF]!"))

		if (!DF.unacidable)
			playsound(loc, "punch", 25, 1)
			DF.stat = 1
			DF.update_icon()
			DF.update_health(40)

		. =  FALSE

	else if (istype(target, /obj/structure/machinery/vending))
		var/obj/structure/machinery/vending/V = target

		if (V.unslashable)
			. = FALSE
		else
			visible_message(SPAN_DANGER("[src] smashes straight into [V]!"), SPAN_XENODANGER("You smash straight into [V]!"))
			playsound(loc, "punch", 25, 1)
			V.tip_over()

			var/impact_range = 1
			var/turf/TA = get_diagonal_step(V, dir)
			TA = get_step_away(TA, src)
			var/launch_speed = 2
			launch_towards(TA, impact_range, launch_speed)

			. =  TRUE

	else if (istype(target, /obj/structure/machinery/cm_vending))
		var/obj/structure/machinery/cm_vending/V = target
		if (V.unslashable)
			. = FALSE
		else
			visible_message(SPAN_DANGER("[src] smashes straight into [V]!"), SPAN_XENODANGER("You smash straight into [V]!"))
			playsound(loc, "punch", 25, 1)
			V.tip_over()

			var/impact_range = 1
			var/turf/TA = get_diagonal_step(V, dir)
			TA = get_step_away(TA, src)
			var/launch_speed = 2
			throw_atom(TA, impact_range, launch_speed)

			. =  TRUE

	// Anything else?
	else
		if (isobj(target))
			var/obj/O = target
			if (O.unacidable)
				. = FALSE
			else if (O.anchored)
				visible_message(SPAN_DANGER("[src] crushes [O]!"), SPAN_XENODANGER("You crush [O]!"))
				if(O.contents.len) //Hopefully won't auto-delete things inside crushed stuff.
					var/turf/T = get_turf(src)
					for(var/atom/movable/S in T.contents) S.forceMove(T)

				qdel(O)
				. = TRUE

			else
				if(O.buckled_mob)
					O.unbuckle()
				visible_message(SPAN_WARNING("[src] knocks [O] aside!"), SPAN_XENOWARNING("You knock [O] aside.")) //Canisters, crates etc. go flying.
				playsound(loc, "punch", 25, 1)

				var/impact_range = 2
				var/turf/TA = get_diagonal_step(O, dir)
				TA = get_step_away(TA, src)
				var/launch_speed = 2
				throw_atom(TA, impact_range, launch_speed)

				. = TRUE

	if (!.)
		update_icons()

/mob/living/carbon/Xenomorph/Crusher/update_icons()
	if(stat == DEAD || lying)
		return ..()

	. = ..()

	if(caste.caste_type != caste.display_icon)
		return

	if(throwing) //Let it build up a bit so we're not changing icons every single turf
		icon_state = "[mutation_type] [caste.display_icon] Charging"


// Mutator delegate for base ravager
/datum/behavior_delegate/crusher_base
	name = "Base Crusher Behavior Delegate"

	var/aoe_slash_damage_reduction = 0.40

/datum/behavior_delegate/crusher_base/melee_attack_additional_effects_target(atom/A)

	if (!isXenoOrHuman(A))
		return

	new /datum/effects/xeno_slow(A, bound_xeno, , , 20)

	var/damage = bound_xeno.melee_damage_upper * aoe_slash_damage_reduction

	var/cdr_amount = 15
	for (var/mob/living/carbon/H in orange(1, A))
		if (H.stat == DEAD)
			continue

		if(!isXenoOrHuman(H) || bound_xeno.can_not_harm(H))
			continue

		cdr_amount += 5

		bound_xeno.visible_message(SPAN_DANGER("[bound_xeno] slashes [H]!"), \
			SPAN_DANGER("You slash [H]!"), null, null, CHAT_TYPE_XENO_COMBAT)

		bound_xeno.flick_attack_overlay(H, "slash")

		H.last_damage_source = initial(bound_xeno.name)
		H.last_damage_mob = bound_xeno

		//Logging, including anti-rulebreak logging
		if(H.status_flags & XENO_HOST && H.stat != DEAD)
			if(istype(H.buckled, /obj/structure/bed/nest)) //Host was buckled to nest while infected, this is a rule break
				H.attack_log += text("\[[time_stamp()]\] <font color='orange'><B>was slashed by [key_name(bound_xeno)] while they were infected and nested</B></font>")
				bound_xeno.attack_log += text("\[[time_stamp()]\] <font color='red'><B>slashed [key_name(H)] while they were infected and nested</B></font>")
				msg_admin_ff("[key_name(bound_xeno)] slashed [key_name(H)] while they were infected and nested.") //This is a blatant rulebreak, so warn the admins
			else //Host might be rogue, needs further investigation
				H.attack_log += text("\[[time_stamp()]\] <font color='orange'>was slashed by [key_name(bound_xeno)] while they were infected</font>")
				bound_xeno.attack_log += text("\[[time_stamp()]\] <font color='red'>slashed [key_name(src)] while they were infected</font>")
		else //Normal xenomorph friendship with benefits
			H.attack_log += text("\[[time_stamp()]\] <font color='orange'>was slashed by [key_name(bound_xeno)]</font>")
			bound_xeno.attack_log += text("\[[time_stamp()]\] <font color='red'>slashed [key_name(H)]</font>")
		log_attack("[key_name(bound_xeno)] slashed [key_name(H)]")


		H.apply_armoured_damage(get_xeno_damage_slash(H, damage), ARMOR_MELEE, BRUTE, bound_xeno.zone_selected)

	var/datum/action/xeno_action/activable/pounce/crusher_charge/cAction = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/crusher_charge)
	if (!cAction.action_cooldown_check())
		cAction.reduce_cooldown(cdr_amount)

	var/datum/action/xeno_action/onclick/crusher_shield/sAction = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/crusher_shield)
	if (!sAction.action_cooldown_check())
		sAction.reduce_cooldown(cdr_amount)

/datum/behavior_delegate/crusher_base/append_to_stat()
	. = list()
	var/shield_total = 0
	for (var/datum/xeno_shield/XS in bound_xeno.xeno_shields)
		if (XS.shield_source == XENO_SHIELD_SOURCE_CRUSHER)
			shield_total += XS.amount

	. += "Shield: [shield_total]"

/mob/living/carbon/Xenomorph/Crusher/process_ai(delta_time, game_evaluation)
	. = ..()

	if(.)
		return

	a_intent = INTENT_HARM
	create_hud()

	if(DT_PROB(CRUSHER_SHIELD, delta_time))
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/onclick/crusher_shield)
		if(health/maxHealth < CRUSHER_SHIELD_HEALTH_PROC)
			A.use_ability_async(null)

	if(throwing || frozen)
		return

	var/datum/action/xeno_action/charge_ability = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce/crusher_charge/ai)

	if(current_target.is_mob_incapacitated() || charge_ability.can_use_action())
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
		current_target = null
		return

	if(get_dist(src, current_target) <= CRUSHER_POUNCE_RANGE && DT_PROB(CRUSHER_POUNCE, delta_time))
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
			charge_ability.use_ability_async(current_target)
			SSxeno_pathfinding.stop_calculating_path(src)
			//stop_calculating_path()
			current_path = null

	if(get_dist(src, current_target) <= 1 && DT_PROB(XENO_SLASH, delta_time))
		INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())

	if(get_dist(src, current_target) <= 0 && DT_PROB(CRUSHER_STOMP, delta_time))
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/onclick/crusher_stomp)
		A.use_ability_async(null)
