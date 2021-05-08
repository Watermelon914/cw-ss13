GLOBAL_DATUM_INIT(loot_yautja, /datum/loot_table/yautja, new())

/obj/structure/closet/crate/loot/yautja
	name = "Predator crate"
	icon_state = "pred_coffin"
	icon_closed = "pred_coffin"
	icon_opened = "pred_coffin_open"

/obj/structure/closet/crate/loot/yautja/Initialize()
	. = ..()
	possible_items = GLOB.loot_yautja

/datum/loot_table/yautja/New()
	. = ..()
	for(var/i in subtypesof(/datum/loot_entry/yautja))
		var/datum/loot_entry/yautja/W = i
		if(initial(W.abstract_type) == i)
			continue

		if(!(initial(W.rarity) in rarities))
			stack_trace("Invalid rarity value from [W]. Rarity not found in rarities variable.")
			continue

		table[initial(W.rarity)] += new W()

/datum/loot_entry/yautja
	name = "yautja item"
	var/item_to_spawn

/datum/loot_entry/yautja/spawn_item(var/atom/spawn_location)
	if(!item_to_spawn)
		return
	new item_to_spawn(spawn_location)

/datum/loot_entry/yautja/multiple
	name = "multiple items"
	abstract_type = /datum/loot_entry/yautja/multiple

/datum/loot_entry/yautja/multiple/spawn_item(atom/spawn_location)
	if(!item_to_spawn)
		return
	for(var/i in item_to_spawn)
		new i(spawn_location)



/*
  ARMOR
*/

/datum/loot_entry/yautja/multiple/yautja_set
	name = "Predator Set"
	item_to_spawn = list(
		/obj/item/clothing/suit/armor/yautja,
		/obj/item/clothing/shoes/yautja,
		/obj/item/clothing/under/chainshirt,
		/obj/item/clothing/mask/gas/yautja,
		/obj/item/weapon/melee/combistick
	)
	rarity = LOOT_LEGENDARY

/datum/loot_entry/yautja/yautja_shoes
	name = "Predator Greaves"
	item_to_spawn = /obj/item/clothing/shoes/yautja
	rarity = LOOT_VERY_RARE

/datum/loot_entry/yautja/yautja_mask
	name = "Predator Mask"
	item_to_spawn = /obj/item/clothing/mask/gas/yautja
	rarity = LOOT_RARE

/datum/loot_entry/yautja/yautja_armor
	name = "Predator Armor"
	item_to_spawn = /obj/item/clothing/suit/armor/yautja
	rarity = LOOT_COMMON

/*
  WEAPONS
*/

/datum/loot_entry/yautja/yautja_glaive
	name = "Predator Glaive"
	item_to_spawn = /obj/item/weapon/melee/twohanded/glaive
	rarity = LOOT_LEGENDARY

/datum/loot_entry/yautja/yautja_rifle
	name = "Predator Plasma Rifle"
	item_to_spawn = /obj/item/weapon/gun/energy/plasmarifle
	rarity = LOOT_LEGENDARY

/datum/loot_entry/yautja/yautja_pistol
	name = "Predator Plasma Pistol"
	item_to_spawn = /obj/item/weapon/gun/energy/plasmapistol
	rarity = LOOT_VERY_RARE

/datum/loot_entry/yautja/yautja_spike
	name = "Predator Spike Launcher"
	item_to_spawn = /obj/item/weapon/gun/launcher/spike
	rarity = LOOT_VERY_RARE

/datum/loot_entry/yautja/yautja_scythe
	name = "Predator Scythe"
	item_to_spawn = /obj/item/weapon/melee/yautja_scythe
	rarity = LOOT_VERY_RARE

/datum/loot_entry/yautja/yautja_sword
	name = "Predator Sword"
	item_to_spawn = /obj/item/weapon/melee/yautja_sword
	rarity = LOOT_RARE

/datum/loot_entry/yautja/yautja_whip
	name = "Predator Chain-Whip"
	item_to_spawn = /obj/item/weapon/yautja_chain
	rarity = LOOT_COMMON



