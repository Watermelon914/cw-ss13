GLOBAL_LIST_EMPTY(processing_music_clients)

SUBSYSTEM_DEF(music)
	name          = "Music"
	wait          = 2 SECONDS
	priority      = SS_PRIORITY_MUSIC
	flags		  = SS_NO_INIT

	var/list/currentrun = list()

/datum/controller/subsystem/music/fire(resumed = FALSE)
	if (!resumed)
		currentrun = GLOB.processing_music_clients.Copy()

	while(length(currentrun))
		var/client/C = currentrun[length(currentrun)]
		currentrun.len--

		if(!C.queued_music || C.prefs?.music_volume == 0)
			if(C.current_music)
				sound_to(C, C.current_music)
				C.current_music = null
			GLOB.processing_music_clients -= C
			continue

		if(C.current_music)
			if(C.queued_music == C.current_music_file)

				continue
			else
				sound_to(C, C.current_music)

		var/sound/S = sound(C.queued_music, TRUE, FALSE, SOUND_CHANNEL_MUSIC, C.prefs.music_volume)
		C.current_music = S
		C.current_music_file = C.queued_music
		S.status = SOUND_STREAM
		sound_to(C, S)
		S.status |= SOUND_UPDATE
		S.repeat = FALSE

		if(MC_TICK_CHECK)
			return
