/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "\improper Odysseus"
	icon_state = "odysseus"
	step_in = 2
	max_temperature = 15000
	health = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6

	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health/mech(src)
		return

	go_out()
		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			if(H.glasses == hud)
				H.glasses = null
		..()
		return
/*
	verb/set_perspective()
		set name = "Set client perspective."
		set category = "Exosuit Interface"
		set src = usr.loc
		var/perspective = input("Select a perspective type.",
                      "Client perspective",
                      occupant.client.perspective) in list(MOB_PERSPECTIVE,EYE_PERSPECTIVE)
		world << "[perspective]"
		occupant.client.perspective = perspective
		return

	verb/toggle_eye()
		set name = "Toggle eye."
		set category = "Exosuit Interface"
		set src = usr.loc
		if(occupant.client.eye == occupant)
			occupant.client.eye = src
		else
			occupant.client.eye = occupant
		world << "[occupant.client.eye]"
		return
*/

//TODO - Check documentation for client.eye and client.perspective...
/obj/item/clothing/glasses/hud/health/mech
	name = "integrated medical HUD"


	process_hud(var/mob/M)
/*
		world<< "view(M)"
		for(var/mob/mob in view(M))
			world << "[mob]"
		world<< "view(M.client)"
		for(var/mob/mob in view(M.client))
			world << "[mob]"
		world<< "view(M.loc)"
		for(var/mob/mob in view(M.loc))
			world << "[mob]"
*/

		if(!M || M.stat || !(M in view(M)))	return
		if(!M.client)	return
		var/client/C = M.client
		var/image/holder
		for(var/mob/living/carbon/human/patient in view(M.loc))
			if(M.see_invisible < patient.invisibility)
				continue
			var/foundVirus = 0
			for(var/datum/disease/D in patient.viruses)
				if(!D.hidden[SCANNER])
					foundVirus++
			//if(patient.virus2)
			//	foundVirus++

			holder = patient.hud_list[HEALTH_HUD]
			if(patient.stat == 2)
				holder.icon_state = "hudhealth-100"
				C.images += holder
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
				C.images += holder

			holder = patient.hud_list[STATUS_HUD]
			if(patient.stat == 2)
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(foundVirus)
				holder.icon_state = "hudill"
			else
				holder.icon_state = "hudhealthy"
			C.images += holder

/obj/mecha/medical/odysseus/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/sleeper(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun(src)
	ME.attach(src)
	return
