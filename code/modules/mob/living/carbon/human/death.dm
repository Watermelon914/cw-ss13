/mob/living/carbon/human/gib(var/cause = "gibbing")
	var/is_a_synth = isSynth(src)
	for(var/obj/limb/E in limbs)
		if(istype(E, /obj/limb/chest))
			continue
		if(istype(E, /obj/limb/groin) && is_a_synth)
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - E.get_damage()))
			// Override the current limb status
			E.droplimb(0, 0, cause)

	undefibbable = TRUE

	GLOB.data_core.manifest_modify(real_name, null, null, "*Deceased*")

	if(is_a_synth)
		spawn_gibs()
		return
	..()

/mob/living/carbon/human/gib_animation()
	new /obj/effect/overlay/temp/gib_animation(loc, src, species ? species.gibbed_anim : "gibbed-h")

/mob/living/carbon/human/spawn_gibs()
	if(species)
		hgibs(loc, viruses, src, species.flesh_color, species.blood_color)
	else
		hgibs(loc, viruses, src)

/mob/living/carbon/human/spawn_dust_remains()
	if(species)
		new species.remains_type(loc)
	else
		new /obj/effect/decal/cleanable/ash(loc)

/mob/living/carbon/human/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-h")


/mob/living/carbon/human/Login()
	. = ..()
	if(stat != DEAD)
		GLOB.alive_client_human_list += src

/mob/living/carbon/human/Logout()
	GLOB.alive_client_human_list -= src
	return ..()

/mob/living/carbon/human/death(var/cause, var/gibbed)
	if(stat == DEAD)
		return
	GLOB.alive_human_list -= src
	GLOB.alive_client_human_list -= src
	if(!gibbed)
		disable_special_flags()
		disable_lights()
		disable_special_items()
		disable_headsets() //Disable radios for dead people to reduce load
	if(pulledby && isXeno(pulledby)) // Xenos lose grab on dead humans
		pulledby.stop_pulling()
	//Handle species-specific deaths.
	if(species)
		species.handle_death(src, gibbed)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MARINE_DEATH, src, gibbed)

	if(!gibbed && species.death_sound)
		playsound(loc, species.death_sound, 50, 1)

	return ..(cause, gibbed, species.death_message)
