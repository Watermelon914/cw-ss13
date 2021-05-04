
GLOBAL_DATUM_INIT(loot_medical, /datum/loot_table/medical, new())

/obj/structure/closet/crate/loot/medical
	name = "medical crate"
	icon_state = "secure_locked_surgery"
	icon_closed = "secure_locked_surgery"
	icon_opened = "secure_open_surgery"

/obj/structure/closet/crate/loot/medical/Initialize()
	. = ..()
	possible_items = GLOB.loot_medical

/datum/loot_table/medical
	rarities = list(
		LOOT_VERY_RARE,
		LOOT_COMMON
	)

/datum/loot_table/medical/New()
	. = ..()
	for(var/i in subtypesof(/datum/loot_entry/medical))
		var/datum/loot_entry/medical/W = i
		if(initial(W.abstract_type) == i)
			continue

		if(!(initial(W.rarity) in rarities))
			stack_trace("Invalid rarity value from [W]. Rarity not found in rarities variable.")
			continue

		table[initial(W.rarity)] += new W()

/datum/loot_entry/medical
	name = "ammo item"
	var/item_to_spawn

/datum/loot_entry/medical/spawn_item(var/atom/spawn_location)
	if(!item_to_spawn)
		return
	new item_to_spawn(spawn_location)

/*
  MEDICAL KITS
*/

/datum/loot_entry/medical/strong_kits
	name = "Upgraded Medical Kit"
	item_to_spawn = /obj/item/storage/box/medic_upgraded_kits
	rarity = LOOT_VERY_RARE

/datum/loot_entry/object/normal_kits
	name = "Medical Kit"
	item_to_spawn = /obj/item/storage/firstaid/adv
	rarity = LOOT_COMMON
