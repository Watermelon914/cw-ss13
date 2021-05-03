/datum/pointshop_product/supply_drop/ammo_crate
	name = "Ammo crate"
	desc = "Sends down a supply drop containing a random ammo kit from the ammo crate."
	cost = 15

/datum/pointshop_product/supply_drop/ammo_crate/purchase_product(var/datum/pointshop/P, var/mob/user)
	. = ..()
	if(!.)
		return

