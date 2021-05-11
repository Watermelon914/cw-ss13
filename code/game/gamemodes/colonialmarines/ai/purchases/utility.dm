/datum/pointshop_product/supply_drop/utility_crate
	name = "Utility crate"
	desc = "Sends down a supply drop containing a random utility item from the item crate. Contains 1 item."
	icon_state = "closed_supply"
	cost = 15
	var/cost_increment = 15

/datum/pointshop_product/supply_drop/weapon_crate/launch(turf/T)
	. = ..()
	cost += cost_increment

/datum/pointshop_product/supply_drop/utility_crate/load_droppod(var/obj/structure/droppod/container/C)
	var/datum/loot_entry/item = SSloot.generate_loot(GLOB.loot_objects)
	if(!item)
		return
	item.spawn_item(C)
