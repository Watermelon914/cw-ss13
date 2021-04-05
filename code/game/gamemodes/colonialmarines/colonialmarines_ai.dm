/datum/game_mode/colonialmarines/ai
	name = "Distress Signal: Lowpop"
	config_tag = "Distress Signal: Lowpop"
	required_players = 1 //Need at least one player, but really we need 2.

/datum/game_mode/colonialmarines/ai/pre_setup()
	RegisterSignal(SSdcs, COMSIG_GLOB_XENO_SPAWN, .proc/handle_xeno_spawn)
	. = ..()

/datum/game_mode/colonialmarines/ai/proc/handle_xeno_spawn(var/datum/source, var/mob/living/carbon/Xenomorph/X)
	SIGNAL_HANDLER
	X.make_ai()

// Temporary fix for now, proper win conditions can be set later.
/datum/game_mode/colonialmarines/ai/check_win()
	return FALSE
