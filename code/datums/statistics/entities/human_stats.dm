/datum/entity/player_stats/human
	var/total_friendly_fire = 0
	var/total_revives = 0
	var/total_lives_saved = 0
	var/total_shots = 0
	var/total_shots_hit = 0
	var/total_screams = 0
	var/datum/entity/weapon_stats/top_weapon = null // reference to /datum/entity/weapon_stats (like tac-shotty)
	var/list/weapon_stats_list = list() // list of types /datum/entity/weapon_stats
	var/list/job_stats_list = list() // list of types /datum/entity/job_stats

//******************
//Stat Procs - setup
//******************

/datum/entity/player_stats/human/proc/setup_job_stats(var/job)
	if(!job)
		return
	var/job_key = strip_improper(job)
	if(job_stats_list["[job_key]"])
		return job_stats_list["[job_key]"]
	var/datum/entity/player_stats/job/new_stat = new()
	new_stat.player = player
	new_stat.name = job_key
	job_stats_list["[job_key]"] = new_stat
	return new_stat

/datum/entity/player_stats/human/proc/setup_weapon_stats(var/weapon)
	if(!weapon)
		return
	var/weapon_key = strip_improper(weapon)
	if(weapon_stats_list["[weapon_key]"])
		return weapon_stats_list["[weapon_key]"]
	var/datum/entity/weapon_stats/new_stat = new()
	new_stat.player = src
	new_stat.name = weapon_key
	weapon_stats_list["[weapon_key]"] = new_stat
	return new_stat

//******************
//Stat Procs - death
//******************

/mob/living/carbon/human/track_death_calculations()
	if(statistic_exempt || !mind)
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	if(!human_stats.round_played)
		human_stats.total_rounds_played += 1
		human_stats.round_played = TRUE
	human_stats.total_playtime += life_time_total
	human_stats.track_job_playtime(job, life_time_total)
	human_stats.recalculate_top_weapon()
	human_stats.recalculate_nemesis()
	..()

/datum/entity/player_stats/human/recalculate_nemesis()
	for(var/job_statistic in job_stats_list)
		var/datum/entity/player_stats/job/job_entity = job_stats_list[job_statistic]
		job_entity.recalculate_nemesis()
	..()

/datum/entity/player_stats/human/proc/recalculate_top_weapon()
	for(var/statistics in weapon_stats_list)
		var/datum/entity/weapon_stats/stat_entity = weapon_stats_list[statistics]
		if(!top_weapon)
			top_weapon = stat_entity
			continue
		if(stat_entity.total_kills > top_weapon.total_kills)
			top_weapon = stat_entity

/datum/entity/player_stats/human/proc/track_job_playtime(var/job, var/time = 0)
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	if(!S.round_played)
		S.total_rounds_played += 1
		S.round_played = TRUE
	S.total_playtime += time
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_playtime += time

/datum/entity/player_stats/human/count_personal_death(var/job)
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_deaths += 1
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_deaths += 1

//******************
//Stat Procs - kills
//******************

/datum/entity/player_stats/human/count_personal_human_kill(var/job_name, var/cause, var/job)
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.count_human_kill(job_name, cause)
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.count_human_kill(job_name, cause)
	if(cause)
		var/datum/entity/weapon_stats/W = setup_weapon_stats(cause)
		W.count_human_kill(job_name)
		if(round_statistics)
			var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(cause)
			R.count_human_kill(job_name)

/datum/entity/player_stats/human/count_personal_xeno_kill(var/caste_name, var/cause, var/job)
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.count_xeno_kill(caste_name, cause)
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.count_xeno_kill(caste_name, cause)
	if(cause)
		var/datum/entity/weapon_stats/W = setup_weapon_stats(cause)
		W.count_xeno_kill(caste_name)
		if(round_statistics)
			var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(cause)
			R.count_xeno_kill(caste_name)

/datum/entity/player_stats/human/count_human_kill(var/job_name, var/cause, var/job)
	if(!job_name)
		return
	if(cause)
		var/datum/entity/weapon_stats/W = setup_weapon_stats(cause)
		W.total_kills +=1
		if(round_statistics)
			var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(cause)
			R.total_kills +=1
	recalculate_top_weapon()
	..()

/datum/entity/player_stats/human/count_xeno_kill(var/caste, var/cause, var/caste)
	if(!caste)
		return
	if(cause)
		var/datum/entity/weapon_stats/W = setup_weapon_stats(cause)
		W.total_kills +=1
		if(round_statistics)
			var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(cause)
			R.total_kills +=1
	recalculate_top_weapon()
	..()

//*****************
//Mob Procs - minor
//*****************

/datum/entity/player_stats/human/count_personal_steps_walked(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.steps_walked += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.steps_walked += amount

/mob/living/carbon/human/track_steps_walked(var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/S = mind.setup_human_stats()
	S.steps_walked += amount
	if(job)
		S.count_personal_steps_walked(job, amount)

/datum/entity/player_stats/human/proc/count_weapon_shot(var/weapon, var/amount = 1)
	if(!weapon)
		return
	var/datum/entity/weapon_stats/S = setup_weapon_stats(weapon)
	S.total_shots += amount
	if(round_statistics)
		var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(weapon)
		R.total_shots +=amount

/datum/entity/player_stats/human/proc/count_personal_shot(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_shots += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_shots += amount

/mob/proc/track_shot(var/weapon, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.total_shots += amount
	human_stats.count_weapon_shot(weapon, amount)
	human_stats.count_personal_shot(job, amount)

/datum/entity/player_stats/human/proc/count_weapon_shot_hit(var/weapon, var/amount = 1)
	if(!weapon)
		return
	var/datum/entity/weapon_stats/S = setup_weapon_stats(weapon)
	S.total_shots_hit += amount
	if(round_statistics)
		var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(weapon)
		R.total_shots_hit += amount

/datum/entity/player_stats/human/proc/count_personal_shot_hit(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_shots_hit += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_shots_hit += amount

/mob/proc/track_shot_hit(var/weapon, var/shot_mob, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.total_shots_hit += amount
	human_stats.count_weapon_shot_hit(weapon, amount)
	human_stats.count_personal_shot_hit(job, amount)
	if(round_statistics)
		round_statistics.total_projectiles_hit += amount
		if(shot_mob)
			if(ishuman(shot_mob))
				round_statistics.total_projectiles_hit_human += amount
			else if(isXeno(shot_mob))
				round_statistics.total_projectiles_hit_xeno += amount

/datum/entity/player_stats/human/proc/count_weapon_friendly_fire(var/weapon, var/amount = 1)
	if(!weapon)
		return
	var/datum/entity/weapon_stats/S = setup_weapon_stats(weapon)
	S.total_friendly_fire += amount
	if(round_statistics)
		var/datum/entity/weapon_stats/R = round_statistics.setup_weapon_stats(weapon)
		R.total_friendly_fire += amount

/datum/entity/player_stats/human/proc/count_personal_friendly_fire(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_friendly_fire += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_friendly_fire += amount

/mob/proc/track_friendly_fire(var/weapon, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.total_friendly_fire += 1
	human_stats.count_weapon_friendly_fire(weapon, amount)
	human_stats.count_personal_friendly_fire(job, amount)

/datum/entity/player_stats/human/proc/count_personal_revive(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_revives += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_revives += amount

/mob/proc/track_revive(var/job, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.total_revives += amount
	human_stats.count_personal_revive(job, amount)

/datum/entity/player_stats/human/proc/count_personal_life_saved(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_lives_saved += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_lives_saved += amount

/mob/proc/track_life_saved(var/job, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.total_lives_saved += amount
	human_stats.count_personal_life_saved(job, amount)

/datum/entity/player_stats/human/proc/count_personal_scream(var/job, var/amount = 1)
	if(!job)
		return
	var/datum/entity/player_stats/job/S = setup_job_stats(job)
	S.total_screams += amount
	if(round_statistics)
		var/datum/entity/player_stats/job/R = round_statistics.setup_job_stats(job)
		R.total_screams += amount

/mob/proc/track_scream(var/job, var/amount = 1)
	if(statistic_exempt || !client || !ishuman(src))
		return
	var/datum/entity/player_stats/human/human_stats = mind.setup_human_stats()
	human_stats.total_screams += 1
	human_stats.count_personal_scream(job, amount)