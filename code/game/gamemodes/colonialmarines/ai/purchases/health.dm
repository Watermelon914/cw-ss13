/datum/pointshop_product/supply_drop/medical_crate
	name = "Health crate"
	desc = "Sends down a supply drop containing a random medical item from the medical crate. Contains 1 item."
	icon_state = "secure_locked_surgery"
	cost = 10

/datum/pointshop_product/supply_drop/medical_crate/load_droppod(var/obj/structure/droppod/container/C)
	var/datum/loot_entry/item = SSloot.generate_loot(GLOB.loot_medical)
	if(!item)
		return
	item.spawn_item(C)
