/datum/pointshop_product/supply_drop/weapon_crate
	name = "Weapon crate"
	desc = "Sends down a supply drop containing a random weapon item from the item crate. Contains 1 weapon."
	icon_state = "secure_locked_weapons"
	cost = 15
	var/cost_increment = 15

/datum/pointshop_product/supply_drop/weapon_crate/launch(turf/T)
	. = ..()
	cost += cost_increment


/datum/pointshop_product/supply_drop/weapon_crate/load_droppod(var/obj/structure/droppod/container/C)
	var/datum/loot_entry/item = SSloot.generate_loot(GLOB.loot_weapons)
	if(!item)
		return
	item.spawn_item(C)
