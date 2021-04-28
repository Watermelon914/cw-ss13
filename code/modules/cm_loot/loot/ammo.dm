
GLOBAL_DATUM_INIT(loot_ammo, /datum/loot_table/ammo, new())

/obj/structure/closet/crate/loot/ammo
	name = "ammo crate"
	icon_state = "secure_locked_ammo"
	icon_closed = "secure_locked_ammo"
	icon_opened = "secure_open_ammo"

/obj/structure/closet/crate/loot/ammo/Initialize()
	. = ..()
	possible_items = GLOB.loot_ammo

/datum/loot_table/ammo
	rarities = list(
		LOOT_RARE,
		LOOT_COMMON
	)

/datum/loot_table/ammo/New()
	. = ..()
	for(var/i in subtypesof(/datum/loot_entry/ammo))
		var/datum/loot_entry/ammo/W = i
		if(initial(W.abstract_type) == i)
			continue

		if(!(initial(W.rarity) in rarities))
			stack_trace("Invalid rarity value from [W]. Rarity not found in rarities variable.")
			continue

		table[initial(W.rarity)] += new W()

/datum/loot_entry/ammo
	name = "ammo item"
	var/item_to_spawn

/datum/loot_entry/ammo/spawn_item(var/atom/spawn_location)
	if(!item_to_spawn)
		return
	new item_to_spawn(spawn_location)

/*
  AMMO KITS
*/

/datum/loot_entry/ammo/ammo_default
	name = "Default Ammo Kit"
	item_to_spawn = /obj/item/ammo_kit/normal
	rarity = LOOT_COMMON

/datum/loot_entry/ammo/ammo_wp
	name = "Wall-piercing Ammo Kit"
	item_to_spawn = /obj/item/ammo_kit/penetrating
	rarity = LOOT_RARE

/datum/loot_entry/ammo/ammo_incend
	name = "Incendiary Ammo Kit"
	item_to_spawn = /obj/item/ammo_kit/incendiary
	rarity = LOOT_RARE

/datum/loot_entry/ammo/ammo_toxin
	name = "Toxin Ammo Kit"
	item_to_spawn = /obj/item/ammo_kit/toxin
	rarity = LOOT_RARE
