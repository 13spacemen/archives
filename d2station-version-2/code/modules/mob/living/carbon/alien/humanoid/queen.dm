/mob/living/carbon/alien/humanoid/queen/New()
	spawn (1)
		src.verbs += /mob/living/carbon/alien/humanoid/proc/corrode_target
		src.verbs += /mob/living/carbon/alien/humanoid/sentinel/verb/spit
		src.verbs -= /mob/living/carbon/alien/humanoid/verb/ventcrawl
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		src.stand_icon = new /icon('alien.dmi', "queen_s")
		src.lying_icon = new /icon('alien.dmi', "queen_l")
		src.icon = src.stand_icon

//there should only be one queen
//		if(src.name == "alien") src.name = text("alien ([rand(1, 1000)])")
		src.real_name = src.name
		src << "\blue Your icons have been generated!"

		update_clothing()


/mob/living/carbon/alien/humanoid/queen

	updatehealth()
		if (src.nodamage == 0)
		//oxyloss is only used for suicide
		//toxloss isn't used for aliens, its actually used as alien powers!!
			src.health = 250 - src.oxyloss - src.fireloss - src.bruteloss
		else
			src.health = 250
			src.stat = 0

	handle_regular_hud_updates()

		if (src.stat == 2 || src.mutations & 4)
			src.sight |= SEE_TURFS
			src.sight |= SEE_MOBS
			src.sight |= SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = 2
		else if(src.reagents.has_reagent("psilocybin"))
			if (src.druggy > 30)
				src.see_invisible = 10
		else if (src.stat != 2)
			src.sight |= SEE_MOBS
			src.sight |= SEE_TURFS
			src.sight &= ~SEE_OBJS
			src.see_in_dark = 8
			src.see_invisible = 2

		if (src.sleep) src.sleep.icon_state = text("sleep[]", src.sleeping)
		if (src.rest) src.rest.icon_state = text("rest[]", src.resting)

		if (src.healths)
			if (src.stat != 2)
				switch(health)
					if(250 to INFINITY)
						src.healths.icon_state = "health0"
					if(175 to 250)
						src.healths.icon_state = "health1"
					if(100 to 175)
						src.healths.icon_state = "health2"
					if(50 to 100)
						src.healths.icon_state = "health3"
					if(0 to 50)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"

	handle_environment()

		//If there are alien weeds on the ground then heal if needed or give some toxins
		if(locate(/obj/alien/weeds) in loc)
			if(health >= 250)
				toxloss += 20
				if(toxloss > max_plasma)
					toxloss = max_plasma
			else
				bruteloss -= 5
				fireloss -= 5

	handle_regular_status_updates()

		health = 250 - (oxyloss + fireloss + bruteloss)

		if(oxyloss > 50) paralysis = max(paralysis, 3)

		if(src.sleeping)
			src.paralysis = max(src.paralysis, 3)
			if (prob(10) && health) spawn(0) emote("snore")
			src.sleeping--

		if(src.resting)
			src.weakened = max(src.weakened, 5)

		if(health < -100 || src.brain_op_stage == 4.0)
			death()
		else if(src.health < 0)
			if(src.health <= 20 && prob(1)) spawn(0) emote("gasp")

			//if(!src.rejuv) src.oxyloss++
			if(!src.reagents.has_reagent("inaprovaline")) src.oxyloss++

			if(src.stat != 2)	src.stat = 1
			src.paralysis = max(src.paralysis, 5)

		if (src.stat != 2) //Alive.

			if (src.paralysis || src.stunned || src.weakened) //Stunned etc.
				if (src.stunned > 0)
					src.stunned--
					src.stat = 0
				if (src.weakened > 0)
					src.weakened--
					src.lying = 1
					src.stat = 0
				if (src.paralysis > 0)
					src.paralysis--
					src.blinded = 1
					src.lying = 1
					src.stat = 1
				var/h = src.hand
				src.hand = 0
				drop_item()
				src.hand = 1
				drop_item()
				src.hand = h

			else	//Not stunned.
				src.lying = 0
				src.stat = 0

		else //Dead.
			src.lying = 1
			src.blinded = 1
			src.stat = 2

		if (src.stuttering) src.stuttering--

		if (src.eye_blind)
			src.eye_blind--
			src.blinded = 1

		if (src.ear_deaf > 0) src.ear_deaf--
		if (src.ear_damage < 25)
			src.ear_damage -= 0.05
			src.ear_damage = max(src.ear_damage, 0)

		src.density = !( src.lying )

		if ((src.sdisabilities & 1))
			src.blinded = 1
		if ((src.sdisabilities & 4))
			src.ear_deaf = 1

		if (src.eye_blurry > 0)
			src.eye_blurry--
			src.eye_blurry = max(0, src.eye_blurry)

		if (src.druggy > 0)
			src.druggy--
			src.druggy = max(0, src.druggy)

		return 1

//Queen verbs
/mob/living/carbon/alien/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (200)"
	set desc = "Plants an egg"
	set category = "Alien"

	if(src.stat)
		src << "You must be concious to do this"
		return
	if(src.toxloss >= 200)
		src.toxloss -= 200
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has laid an egg!</B>"), 1)
		new /obj/alien/egg(src.loc)

	else
		src << "\green Not enough plasma stored"
	return
