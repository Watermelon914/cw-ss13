/datum/config_entry/string/lobby_art
	config_entry_value = "icons/lobby/title.dmi"

/datum/config_entry/string/alien
	abstract_type = /datum/config_entry/string/alien
	var/associated_caste_type

/datum/config_entry/string/alien/New()
	. = ..()
	GLOB.xeno_icons_by_caste[associated_caste_type] = get_icon_from_source(config_entry_value)

/datum/config_entry/string/alien/ValidateAndSet(str_val)
	. = ..()
	if(!.)
		return
	GLOB.xeno_icons_by_caste[associated_caste_type] = get_icon_from_source(config_entry_value)

/datum/config_entry/string/alien/alien_embryo
	config_entry_value = "icons/mob/hostiles/larva.dmi"
	associated_caste_type = XENO_CASTE_LARVA

/datum/config_entry/string/alien/alien_hunter_embryo
	config_entry_value = "icons/mob/xenos_old/1x1_Xenos.dmi"
	associated_caste_type = XENO_CASTE_PREDALIEN_LARVA

/datum/config_entry/string/alien/alien_boiler
	config_entry_value = "icons/mob/hostiles/boiler.dmi"
	associated_caste_type = XENO_CASTE_BOILER

/datum/config_entry/string/alien/alien_burrower
	config_entry_value = "icons/mob/hostiles/burrower.dmi"
	associated_caste_type = XENO_CASTE_BURROWER

/datum/config_entry/string/alien/alien_carrier
	config_entry_value = "icons/mob/hostiles/carrier.dmi"
	associated_caste_type = XENO_CASTE_CARRIER

/datum/config_entry/string/alien/alien_crusher
	config_entry_value = "icons/mob/hostiles/crusher.dmi"
	associated_caste_type = XENO_CASTE_CRUSHER

/datum/config_entry/string/alien/alien_defender
	config_entry_value = "icons/mob/hostiles/defender.dmi"
	associated_caste_type = XENO_CASTE_DEFENDER

/datum/config_entry/string/alien/alien_drone
	config_entry_value = "icons/mob/hostiles/drone.dmi"
	associated_caste_type = XENO_CASTE_DRONE

/datum/config_entry/string/alien/alien_hivelord
	config_entry_value = "icons/mob/hostiles/hivelord.dmi"
	associated_caste_type = XENO_CASTE_HIVELORD

/datum/config_entry/string/alien/alien_lurker
	config_entry_value = "icons/mob/hostiles/lurker.dmi"
	associated_caste_type = XENO_CASTE_LURKER

/datum/config_entry/string/alien/alien_praetorian
	config_entry_value = "icons/mob/hostiles/praetorian.dmi"
	associated_caste_type = XENO_CASTE_PRAETORIAN

/datum/config_entry/string/alien/alien_predalien
	config_entry_value = "icons/mob/hostiles/predalien.dmi"
	associated_caste_type = XENO_CASTE_PREDALIEN

/datum/config_entry/string/alien/alien_queen_standing
	config_entry_value = "icons/mob/hostiles/queen.dmi"
	associated_caste_type = XENO_CASTE_QUEEN

/datum/config_entry/string/alien_queen_ovipositor
	config_entry_value = "icons/mob/hostiles/Ovipositor.dmi"

/datum/config_entry/string/alien/alien_ravager
	config_entry_value = "icons/mob/hostiles/ravager.dmi"
	associated_caste_type = XENO_CASTE_RAVAGER

/datum/config_entry/string/alien/alien_runner
	config_entry_value = "icons/mob/hostiles/runner.dmi"
	associated_caste_type = XENO_CASTE_RUNNER

/datum/config_entry/string/alien/alien_sentinel
	config_entry_value = "icons/mob/hostiles/sentinel.dmi"
	associated_caste_type = XENO_CASTE_SENTINEL

/datum/config_entry/string/alien/alien_spitter
	config_entry_value = "icons/mob/hostiles/spitter.dmi"
	associated_caste_type = XENO_CASTE_SPITTER

/datum/config_entry/string/alien/alien_warrior
	config_entry_value = "icons/mob/hostiles/warrior.dmi"
	associated_caste_type = XENO_CASTE_WARRIOR

/datum/config_entry/string/alien_structures
	config_entry_value = "icons/mob/hostiles/structures.dmi"

/datum/config_entry/string/alien_structures_64x64
	config_entry_value = "icons/mob/hostiles/structures64x64.dmi"

/datum/config_entry/string/alien_structures_48x48
	config_entry_value = "icons/mob/hostiles/structures48x48.dmi"

/datum/config_entry/string/alien_overlay_64x64
	config_entry_value = "icons/mob/hostiles/overlay_effects64x64.dmi"

/datum/config_entry/string/alien_effects
	config_entry_value = "icons/mob/hostiles/Effects.dmi"

/datum/config_entry/string/alien_weeds
	config_entry_value = "icons/mob/hostiles/weeds.dmi"
/datum/config_entry/string/alien_gib_48x48
	config_entry_value = "icons/mob/xenos_old/xenomorph_48x48.dmi"

/datum/config_entry/string/alien_gib_64x64
	config_entry_value = "icons/mob/xenos_old/xenomorph_64x64.dmi"

/datum/config_entry/string/species_hunter
	config_entry_value = "icons/mob/humans/species/r_predator.dmi"
