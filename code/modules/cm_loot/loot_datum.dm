/datum/loot_table
	/// The list of rarities that this loot table includes. Used for probability calculations.
	/// The order in which the probabilities are checked depend on the order of the rarities.
	var/list/rarities = list(
		LOOT_LEGENDARY,
		LOOT_VERY_RARE,
		LOOT_RARE,
		LOOT_COMMON
	)
	var/list/datum/loot_entry/table

/datum/loot_table/New()
	. = ..()
	var/highest_value = 0
	for(var/i in rarities)
		if(i > highest_value)
			highest_value = i

	table = new(highest_value)
	for(var/i in rarities)
		table[i] = list()

/datum/loot_entry
	var/name
	var/abstract_type = /datum/loot_entry
	var/rarity = LOOT_COMMON

/// Returns the item to spawn, whilst also spawning at the desired spawn location. Can return null.
/datum/loot_entry/proc/spawn_item(var/atom/spawn_location)
	return

