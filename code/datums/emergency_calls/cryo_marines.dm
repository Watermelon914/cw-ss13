

//whiskey outpost extra marines
/datum/emergency_call/cryo_squad
	name = "Marine Cryo Reinforcements (Squad)"
	mob_max = 15
	mob_min = 1
	probability = 0
	objectives = "Assist the USCM forces"
	max_heavies = 4
	max_medics = 2
	name_of_spawn = "Distress_Cryo"
	shuttle_id = ""

/datum/emergency_call/cryo_squad/create_member(datum/mind/M)
	set waitfor = 0
	if(map_tag == MAP_WHISKEY_OUTPOST)
		name_of_spawn = "distress_wo"
	var/turf/spawn_loc = get_spawn_point()

	if(!istype(spawn_loc)) return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/H = new(spawn_loc)
	H.key = M.key
	if(H.client) H.client.change_view(world.view)
	if(H.mind)
		H.mind.assigned_role = ""
		H.mind.special_role = ""

	sleep(5)
	if (medics < max_medics)
		arm_equipment(H, "USCM (Cryo) Squad Medic", TRUE)
		H << "<font size='3'>\red You are a medic in the USCM, you are here to assist in the defence of the [map_tag]. Listen to the chain of command. </B>"
		medics ++
	else if (heavies < max_heavies)
		arm_equipment(H, "USCM (Cryo) Squad Engineer", TRUE)
		H << "<font size='3'>\red You are an engineer in the USCM, you are here to assist in the defence of the [map_tag]. Listen to the chain of command. </B>"
		heavies ++
	else
		arm_equipment(H, "USCM (Cryo) Squad Marine (PFC)", TRUE)
		H << "<font size='3'>\red You are a private in the USCM, you are here to assist in the defence of the [map_tag]. Listen to the chain of command. </B>"
		
	sleep(10)
	H << "<B>Objectives:</b> [objectives]"
	RoleAuthority.randomize_squad(H, TRUE) //we force put people in squads so even if we have a max amount of medics / engis we still give them a squad
	H.sec_hud_set_ID()
	H.sec_hud_set_implants()
	H.hud_set_special_role()
	H.hud_set_squad()

datum/emergency_call/cryo_squad/platoon
	name = "Marine Cryo Reinforcements (Platoon)"
	mob_min = 8
	mob_max = 30
	probability = 0
	max_heavies = 8