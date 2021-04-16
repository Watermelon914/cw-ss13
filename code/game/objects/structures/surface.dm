//Surface structures are structures that can have items placed on them
/obj/structure/surface
	health = 100
	wrenchable = FALSE

/obj/structure/surface/Destroy()
	. = ..()

/obj/structure/surface/ex_act(severity, direction)
	health -= severity
	if(health <= 0)
		var/location = get_turf(src)
		handle_debris(severity, direction)
		qdel(src)
		if(prob(66))
			create_shrapnel(location, rand(1,4), direction, , /datum/ammo/bullet/shrapnel/light)
		return TRUE

/obj/structure/surface/attackby(obj/item/W, mob/user, click_data)
	// Placing stuff on tables
	if(user.a_intent != INTENT_HARM && user.drop_inv_item_to_loc(W, loc))
		auto_align(W, click_data)
		return TRUE
	return ..()

/obj/structure/surface/proc/auto_align(obj/item/W, click_data)
	if(!W.center_of_mass) // Clothing, material stacks, generally items with large sprites where exact placement would be unhandy.
		W.pixel_x = rand(-W.randpixel, W.randpixel)
		W.pixel_y = rand(-W.randpixel, W.randpixel)
		W.pixel_z = 0
		return

	if(!click_data)
		return

	if(!click_data["icon-x"] || !click_data["icon-y"])
		return

	// Calculation to apply new pixelshift.
	var/mouse_x = text2num(click_data["icon-x"])-1 // Ranging from 0 to 31
	var/mouse_y = text2num(click_data["icon-y"])-1

	var/cell_x = Clamp(round(mouse_x/CELLSIZE), 0, CELLS-1) // Ranging from 0 to CELLS-1
	var/cell_y = Clamp(round(mouse_y/CELLSIZE), 0, CELLS-1)

	var/list/center = cached_key_number_decode(W.center_of_mass)

	W.pixel_x = (CELLSIZE * (cell_x + 0.5)) - center["x"]
	W.pixel_y = (CELLSIZE * (cell_y + 0.5)) - center["y"]
	W.pixel_z = 0
