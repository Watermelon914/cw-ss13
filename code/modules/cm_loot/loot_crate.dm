/obj/structure/closet/crate/loot
	name = "debug loot crate"
	icon_state = "secure_locked_weapons"
	icon_opened = "secure_open_weapons"
	icon_closed = "secure_locked_weapons"
	wrenchable = FALSE
	anchored = TRUE

	/// Loot table used to determine what a box can give depending on what the dice roll comes out on.
	var/datum/loot_table/possible_items

// Can't close loot crates, they stay open once open.
/obj/structure/closet/crate/loot/can_close()
	return FALSE

/obj/structure/closet/crate/loot/open()
	if(!possible_items)
		return

	. = ..()
	if(!.)
		return

	var/datum/loot_entry/item = SSloot.generate_loot(possible_items)
	if(!item)
		return

	item.spawn_item(get_turf(src))

/obj/structure/closet/crate/loot/Destroy()
	possible_items = null
	return ..()
