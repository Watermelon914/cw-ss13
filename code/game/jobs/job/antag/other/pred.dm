#define PREDATOR_TO_MARINES_SPAWN_RATIO 1/40

/datum/job/antag/predator
	title = JOB_PREDATOR
	selection_class = "job_predator"
	flags_startup_parameters = NO_FLAGS
	flags_whitelist = WHITELIST_YAUTJA
	supervisors = "Ancients"
	gear_preset = "Yautja Blooded"

/datum/job/antag/predator/set_spawn_positions(var/count)
	spawn_positions = max((round(count * PREDATOR_TO_MARINES_SPAWN_RATIO)), 4)
	total_positions = spawn_positions

/datum/job/antag/predator/spawn_in_player(mob/new_player/NP)
	if(!NP?.client)
		return

	var/clan_id = CLAN_SHIP_PUBLIC
	var/datum/entity/clan_player/clan_info = NP?.client?.clan_info
	clan_info?.sync()
	if(clan_info?.clan_id)
		clan_id = clan_info.clan_id
	SSpredships.load_new(clan_id)
	var/turf/spawn_point = SAFEPICK(SSpredships.get_clan_spawnpoints(clan_id))
	if(!isturf(spawn_point))
		log_debug("Failed to find spawn point for pred ship in JobAuthority - clan_id=[clan_id]")
		to_chat(NP, SPAN_WARNING("Unable to setup spawn location - you might want to tell someone about this."))
		return

	NP.spawning = TRUE
	NP.close_spawn_windows()
	var/mob/living/carbon/human/yautja/Y = new(NP.loc)
	Y.lastarea = get_area(NP.loc)

	Y.forceMove(spawn_point)
	Y.job = NP.job
	Y.name = NP.real_name
	Y.voice = NP.real_name

	NP.mind_initialize()
	NP.mind.transfer_to(Y, TRUE)
	NP.mind.setup_human_stats()

	return Y


/datum/job/antag/predator/announce_entry_message(var/mob/new_predator, var/account, var/whitelist_status)
	to_chat(new_predator, SPAN_NOTICE("You are <B>Yautja</b>, a great and noble predator!"))
	to_chat(new_predator, SPAN_NOTICE("Your job is to first study your opponents. A hunt cannot commence unless intelligence is gathered."))
	to_chat(new_predator, SPAN_NOTICE("Hunt at your discretion, yet be observant rather than violent."))

/datum/job/antag/predator/generate_entry_conditions(mob/living/M, var/whitelist_status)
	. = ..()

	if(SSticker.mode)
		SSticker.mode.initialize_predator(M, whitelist_status == CLAN_RANK_ADMIN)
