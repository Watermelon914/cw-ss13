/mob/living/carbon/Xenomorph/ex_act(var/severity, var/direction, var/source, var/source_mob, pierce=0)

	if(lying)
		severity *= EXPLOSION_PRONE_MULTIPLIER

	if(severity >= 30)
		flash_eyes()

	if(severity > EXPLOSION_THRESHOLD_LOW && stomach_contents.len)
		for(var/mob/M in stomach_contents)
			M.ex_act(severity - EXPLOSION_THRESHOLD_LOW, source, source_mob, pierce)

	var/b_loss = 0
	var/f_loss = 0

	var/damage = severity

	var/cfg = mob_size < MOB_SIZE_BIG? GLOB.xeno_explosive_small : GLOB.xeno_explosive
	var/total_explosive_resistance = caste != null ? caste.xeno_explosion_resistance + armor_explosive_buff : armor_explosive_buff
	damage = armor_damage_reduction(cfg, damage, total_explosive_resistance, pierce, 1, 0.5)

	if(source)
		last_damage_source = source
	if(source_mob)
		last_damage_mob = source_mob

	last_hit_time = world.time

	if (damage >= health && damage >= EXPLOSION_THRESHOLD_GIB)
		var/oldloc = loc
		gib(source)
		create_shrapnel(oldloc, rand(16, 24), , , /datum/ammo/bullet/shrapnel/light/xeno, source, source_mob)
		return
	if (damage >= 0)
		b_loss += damage * 0.5
		f_loss += damage * 0.5
		apply_damage(b_loss, BRUTE)
		apply_damage(f_loss, BURN)
		updatehealth()

		var/powerfactor_value = round( damage * 0.05 ,1)
		powerfactor_value = min(powerfactor_value,20)
		if(powerfactor_value > 0 && small_explosives_stun)
			KnockOut(powerfactor_value/5)
			if(mob_size < MOB_SIZE_BIG)
				Slow(powerfactor_value)
				Superslow(powerfactor_value/2)
			else
				Slow(powerfactor_value/3)
			explosion_throw(severity, direction)
		else if(powerfactor_value > 10)
			powerfactor_value /= 5
			KnockOut(powerfactor_value/5)
			if(mob_size < MOB_SIZE_BIG)
				Slow(powerfactor_value)
				Superslow(powerfactor_value/2)
			else
				Slow(powerfactor_value/3)

/mob/living/carbon/Xenomorph/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, used_weapon = null, sharp = 0, edge = 0, force = FALSE)
	if(!damage)
		return


	var/list/damagedata = list("damage" = damage)
	if(SEND_SIGNAL(src, COMSIG_XENO_TAKE_DAMAGE, damagedata, damagetype) & COMPONENT_BLOCK_DAMAGE) return
	damage = damagedata["damage"]

	//We still want to check for blood splash before we get to the damage application.
	var/chancemod = 0
	if(used_weapon && sharp)
		chancemod += 10
	if(used_weapon && edge) //Pierce weapons give the most bonus
		chancemod += 12
	if(def_zone != "chest") //Which it generally will be, vs xenos
		chancemod += 5

	if(damage > 12) //Light damage won't splash.
		check_blood_splash(damage, damagetype, chancemod)

	if(damage > 0 && stat == DEAD)
		return

	var/shielded = FALSE
	if(xeno_shields.len != 0 && damage > 0)
		shielded = TRUE
		for(var/datum/xeno_shield/XS in xeno_shields)
			damage = XS.on_hit(damage)

			if(damage > 0)
				XS.on_removal()
				QDEL_NULL(XS)

			if(damage == 0)
				return

		overlay_shields()

	if(shielded) // We were shielded, but damage went through.
		playsound(src, "shield_shatter", 50, 1)

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)

	updatehealth()
	handle_regular_status_updates(FALSE)

	last_hit_time = world.time

	return 1

/mob/living/carbon/Xenomorph/proc/check_blood_splash(damage = 0, damtype = BRUTE, chancemod = 0, radius = 1)
	if(!damage || world.time < acid_splash_last + acid_splash_cooldown || (SSticker?.mode?.flags_round_type & MODE_DISABLE_ACID_BLOOD))
		return FALSE
	var/chance = 20 //base chance
	if(damtype == BRUTE) chance += 5
	chance += chancemod + (damage * 0.33)
	var/turf/T = loc
	if(!T || !istype(T))
		return

	if(radius > 1 || prob(chance))
		var/decal_chance = 50
		if(prob(decal_chance))
			var/obj/effect/decal/cleanable/blood/xeno/decal = locate(/obj/effect/decal/cleanable/blood/xeno) in T
			if(!decal) //Let's not stack blood, it just makes lagggggs.
				add_splatter_floor(T) //Drop some on the ground first.
			else
				if(decal.random_icon_states && length(decal.random_icon_states) > 0) //If there's already one, just randomize it so it changes.
					decal.icon_state = pick(decal.random_icon_states)

		var/splash_chance = 40 //Base chance of getting splashed. Decreases with # of victims.
		var/distance = 0 //Distance, decreases splash chance.
		var/i = 0 //Tally up our victims.

		for(var/mob/living/carbon/human/victim in orange(radius,src)) //Loop through all nearby victims, including the tile.
			distance = get_dist(src,victim)

			splash_chance = 80 - (i * 5)
			if(victim.loc == loc) splash_chance += 30 //Same tile? BURN
			splash_chance += distance * -15
			if(victim.species && victim.species.name == "Yautja")
				splash_chance -= 70 //Preds know to avoid the splashback.

			if(splash_chance > 0 && prob(splash_chance)) //Success!
				var/dmg = list("damage" = acid_blood_damage)
				if(SEND_SIGNAL(src, COMSIG_XENO_DEAL_ACID_DAMAGE, victim, dmg) & COMPONENT_BLOCK_DAMAGE)
					continue
				i++
				victim.visible_message(SPAN_DANGER("\The [victim] is scalded with hissing green blood!"), \
				SPAN_DANGER("You are splattered with sizzling blood! IT BURNS!"))
				if(prob(60) && !victim.stat && pain.feels_pain)
					INVOKE_ASYNC(victim, /mob.proc/emote, "scream") //Topkek
				victim.take_limb_damage(0, dmg["damage"]) //Sizzledam! This automagically burns a random existing body part.
				victim.add_blood(get_blood_color(), BLOOD_BODY)
				acid_splash_last = world.time
