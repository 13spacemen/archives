/mob/living/carbon/human/proc/monkeyize()
	if (src.monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		src.u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			W.layer = initial(W.layer)
	src.update_clothing()
	src.monkeyizing = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		//src.organs[text("[]", t)] = null
		del(src.organs[text("[]", t)])
	var/atom/movable/overlay/animation = new /atom/movable/overlay( src.loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null
	del(animation)
	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey( src.loc )

	O.name = "monkey"
	O.dna = src.dna
	src.dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
	if (src.client)
		src.client.mob = O
	O.loc = src.loc
	O.a_intent = "hurt"
	O << "<B>You are now a monkey.</B>"

	del(src)
	return

/mob/new_player/AIize()
	src.spawning = 1
	..()
	return

/mob/living/carbon/AIize()
	if (src.monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		src.u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			W.layer = initial(W.layer)
			del(W)
	src.update_clothing()
	src.monkeyizing = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		del(src.organs[text("[]", t)])


	..()


/mob/proc/AIize()
	src.client.screen.len = null
	var/mob/living/silicon/ai/O = new /mob/living/silicon/ai( src.loc )
	O.icon_state = "ai"
	O.invisibility = 0
	O.canmove = 0
	O.name = src.name
	O.real_name = src.real_name
	O.anchored = 1
	O.aiRestorePowerRoutine = 0
	O.lastKnownIP = src.client.address

	mind.transfer_to(O)
	O.mind.original = O

	var/obj/loc_landmark
	for(var/obj/landmark/start/sloc in world)
		if (sloc.name != "AI")
			continue
		if (locate(/mob) in sloc.loc)
			continue
		loc_landmark = sloc
	if (!loc_landmark)
		for(var/obj/landmark/tripai in world)
			if (tripai.name == "tripai")
				if(locate(/mob) in tripai.loc)
					continue
				loc_landmark = tripai
	if (!loc_landmark)
		O << "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone."
		for(var/obj/landmark/start/sloc in world)
			if (sloc.name == "AI")
				loc_landmark = sloc
		for (var/mob/living/silicon/ai/A in world)
			if(A.name == "Inactive AI")
				del(A)

	O.loc = loc_landmark.loc
	for (var/obj/item/device/radio/intercom/comm in O.loc)
		comm.ai += O

	O << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
	O << "<B>To look at other parts of the station, double-click yourself to get a camera menu.</B>"
	O << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
	O << "To use something, simply double-click it."
	O << "Currently right-click functions will not work for the AI (except examine), and will either be replaced with dialogs or won't be usable by the AI."


	O.laws_object = new /datum/ai_laws/asimov
	O.show_laws()
	O << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

	O.verbs += /mob/living/silicon/ai/proc/ai_call_shuttle
	O.verbs += /mob/living/silicon/ai/proc/show_laws_verb
	O.verbs += /mob/living/silicon/ai/proc/ai_camera_track
	O.verbs += /mob/living/silicon/ai/proc/ai_alerts
	O.verbs += /mob/living/silicon/ai/proc/ai_camera_list
	O.verbs += /mob/living/silicon/ai/proc/lockdown
	O.verbs += /mob/living/silicon/ai/proc/disablelockdown
	O.verbs += /mob/living/silicon/ai/proc/ai_statuschange
	O.verbs += /mob/living/silicon/ai/proc/ai_roster

//	O.verbs += /mob/living/silicon/ai/proc/ai_cancel_call
	O.job = "AI"

	spawn(0)
		ainame(O)
/*		var/randomname = pick(ai_names)
		var/newname = input(O,"You are the AI. Would you like to change your name to something else?", "Name change",randomname)

		if (length(newname) == 0)
			newname = randomname

		if (newname)
			if (length(newname) >= 26)
				newname = copytext(newname, 1, 26)
			newname = dd_replacetext(newname, ">", "'")
			O.real_name = newname
			O.name = newname
*/
		world << text("<b>[O.real_name] is the AI!</b>")


		del(src)

	return O

//human -> robot
/mob/living/carbon/human/proc/Robotize()
	if (src.monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		src.u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			W.layer = initial(W.layer)
			del(W)
	src.update_clothing()
	src.monkeyizing = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		del(src.organs[text("[t]")])
	//src.client.screen -= main_hud1.contents
	src.client.screen -= src.hud_used.contents
	src.client.screen -= src.hud_used.adding
	src.client.screen -= src.hud_used.mon_blo
	src.client.screen -= list( src.oxygen, src.throw_icon, src.i_select, src.m_select, src.toxin, src.internals, src.fire, src.hands, src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	src.client.screen -= list( src.zone_sel, src.oxygen, src.throw_icon, src.i_select, src.m_select, src.toxin, src.internals, src.fire, src.hands, src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot( src.loc )

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 7500


	O.gender = src.gender
	O.invisibility = 0
	O.name = "Cyborg"
	O.real_name = "Cyborg"
	O.lastKnownIP = src.client.address
	if (src.mind)
		src.mind.transfer_to(O)
		if (src.mind.assigned_role == "Cyborg")
			src.mind.original = O
		else if (src.mind.special_role) O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else //welp
		src.mind = new /datum/mind(  )
		src.mind.key = src.key
		src.mind.current = O
		src.mind.original = O
		src.mind.transfer_to(O)
		ticker.minds += O.mind
	O.loc = src.loc
	O << "<B>You are playing a Robot. A Robot can interact with most electronic objects in its view point.</B>"
	O << "<B>You must follow the laws that the AI has. You are the AI's assistant to the station basically.</B>"
	O << "To use something, simply double-click it."
	O << {"Use say ":s to speak to fellow cyborgs and the AI through binary chat."}

	O.job = "Cyborg"



	del(src)
	return O

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (src.monkeyizing)
		return
	for(var/obj/item/weapon/W in src)
		src.u_equip(W)
		if (src.client)
			src.client.screen -= W
		if (W)
			W.loc = src.loc
			W.dropped(src)
			W.layer = initial(W.layer)
	src.update_clothing()
	src.monkeyizing = 1
	src.canmove = 0
	src.icon = null
	src.invisibility = 101
	for(var/t in src.organs)
		del(src.organs[t])
//	var/atom/movable/overlay/animation = new /atom/movable/overlay( src.loc )
//	animation.icon_state = "blank"
//	animation.icon = 'mob.dmi'
//	animation.master = src
//	flick("h2alien", animation)
//	sleep(48)
//	del(animation)

	var/CASTE = pick("Hunter","Sentinel","Drone")
	var/mob/O
	switch(CASTE)
		if("Hunter")
			O = new /mob/living/carbon/alien/humanoid/hunter (src.loc)
		if("Sentinel")
			O = new /mob/living/carbon/alien/humanoid/sentinel (src.loc)
		if("Drone")
			O = new /mob/living/carbon/alien/humanoid/drone (src.loc)

	O.dna = src.dna
	src.dna = null
	O.dna.uni_identity = "00600200A00E0110148FC01300B009"
	O.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"

	O.mind = new//Mind initialize stuff.
	O.mind.current = O
	O.mind.assigned_role = "Alien"
	O.mind.special_role = CASTE
	O.mind.key = src.key
	if(src.client)
		src.client.mob = O


	O.loc = src.loc
	O << "<B>You are now an alien.</B>"
	del(src)
	return