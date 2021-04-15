GLOBAL_DATUM_INIT(loot_weapons, /datum/loot_table/weapons, new())

/obj/structure/closet/crate/loot/weapons
	name = "weapons crate"

/obj/structure/closet/crate/loot/weapons/Initialize()
	. = ..()
	possible_items = GLOB.loot_weapons

/datum/loot_table/weapons/New()
	. = ..()
	for(var/i in subtypesof(/datum/loot_entry/weapon))
		var/datum/loot_entry/weapon/W = i
		if(initial(W.abstract_type) == i)
			continue

		if(!(initial(W.rarity) in rarities))
			stack_trace("Invalid rarity value from [W]. Rarity not found in rarities variable.")
			continue

		table[initial(W.rarity)] += new W()

/datum/loot_entry/weapon
	name = "weapon item"
	var/item_to_spawn

/datum/loot_entry/weapon/spawn_item(var/atom/spawn_location)
	if(!item_to_spawn)
		return
	return new item_to_spawn(spawn_location)

/*
  SHOTGUN WEAPONS
  Ordered from Legendary items to Common items
*/

/datum/loot_entry/weapon/marsoc_shotgun
	name = "MARSOC Shotgun"
	item_to_spawn = /obj/item/weapon/gun/shotgun/combat/marsoc
	rarity = LOOT_LEGENDARY

/datum/loot_entry/weapon/combat_shotgun
	name = "MK221 Tactical Shotgun"
	item_to_spawn = /obj/item/weapon/gun/shotgun/combat
	rarity = LOOT_VERY_RARE

/datum/loot_entry/weapon/sawnoff_shotgun
	name = "Sawn-off Shotgun"
	item_to_spawn = /obj/item/weapon/gun/shotgun/double/sawn
	rarity = LOOT_RARE

/datum/loot_entry/weapon/double_barrel
	name = "Double-barrel Shotgun"
	item_to_spawn = /obj/item/weapon/gun/shotgun/double
	rarity = LOOT_COMMON

/datum/loot_entry/weapon/hg_shotgun
	name = "HG 37-12 Pump Shotgun"
	item_to_spawn = /obj/item/weapon/gun/shotgun/pump/cmb
	rarity = LOOT_COMMON

/*
  GENERAL WEAPONS
  Ordered from Legendary items to Common items
*/

/datum/loot_entry/weapon/m40_sd
	name = "M40-SD pulse rifle"
	item_to_spawn = /obj/item/weapon/gun/rifle/m41a/elite/m40_sd
	rarity = LOOT_VERY_RARE

/datum/loot_entry/weapon/m39_elite
	name = "M39B/2 submachinegun"
	item_to_spawn = /obj/item/weapon/gun/smg/m39/elite
	rarity = LOOT_VERY_RARE

/datum/loot_entry/weapon/m41a_elite
	name = "M41A/2 pulse rifle"
	item_to_spawn = /obj/item/weapon/gun/rifle/m41a/elite
	rarity = LOOT_RARE

/datum/loot_entry/weapon/fp9000
	name = "FP9000 submachinegun"
	item_to_spawn = /obj/item/weapon/gun/smg/fp9000
	rarity = LOOT_RARE

/datum/loot_entry/weapon/m46c
	name = "M46C pulse rifle"
	item_to_spawn = /obj/item/weapon/gun/rifle/m46c
	rarity = LOOT_COMMON

/datum/loot_entry/weapon/m4ra
	name = "M4RA battle rifle"
	item_to_spawn = /obj/item/weapon/gun/rifle/m4ra
	rarity = LOOT_COMMON

/*
  SPECIAL WEAPONS
  Ordered from Legendary items to Common items
*/

/datum/loot_entry/weapon/minigun
	name = "Minigun"
	item_to_spawn = /obj/item/weapon/gun/minigun
	rarity = LOOT_LEGENDARY

/datum/loot_entry/weapon/rpg
	name = "M5 RPG"
	item_to_spawn = /obj/item/weapon/gun/launcher/rocket
	rarity = LOOT_LEGENDARY

/datum/loot_entry/weapon/m60
	name = "M60 Machinegun"
	item_to_spawn = /obj/item/weapon/gun/m60
	rarity = LOOT_VERY_RARE

/datum/loot_entry/weapon/grenade_launcher
	name = "Grenade Launcher"
	item_to_spawn = /obj/item/weapon/gun/launcher/grenade/m92
	rarity = LOOT_RARE

#ifdef TESTING
/client/verb/do_loot_table_test(var/amount as num)
	set name = "Do Weapon Loot Table Test"
	set category = "Debug"

	var/legendary = 0
	var/very_rare = 0
	var/rare = 0
	var/common = 0
	for(var/i in 1 to amount)
		var/datum/loot_entry/L = SSloot.generate_loot(GLOB.loot_weapons)
		switch(L.rarity)
			if(LOOT_COMMON)
				common++
			if(LOOT_RARE)
				rare++
			if(LOOT_VERY_RARE)
				very_rare++
			if(LOOT_LEGENDARY)
				legendary++

	to_chat(usr, "Got [legendary] legendaries, [very_rare] very rares, [rare] rares, [common] commons.")

#endif

