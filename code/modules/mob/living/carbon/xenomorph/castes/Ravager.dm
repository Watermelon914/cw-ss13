/datum/caste_datum/ravager
	caste_type = XENO_CASTE_RAVAGER
	display_icon = XENO_CASTE_RAVAGER
	display_name = XENO_CASTE_RAVAGER
	tier = 3

	melee_damage_lower = XENO_DAMAGE_TIER_6
	melee_damage_upper = XENO_DAMAGE_TIER_6
	max_health = XENO_HEALTH_TIER_8
	plasma_gain = XENO_PLASMA_GAIN_TIER_9
	plasma_max = XENO_PLASMA_TIER_3
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_8
	armor_deflection = XENO_ARMOR_TIER_2
	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_4
	heal_standing = 0.66

	tackle_min = 2
	tackle_max = 5
	tackle_chance = 35
	tacklestrength_min = 4
	tacklestrength_max = 5

	evolution_allowed = FALSE
	deevolves_to = XENO_CASTE_LURKER
	caste_desc = "A brutal, devastating front-line attacker."
	fire_immunity = FIRE_IMMUNITY_NO_DAMAGE
	attack_delay = -1

	behavior_delegate_type = /datum/behavior_delegate/ravager_base

/mob/living/carbon/Xenomorph/Ravager
	caste_type = XENO_CASTE_RAVAGER
	name = XENO_CASTE_RAVAGER
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon_size = 64
	icon_state = "Ravager Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	var/used_charge = 0
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = 3
	pixel_x = -16
	old_x = -16
	mutation_type = RAVAGER_NORMAL
	claw_type = CLAW_TYPE_VERY_SHARP

	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/empower,
		/datum/action/xeno_action/activable/pounce/charge,
		/datum/action/xeno_action/activable/scissor_cut
	)

// Mutator delegate for base ravager
/datum/behavior_delegate/ravager_base
	var/damage_per_shield_hp = 0.10
	var/shield_decay_time = 150 // Time in deciseconds before our shield decays
	var/slash_charge_cdr = 20 // Amount to reduce charge cooldown by per slash
	var/min_shield_buffed_abilities = 150
	var/knockdown_amount = 2
	var/fling_distance = 3

/datum/behavior_delegate/ravager_base/melee_attack_modify_damage(original_damage, atom/A = null)
	var/shield_total = 0
	for (var/datum/xeno_shield/XS in bound_xeno.xeno_shields)
		if (XS.shield_source == XENO_SHIELD_SOURCE_RAVAGER)
			shield_total += XS.amount

	return original_damage + damage_per_shield_hp*shield_total

/datum/behavior_delegate/ravager_base/melee_attack_additional_effects_self()
	..()

	var/datum/action/xeno_action/activable/pounce/charge/cAction = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/charge)
	if (!cAction.action_cooldown_check())
		cAction.reduce_cooldown(slash_charge_cdr)

/datum/behavior_delegate/ravager_base/append_to_stat()
	. = list()
	var/shield_total = 0
	for (var/datum/xeno_shield/XS in bound_xeno.xeno_shields)
		if (XS.shield_source == XENO_SHIELD_SOURCE_RAVAGER)
			shield_total += XS.amount

	. += "Empower Shield: [shield_total]"
	. += "Bonus Slash Damage: [shield_total*damage_per_shield_hp]"

/datum/behavior_delegate/ravager_base/on_life()
	var/datum/xeno_shield/rav_shield
	for (var/datum/xeno_shield/XS in bound_xeno.xeno_shields)
		if (XS.shield_source == XENO_SHIELD_SOURCE_RAVAGER)
			rav_shield = XS
			break

	if (rav_shield && ((rav_shield.last_damage_taken + shield_decay_time) < world.time))
		QDEL_NULL(rav_shield)
		to_chat(bound_xeno, SPAN_XENODANGER("You feel your shield decay!"))
		bound_xeno.overlay_shields()

/mob/living/carbon/Xenomorph/Ravager/process_ai(delta_time, game_evaluation)
	. = ..()

	if(.)
		return

	a_intent = INTENT_HARM
	create_hud()

	if(throwing)
		return

	var/turf/T = get_turf(current_target)
	if(get_dist(src, current_target) <= 1)
		var/list/turfs = RANGE_TURFS(1, T)
		while(length(turfs))
			T = pick(turfs)
			turfs -= T
			if(!T.density)
				break

			if(T == get_turf(current_target))
				break


	if(!move_to_next_turf(T))
		current_target = null
		return

	if(get_dist(src, current_target) <= RAVAGER_LUNGE_RANGE)
		var/shield_total = 0
		for (var/l in xeno_shields)
			var/datum/xeno_shield/XS = l
			if (XS.shield_source == XENO_SHIELD_SOURCE_RAVAGER)
				shield_total += XS.amount
				break
		var/datum/behavior_delegate/ravager_base/BD = behavior_delegate

		var/clear
		if (shield_total > BD.min_shield_buffed_abilities)
			clear = DT_PROB(RAVAGER_LUNGE_SHIELD, delta_time)
		else
			clear = DT_PROB(RAVAGER_LUNGE, delta_time)

		if(clear)
			var/turf/last_turf = loc
			add_temp_pass_flags(PASS_OVER_THROW_MOB)
			for(var/i in getline2(src, current_target, FALSE))
				var/turf/new_turf = i
				if(LinkBlocked(src, last_turf, new_turf, list(current_target, src)))
					clear = FALSE
					break
			remove_temp_pass_flags(PASS_OVER_THROW_MOB)

		if(clear)
			var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/pounce/charge)
			A.use_ability_async(current_target)
			SSxeno_pathfinding.stop_calculating_path(src)
			//stop_calculating_path()
			current_path = null

	if(DT_PROB(RAVAGER_SHIELD, delta_time))
		var/datum/action/xeno_action/activable/empower/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/empower)
		var/should_apply = FALSE
		if(health/maxHealth < RAVAGER_SHIELD_PROC_HEALTH)
			should_apply = TRUE

		var/humans_around = 0
		for(var/i in GLOB.alive_client_human_list)
			var/mob/living/carbon/human/H = i
			if(get_dist(H, src) <= A.empower_range)
				humans_around++

			if(humans_around >= RAVAGER_SHIELD_PROC_PEOPLE)
				should_apply = TRUE
				break

		if(should_apply)
			A.use_ability_async(null)

	if(DT_PROB(RAVAGER_SCISSOR_CUT, delta_time) && get_dist(src, current_target) <= RAVAGER_SCISSOR_CUT_RANGE)
		var/datum/action/xeno_action/A = get_xeno_action_by_type(src, /datum/action/xeno_action/activable/scissor_cut)
		A.use_ability_async(current_target)

	zone_selected = pick(GLOB.warrior_target_limbs)
	if(get_dist(src, current_target) <= 1 && DT_PROB(XENO_SLASH, delta_time))
		INVOKE_ASYNC(src, /mob.proc/do_click, current_target, "", list())
