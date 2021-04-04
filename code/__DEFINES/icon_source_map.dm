GLOBAL_LIST_INIT(icon_source_files, list(
	"icons/mob/hostiles/larva.dmi" = 'icons/mob/hostiles/larva.dmi',
	"icons/mob/hostiles/boiler.dmi" = 'icons/mob/hostiles/boiler.dmi',
	"icons/mob/hostiles/burrower.dmi" = 'icons/mob/hostiles/burrower.dmi',
	"icons/mob/hostiles/carrier.dmi" = 'icons/mob/hostiles/carrier.dmi',
	"icons/mob/hostiles/crusher.dmi" = 'icons/mob/hostiles/crusher.dmi',
	"icons/mob/hostiles/defender.dmi" = 'icons/mob/hostiles/defender.dmi',
	"icons/mob/hostiles/drone.dmi" = 'icons/mob/hostiles/drone.dmi',
	"icons/mob/hostiles/hivelord.dmi" = 'icons/mob/hostiles/hivelord.dmi',
	"icons/mob/hostiles/lurker.dmi" = 'icons/mob/hostiles/lurker.dmi',
	"icons/mob/hostiles/praetorian.dmi" = 'icons/mob/hostiles/praetorian.dmi',
	"icons/mob/hostiles/queen.dmi" = 'icons/mob/hostiles/queen.dmi',
	"icons/mob/hostiles/Ovipositor.dmi" = 'icons/mob/hostiles/Ovipositor.dmi',
	"icons/mob/hostiles/ravager.dmi" = 'icons/mob/hostiles/ravager.dmi',
	"icons/mob/hostiles/runner.dmi" = 'icons/mob/hostiles/runner.dmi',
	"icons/mob/hostiles/sentinel.dmi" = 'icons/mob/hostiles/sentinel.dmi',
	"icons/mob/hostiles/spitter.dmi" = 'icons/mob/hostiles/spitter.dmi',
	"icons/mob/hostiles/warrior.dmi" = 'icons/mob/hostiles/warrior.dmi',
	"icons/mob/hostiles/structures.dmi" = 'icons/mob/hostiles/structures.dmi',
	"icons/mob/hostiles/structures64x64.dmi" = 'icons/mob/hostiles/structures64x64.dmi',
	"icons/mob/hostiles/structures48x48.dmi" = 'icons/mob/hostiles/structures48x48.dmi',
	"icons/mob/hostiles/overlay_effects64x64.dmi" = 'icons/mob/hostiles/overlay_effects64x64.dmi',
	"icons/mob/hostiles/Effects.dmi" = 'icons/mob/hostiles/Effects.dmi',
	"icons/mob/hostiles/weeds.dmi" = 'icons/mob/hostiles/weeds.dmi',
))

GLOBAL_LIST_INIT(xeno_icons_by_caste, init_xeno_icons())

/proc/init_xeno_icons()
	. = list()
	for(var/i in subtypesof(/datum/config_entry/string/alien))
		var/datum/config_entry/string/alien/A = i
		if(!initial(A.associated_caste_type))
			stack_trace("Invalid associated_caste_type variable from type '[i]'!")
			continue
		// Need to use global.config.Get because GET_CONFIG will auto-fill out the type
		// with /datum/config_entry, which we don't want
		.[initial(A.associated_caste_type)] = get_icon_from_source(global.config.Get(i))

/proc/get_icon_from_source(source_name)
	if(!source_name)
		return

	if(GLOB.icon_source_files[source_name])
		return GLOB.icon_source_files[source_name]
	GLOB.icon_source_files[source_name] = file(source_name)
	return GLOB.icon_source_files[source_name]
