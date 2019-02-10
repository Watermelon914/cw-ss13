//SCP-096, nothing more need be said
/mob/living/simple_animal/scp/shyguy
	name = "???"
	desc = "No, no, you know not to look closely at it" //for non-targets
	var/target_desc_1 = "A pale, emanciated figure. It looks almost human, but its limbs are long and skinny, and its face is......<span class='danger'>no. NO. NO</span>" //for targets
	var/target_desc_2 = "<span class='danger'>NO</span>" //on second examine
	icon_state = "shyguy_dam0"
	icon_living = "shyguy_dam0"
	icon_dead = "shyguy_dam0"
	emote_hear = list("makes a faint groaning sound")
	emote_see = list("shuffles around aimlessly", "shivers")
	layer = BELOW_MOB_LAYER

	health = 600
	maxHealth = 600
	var/move_to_delay = 2

	var/murder_sound = list('sound/voice/scream_horror2.ogg')

	var/list/shitlist = list() //list of folks this guy is about to murder
	var/list/examine_urge_list = list() //tracks urge to examine
	var/list/examine_urge_values = list()
	var/target //current dude this guy is targeting
	var/screaming = 0 //are we currently screaming?
	var/will_scream = 1 //will we scream when examined?
	var/staggered = 0
	var/chasing = 0 //are we chasing a dude
	var/murdering = 0 //are we in the middle of murdering a dude

	var/chasing_message_played = 0 //preferably, these only play once to each target
	var/doom_message_played = 0

	var/damage_state = 0

/mob/living/simple_animal/scp/shyguy/Life()
	if(hibernate)
		return

	check_los()
	staggered = max(staggered/8 - 1, 0)
	adjustBruteLoss(-5)

	if(screaming) //we're still screaming
		return

	//Pick the next target
	if(!target && shitlist.len)
		var/mob/living/carbon/H
		for(var/i = 1, i <= shitlist.len, i++) //start from the first guy
			H = shitlist[1]
			if(!H || H.stat == DEAD || !istype(H))
				shitlist -= H
				chasing_message_played = 0
				doom_message_played = 0
				murdering = 0
			else
				target = H
				continue
	else
		will_scream = 1
		chasing_message_played = 0
		doom_message_played = 0
		murdering = 0

	if(target)
		handle_target(target)
	else
		chasing_message_played = 0
		doom_message_played = 0
		murdering = 0
		chasing = 0
		will_scream = 1
		handle_idle()

/mob/living/simple_animal/scp/shyguy/on_observed(var/mob/living/carbon/H)
	. = ..()
	if(. == TRUE) //would be false if we add blinking or something
		if(!(H in shitlist))
			add_examine_urge(H)

//Function to call for each mob that has eye contact with us (we are looking at it, it is looking at us)
/mob/living/simple_animal/scp/shyguy/on_eye_contact(var/mob/living/carbon/H)
	. = ..()
	if(. == TRUE) //would be false if we add blinking or something
		if(!(H in shitlist))
			H << "<span class='alert'>You are facing it, and it is facing you...</span>"
			add_examine_urge(H)


/mob/living/simple_animal/scp/shyguy/proc/add_examine_urge(var/mob/living/carbon/H)
	if(!H || !istype(H))
		return
	var/index
	var/examine_urge

	if(H in examine_urge_list)
		index = examine_urge_list.Find(H)
		examine_urge = examine_urge_values[index]
	else
		examine_urge_list += H
		index = examine_urge_list.Find(H)
		examine_urge = 1
		examine_urge_values += examine_urge

	switch(examine_urge)
		if(1)
			H << "<span class='alert'>You feel the urge to examine it...</span>"
		if(3)
			H << "<span class='alert'>It is becoming difficult to resist the urge to examine it ...</span>"
		if(5)
			H << "<span class='alert'>Unable to resist the urge, you look closely...</span>"
			spawn(10)
				examine(H)

	examine_urge = min(examine_urge+1, 5)
	examine_urge_values[index] = examine_urge

	spawn(300)
		if(H)
			reduce_examine_urge(H)

/mob/living/simple_animal/scp/shyguy/proc/reduce_examine_urge(var/mob/living/carbon/H)
	if(!H || !istype(H))
		return
	var/index
	var/examine_urge

	if(H in examine_urge_list)
		index = examine_urge_list.Find(H)
		examine_urge = examine_urge_values[index]
	else return

	if (examine_urge == 1 && !(H in shitlist))
		H << "<span class='notice'>The urge fades away...</span>"

	examine_urge = max(examine_urge-1, 0)

	examine_urge_values[index] = examine_urge

/mob/living/simple_animal/scp/shyguy/examine(var/userguy)
	if (istype(userguy, /mob/living/carbon))
		if (!(userguy in shitlist))
			userguy <<  target_desc_1
			shitlist += userguy
			spawn(20)
				if(userguy)
					userguy << "<span class='alert'>Run</span>"
			spawn(30)
				if(userguy)
					userguy << "<span class='danger'>RUN</span>"
		else
			userguy << target_desc_2
		if(will_scream)
			if(!buckled) dir = 2
			visible_message("<span class='danger'>[src] SCREAMS!</span>")
			playsound(get_turf(src), 'sound/voice/scream_horror1.ogg', 50, 1)
			screaming = 1
			will_scream = 0
			for(var/mob/M in viewers(src, null))
				shake_camera(M, 19, 2)
			spawn(100)
				visible_message("<span class='danger'>[src] SCREAMS!</span>")
				playsound(get_turf(src), 'sound/voice/scream_horror1.ogg', 50, 1)
				for(var/mob/M in viewers(src, null))
					shake_camera(M, 19, 2)
			spawn(200)
				visible_message("<span class='danger'>[src] SCREAMS!</span>")
				playsound(get_turf(src), 'sound/voice/scream_horror1.ogg', 50, 1)
				for(var/mob/M in viewers(src, null))
					shake_camera(M, 19, 2)
			spawn(300)
				screaming = 0
		return
	..()


/mob/living/simple_animal/scp/shyguy/handle_target(var/mob/living/carbon/target, var/forced = FALSE)
	if(!target || chasing || !istype(target)) //Sanity
		return

	if(forced)
		//We are lashing out at them by triggering the examine condition
		examine(target)

	if(target.stat == DEAD)
		target = null
		return

	if(buckled)
		visible_message("<span class='danger'>[src] breaks out of its restraints!</span>")
		buckled.unbuckle()

	var/turf/target_turf

	//Send the warning that we are is homing in
	target_turf = get_turf(target)

	if(!chasing_message_played)
		target << "<span class='danger'>You saw its face</span>"
		chasing_message_played = 1

	if(!scare_played) //Let's minimize the spam
		playsound(get_turf(src), pick(scare_sound), 50, 1)
		scare_played = 1
		for(var/mob/M in viewers(src, null))
			shake_camera(M, 19, 1)
		spawn(50)
			scare_played = 0

	//Just in case target is on the same tile
	if(target_turf == get_turf(src))
		murder(target)

	//Rampage along a path to get to them,
	var/turf/next_turf = get_step_towards(src, target)
	var/limit = 100
	spawn()
		chasing = 1
		while(target && get_turf(src) != target_turf && limit > 0)
			if(murdering <= 0)
				target_turf = get_turf(target)

				for(var/obj/machinery/door/D in next_turf)
					if(D.density)
						D.open()
						sleep(10)
						if(D.density)
							D.ex_act(EXPLOSION_THRESHOLD_HIGH)
				for(var/obj/structure/S in next_turf)
					if(S.density)
						S.ex_act(EXPLOSION_THRESHOLD_MEDIUM)
						sleep(5)
						if(S && S.density)
							S.ex_act(1000000)
				if(istype(next_turf, /turf/closed))
					next_turf.ex_act(EXPLOSION_THRESHOLD_HIGH)
					sleep(10)
					if(next_turf && istype(next_turf, /turf/closed))
						next_turf.ex_act(1000000)

				if(!next_turf.CanPass(src, next_turf)) //Once we cleared everything we could, check one last time if we can pass
					sleep(10)

				if(doom_message_played == 0 && get_dist(src,target) < 7)
					target << "<span class='danger'>YOU SAW ITS FACE</span>"
					doom_message_played = 1

				forceMove(next_turf)

				if(is_different_level(target_turf))
					next_turf = target_turf
					target << "<span class='danger'>DID YOU THINK YOU COULD HIDE?</span>"
				else
					dir = get_dir(src, target)
					next_turf = get_step(src, get_dir(next_turf,target))
			limit--
			sleep(move_to_delay + round(staggered/8))
		chasing = 0

/mob/living/simple_animal/scp/shyguy/proc/is_different_level(var/turf/target_turf)
	if(!target_turf || !istype(target_turf))
		return 0
	if(target_turf.z != z)
		return 1

	var/source_level = 0 //0 means lower level or left side, depending on map, 1 means upper level or right side
	var/target_level = 0

	switch(z)
		if(MAIN_SHIP_Z_LEVEL) //on the Almayer
			switch(y)
				if(0 to 100)
					source_level = 0
				if(100 to 200)
					source_level = 1
				else
					source_level = 2
			switch(target_turf.y)
				if(0 to 100)
					target_level = 0
				if(100 to 200)
					target_level = 1
				else
					target_level = 2
		if(LOW_ORBIT_Z_LEVEL) //dropships
			switch(x)
				if (0 to 44)
					source_level = 0
				else
					source_level = 1
			switch(target_turf.x)
				if (0 to 44)
					target_level = 0
				else
					target_level = 1

	if(source_level != target_level)
		return 1

	return 0

//This performs an immediate murder check, meant to avoid people cheesing us by just running faster than Life() refresh
/mob/living/simple_animal/scp/shyguy/proc/check_murder()

	if(!target)
		return

	//See if we're able to murder anyone
	for(var/mob/living/carbon/M in get_turf(src))
		if(M == target)
			murder(M)
			break

/mob/living/simple_animal/scp/shyguy/forceMove(atom/destination, var/no_tp = 0)

	..()
	for(var/mob/living/carbon/M in get_turf(src))
		if(M == target || !M.density)
			continue
		playsound(loc, "punch", 25, 1)
		M.apply_damage(50, BRUTE)
		visible_message("<span class='danger'>[src] knocks [M] aside!</span>")
		M.KnockDown(4)
		animation_flash_color(M)
		diagonal_step(M, dir) //Occasionally fling it diagonally.
		step_away(M, src, 3)
	check_murder()

/mob/living/simple_animal/scp/shyguy/proc/diagonal_step(atom/movable/A, direction)
	if(!A) r_FAL
	switch(direction)
		if(EAST, WEST) step(A, pick(NORTH,SOUTH))
		if(NORTH,SOUTH) step(A, pick(EAST,WEST))

/mob/living/simple_animal/scp/shyguy/proc/murder(var/mob/living/T)

	if(T)
		T.loc = src.loc
		visible_message("<span class='danger'>[src] grabs [T]!</span>")
		animation_flash_color(T)
		dir = 2
		T.KnockDown(10)
		T.anchored = 1
		var/original_y = T.pixel_y
		T.pixel_y = 10
		murdering = 1

		for(var/mob/M in viewers(src, null))
			shake_camera(M, 30, 1)

		sleep(20)

		animation_flash_color(T)
		T.anchored = 0
		T.pixel_y = original_y
		if(ishuman(T))
			T.emote("scream")
		playsound(T.loc, pick(murder_sound), 50, 1)
		murdering = 0

		//Warn everyone
		visible_message("<span class='danger'>[src] tears [T] apart!</span>")

		T.gib()

		//Logging stuff
		T.attack_log += text("\[[time_stamp()]\] <font color='red'>has been torn apart by [src]!</font>")
		log_admin("[T] ([T.ckey]) has been torn apart by an active [src].")
		message_admins("ALERT: <A HREF='?_src_=admin_holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[T.real_name]</a> has been torn apart by an active [src].")
		shitlist -= T

		if (target == T)
			target = null
			chasing_message_played = 0
			doom_message_played = 0

/mob/living/simple_animal/scp/shyguy/proc/handle_idle()

	//Movement
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					Move(get_step(src,pick(cardinal)))
					turns_since_move = 0

	//Speaking
	if(!client && speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)

	//Do we have a vent ? Good, let's take a look
	if(buckled) return
	for(entry_vent in view(1, src))
		if(prob(90)) //10 % chance to consider a vent, to try and avoid constant vent switching
			return
		visible_message("<span class='danger'>\The [src] starts trying to slide itself into the vent!</span>")
		sleep(50) //Let's stop for five seconds to do our parking job
		..()
		if(entry_vent.network && entry_vent.network.normal_members.len)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.network.normal_members)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			spawn()
				visible_message("<span class='danger'>\The [src] suddenly disappears into the vent!</span>")
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc)/2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						forceMove(get_turf(entry_vent))
						entry_vent = null
						visible_message("<span class='danger'>\The [src] suddenly appears from the vent!</span>")
						return

					forceMove(get_turf(exit_vent))
					entry_vent = null
					visible_message("<span class='danger'>\The [src] suddenly appears from the vent!</span>")
		else
			entry_vent = null

/mob/living/simple_animal/scp/shyguy/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj || Proj.damage <= 0)
		return 0

	visible_message("<span class='danger'>[src] is staggered by [Proj]!</span>")
	adjustBruteLoss(Proj.damage)
	return 1

/mob/living/simple_animal/scp/shyguy/adjustBruteLoss(var/damage)

	health = Clamp(health - damage, 0, maxHealth)

	if(damage > 0)
		staggered += damage

	var/old_damage_state = damage_state
	damage_state = round( (1-health/maxHealth) * 3.99 )
	icon_state = "shyguy_dam[damage_state]"

	if(old_damage_state < damage_state)
		visible_message("<span class='danger'>Chunks of flesh and bone are torn out of [src]!</span>")
	else if(old_damage_state > damage_state)
		visible_message("<span class='danger'>[src] regenerates some of its missing pieces!</span>")



/mob/living/simple_animal/scp/shyguy/Bump(atom/movable/AM as mob)
	..()

/mob/living/simple_animal/scp/shyguy/Bumped(atom/movable/AM as mob, yes)
	..()

//You cannot destroy us, fool!
/mob/living/simple_animal/scp/shyguy/ex_act(var/severity)
	visible_message("<span class='danger'>[src] is staggered by the explosion!</span>")
	adjustBruteLoss(severity)
	return 1

/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	..()
	if(O.force)
		visible_message("<span class='danger'>[src] is staggered by [O]!</span>")
		adjustBruteLoss(O.force)