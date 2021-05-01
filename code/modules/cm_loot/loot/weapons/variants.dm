
GLOBAL_DATUM_INIT(loot_variants, /datum/loot_table/variants, new())


/datum/loot_table/variants
	rarities = list(
		LOOT_LEGENDARY,
		LOOT_VERY_RARE,
		LOOT_RARE,
		LOOT_COMMON
	)

/datum/loot_table/variants/New()
	. = ..()
	for(var/i in subtypesof(/datum/loot_entry/variant))
		var/datum/loot_entry/variant/W = i
		if(initial(W.abstract_type) == i)
			continue

		if(!(initial(W.rarity) in rarities))
			stack_trace("Invalid rarity value from [W]. Rarity not found in rarities variable.")
			continue

		table[initial(W.rarity)] += new W()

/datum/loot_entry/variant
	name = "weapon variant"
	var/damage_mult = 0
	var/accuracy_mult = 0
	var/movement_acc_penalty_mult = 0
	var/scatter = 0
	var/firerate = 0
	var/recoil = 0
	var/aim_slowdown = 0
	var/burst = 0
	var/burst_delay = 0
	var/burst_scatter_mult = 0

/datum/loot_entry/variant/proc/register_weapon(var/obj/item/weapon/gun/G)
	RegisterSignal(G, COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES, .proc/apply_to_weapon)
	apply_to_weapon(G)
	G.name = "[name] [G.name]"

/datum/loot_entry/variant/proc/apply_to_weapon(var/obj/item/weapon/gun/G)
	SIGNAL_HANDLER
	G.damage_mult = max(0, G.damage_mult + damage_mult)
	G.accuracy_mult = max(0, G.accuracy_mult + accuracy_mult)
	G.scatter = max(0, G.scatter + scatter)
	G.fire_delay = max(1, G.fire_delay - firerate)
	G.recoil = max(0, G.recoil + recoil)
	G.aim_slowdown = max(0, G.aim_slowdown + aim_slowdown)
	G.movement_acc_penalty_mult = max(0, G.movement_acc_penalty_mult + movement_acc_penalty_mult)
	G.burst_amount = max(0, G.burst_amount + burst)
	G.burst_delay = max(1, G.burst_delay + burst_delay)
	G.burst_scatter_mult = max(0, G.burst_scatter_mult + burst_scatter_mult)

/*
	LEGENDARY VARIANTS
*/
/datum/loot_entry/variant/divine
	name = "divine"
	damage_mult = 0.35
	firerate = 2
	recoil = -4
	scatter = -5
	burst_scatter_mult = -5
	aim_slowdown = -1.2
	rarity = LOOT_LEGENDARY

	var/glow_max_alpha = 100
	var/glow_min_alpha = 40
	var/divine_color = "#e6b31900"

/datum/loot_entry/variant/divine/register_weapon(obj/item/weapon/gun/G)
	. = ..()
	G.add_filter("divine_glow", 1, list("type" = "outline", "color" = divine_color, "size" = 1))
	var/filter = G.get_filter("divine_glow")
	animate(filter, alpha = glow_max_alpha, time = 1 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
	animate(alpha = glow_min_alpha, time = 1 SECONDS)

/datum/loot_entry/variant/ruthless
	name = "ruthless"
	damage_mult = 0.75
	firerate = -1
	recoil = 1
	aim_slowdown = 0.25

	rarity = LOOT_LEGENDARY

	var/glow_max_alpha = 100
	var/glow_min_alpha = 40
	var/ruthless_color = "#ff000000"

/datum/loot_entry/variant/ruthless/register_weapon(var/obj/item/weapon/gun/G)
	. = ..()
	G.add_filter("ruthless_glow", 1, list("type" = "outline", "color" = ruthless_color, "size" = 1))
	var/filter = G.get_filter("ruthless_glow")
	animate(filter, alpha = glow_max_alpha, time = 1 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
	animate(alpha = glow_min_alpha, time = 1 SECONDS)


/*
	VERY RARE VARIANTS
*/

/datum/loot_entry/variant/ultra
	name = "ultra"
	damage_mult = 0.2
	firerate = 2
	recoil = -2
	scatter = -2
	rarity = LOOT_VERY_RARE


/*
	RARE VARIANTS
*/

/datum/loot_entry/variant/alpha
	name = "alpha"
	damage_mult = 0.15
	firerate = 1
	recoil = -1
	rarity = LOOT_RARE

/*
	COMMON VARIANTS
*/

/datum/loot_entry/variant/lightweight
	name = "lightweight"
	aim_slowdown = -1.2

/datum/loot_entry/variant/hyperburst
	name = "hyperburst"
	burst = 3
	var/max_burst = 8
	damage_mult = 0.25
	firerate = -3
	burst_delay = -1
	recoil = -1

/datum/loot_entry/variant/hyperburst/apply_to_weapon(obj/item/weapon/gun/G)
	. = ..()
	G.burst_amount = min(G.burst_amount, max_burst)

/datum/loot_entry/variant/stabilized
	name = "stabilized"
	movement_acc_penalty_mult = -3
	scatter = 1
	rarity = LOOT_COMMON

/datum/loot_entry/variant/none
	name = ""
	rarity = LOOT_COMMON

/datum/loot_entry/variant/none/register_weapon(obj/item/weapon/gun/G)
	return
