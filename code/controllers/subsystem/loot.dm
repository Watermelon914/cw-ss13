
SUBSYSTEM_DEF(loot)
	name = "Loot"
	init_order	= SS_INIT_LOOT

	flags = SS_NO_FIRE

	var/list/drop_chances[RARITY_COUNT]

/datum/controller/subsystem/loot/Initialize()
	. = ..()
	reload_drop_chances()

/datum/controller/subsystem/loot/proc/reload_drop_chances()
	drop_chances[LOOT_COMMON] = CONFIG_GET(number/loot_common_chance)
	drop_chances[LOOT_RARE] = CONFIG_GET(number/loot_rare_chance)
	drop_chances[LOOT_VERY_RARE] = CONFIG_GET(number/loot_very_rare_chance)
	drop_chances[LOOT_LEGENDARY] = CONFIG_GET(number/loot_legendary_chance)

/datum/controller/subsystem/loot/proc/generate_loot(var/datum/loot_table/loot)
	RETURN_TYPE(/datum/loot_entry)

	if(!loot.table)
		return

	var/chosen_rarity = LOOT_NONE
	for(var/index in 1 to length(loot.rarities))
		var/rarity = loot.rarities[index]
		var/probability = drop_chances[rarity]
		if(prob(probability))
			chosen_rarity = rarity
			break

	if(chosen_rarity == LOOT_NONE)
		return

	if(!loot.table[chosen_rarity])
		return

	return pick(loot.table[chosen_rarity])

