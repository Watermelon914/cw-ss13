/datum/pointshop_product/supply_drop/ammo_crate
	name = "Ammo crate"
	desc = "Sends down a supply drop containing a random ammo kit from the ammo crate."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "closed_ammo"
	cost = 15
	var/max_amount = 2

/datum/pointshop_product/supply_drop/ammo_crate/load_droppod(var/obj/structure/droppod/container/C)
	var/datum/loot_entry/item = SSloot.generate_loot(GLOB.loot_ammo)
	if(!item)
		return
	for(var/i in 1 to rand(1, max_amount))
		item.spawn_item(C)
