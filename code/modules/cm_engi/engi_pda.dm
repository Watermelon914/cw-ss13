/datum/pointshop_product/engineer
	name = "abstract engineer item"
	abstract_type = /datum/pointshop_product/engineer
	var/item_to_spawn

/datum/pointshop_product/engineer/purchase_product(mob/user)
	. = ..()
	if(!.)
		return

	if(!item_to_spawn)
		return FALSE

	var/atom/A = new item_to_spawn(get_turf(user))
	user.put_in_any_hand_if_possible(A)

/obj/item/device/pointshop/engi
	name = "engineering pda"
	desc = "An engineering PDA to quickly construct supplies"
	icon_state = "tracker"
	subtype_products = list(
		/datum/pointshop_product/engineer,
	)
	theme = "engi"
	currency = "scrap"

/obj/item/device/pointshop/engi/attack_self(mob/user)
	if(!skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_ENGI))
		to_chat(user, SPAN_WARNING("You don't know how to use [src]!"))
		return
	return ..()
