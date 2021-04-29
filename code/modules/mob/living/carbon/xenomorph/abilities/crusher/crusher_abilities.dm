/datum/action/xeno_action/activable/pounce/crusher_charge
	name = "Charge"
	action_icon_state = "ready_charge"
	ability_name = "charge"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 140
	plasma_cost = 5

	var/direct_hit_damage = 60

	// Config options
	distance = 9

	knockdown = TRUE
	knockdown_duration = 2
	slash = FALSE
	freeze_self = FALSE
	windup = TRUE
	windup_duration = 12
	windup_interruptable = FALSE
	should_destroy_objects = TRUE
	throw_speed = SPEED_FAST
	tracks_target = FALSE

	// Object types that dont reduce cooldown when hit
	var/list/not_reducing_objects = list()

/datum/action/xeno_action/activable/pounce/crusher_charge/ai
	windup = FALSE

	windup_duration = 3 SECONDS
	// When to acquire target before launching
	var/when_to_get_turf = 0.5 SECONDS
	var/additional_turfs_to_charge = 3
	var/charging = FALSE

	prob_chance = 75

/datum/action/xeno_action/activable/pounce/crusher_charge/ai/use_ability(atom/A)
	if(charging || !action_cooldown_check() || !can_use_action())
		return

	var/mob/living/carbon/Xenomorph/M = owner

	M.anchored = TRUE
	M.frozen = TRUE

	charging = TRUE

	var/failed = FALSE
	if(!do_after(M, windup_duration - when_to_get_turf, INTERRUPT_INCAPACITATED, BUSY_ICON_HOSTILE))
		failed = TRUE

	if(!failed)
		var/direction = get_dir(M, A)

		if(direction in GLOB.diagonals)
			if(abs(M.x - A.x) < abs(M.y - A.y))
				direction &= (NORTH|SOUTH)
			else
				direction &= (EAST|WEST)

		for(var/i in 1 to additional_turfs_to_charge)
			A = get_step(A, direction)

		M.add_filter("unavoidable_act", 1, list("type" = "outline", "color" = "#ffa800", "size" = 1))
		var/filter = M.get_filter("unavoidable_act")
		animate(filter, alpha=0, time = 0.1 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 0.1 SECONDS)

		if(!do_after(M, when_to_get_turf, INTERRUPT_INCAPACITATED, BUSY_ICON_HOSTILE))
			failed = TRUE

		animate(filter)
		M.remove_filter("unavoidable_act")

	M.anchored = FALSE
	M.frozen = FALSE
	charging = FALSE

	if(failed)
		return

	return ..(A)


/datum/action/xeno_action/activable/pounce/crusher_charge/ai/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(get_dist(X, X.current_target) > distance || DT_PROB(prob_chance, delta_time))
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

/datum/action/xeno_action/activable/pounce/crusher_charge/New()
	. = ..()
	not_reducing_objects = typesof(/obj/structure/barricade) + typesof(/obj/structure/machinery/defenses)

/datum/action/xeno_action/activable/pounce/crusher_charge/initialize_pounce_pass_flags()
	pounce_pass_flags = PASS_CRUSHER_CHARGE

/datum/action/xeno_action/onclick/crusher_stomp
	name = "Stomp"
	action_icon_state = "stomp"
	ability_name = "stomp"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	xeno_cooldown = 180
	plasma_cost = 20

	var/damage = 65

	var/distance = 2
	var/effect_type_base = /datum/effects/xeno_slow/superslow
	var/effect_duration = 10

	var/prob_chance_on_person = 100
	var/prob_chance = 10

/datum/action/xeno_action/onclick/crusher_stomp/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if((get_dist(X, X.current_target) <= 0 && DT_PROB(prob_chance_on_person, delta_time)) \
		|| (get_dist(X, X.current_target) <= 1 && DT_PROB(prob_chance, delta_time)))
		use_ability_async()

/datum/action/xeno_action/onclick/crusher_shield
	name = "Defensive Shield"
	action_icon_state = "empower"
	ability_name = "defensive shield"
	macro_path = /datum/action/xeno_action/verb/verb_crusher_charge
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 260
	plasma_cost = 20

	var/shield_amount = 200
	default_ai_action = TRUE

	var/ai_percentage_activate = 0.25
	var/prob_chance = 100

/datum/action/xeno_action/onclick/crusher_shield/process_ai(mob/living/carbon/Xenomorph/X, delta_time, game_evaluation)
	if(DT_PROB(prob_chance, delta_time) && X.health/X.maxHealth < ai_percentage_activate)
		use_ability_async()
