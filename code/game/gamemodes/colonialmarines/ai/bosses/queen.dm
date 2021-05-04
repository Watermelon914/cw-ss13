/datum/boss_battle/queen
	name = "Queen"
	var/boss_health_scale_per_player = 4

/datum/boss_battle/queen/spawn_boss_in(var/player_count, var/turf/spawn_loc)
	for(var/i in GLOB.alive_client_human_list)
		to_chat(i, SPAN_HIGHDANGER("This is it. This is the Queen's chamber. Kill the Queen to succeed in your objectives!"))

	var/mob/living/carbon/Xenomorph/Queen/X = new(spawn_loc)
	X.maxHealth *= (length(GLOB.alive_client_human_list) / boss_health_scale_per_player)
	X.health = X.maxHealth
