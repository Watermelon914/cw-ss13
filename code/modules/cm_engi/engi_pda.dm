/obj/item/device/pointshop/engi
	name = "engineering pda"
	desc = "An engineering PDA to quickly construct supplies"
	icon_state = "tracker"
	// TODO: Add actual products for engi
	products = list(
		/datum/pointshop_product,
	)

/obj/item/device/pointshop/engi/attack_hand(mob/user)
	if(skillcheck(user, SKILL_ENGINEER, SKILL_ENGINEER_ENGI))
		to_chat(user, SPAN_WARNING("You don't know how to use [src]!"))
		return
	return ..()
