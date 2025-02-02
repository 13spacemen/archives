//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY


/obj/machinery/bot/medbot
	name = "Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'aibots.dmi'
	icon_state = "medibot0"
	layer = 5.0
	density = 1
	anchored = 0
	health = 20
	maxhealth = 20
	req_access =list(access_medical)
	var/stunned = 0 //It can be stunned by tasers. Delicate circuits.
	var/locked = 1
	var/emagged = 0
	var/obj/machinery/camera/cam = null
	var/list/botcard_access = list(access_medical, access_morgue, access_medlab, access_robotics)
	var/obj/item/weapon/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/frustration = 0
	var/path[] = new()
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/currently_healing = 0
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 15 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "bicaridine"
	var/treatment_oxy = "dexalin"
	var/treatment_fire = "kelotane"
	var/treatment_tox = "anti_toxin"
	var/treatment_virus = "spaceacillin"

/obj/machinery/bot/medbot/mysterious
	name = "Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = "dexalinp"

/obj/item/weapon/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = 3.0

	New()
		..()
		spawn(5)
			if(src.skin)
				src.overlays += image('aibots.dmi', "kit_skin_[src.skin]")


/obj/machinery/bot/medbot/New()
	..()
	src.icon_state = "medibot[src.on]"

	spawn(4)
		if(src.skin)
			src.overlays += image('aibots.dmi', "medskin_[src.skin]")

		src.botcard = new /obj/item/weapon/card/id(src)
		if(isnull(src.botcard_access) || (src.botcard_access.len < 1))
			src.botcard.access = get_access("Medical Doctor")
		else
			src.botcard.access = src.botcard_access
		src.cam = new /obj/machinery/camera(src)
		src.cam.c_tag = src.name
		src.cam.network = "SS13"

/obj/machinery/bot/medbot/turn_on()
	. = ..()
	src.icon_state = "medibot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/medbot/turn_off()
	..()
	src.patient = null
	src.oldpatient = null
	src.oldloc = null
	src.path = new()
	src.currently_healing = 0
	src.last_found = world.time
	src.icon_state = "medibot[src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/medbot/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/bot/medbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat
	dat += "<TT><B>Automatic Medical Unit v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A><BR>"
	dat += "Beaker: "
	if (src.reagent_glass)
		dat += "<A href='?src=\ref[src];eject=1'>Loaded \[[src.reagent_glass.reagents.total_volume]/[src.reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [src.locked ? "locked" : "unlocked"]<hr>"
	if(!src.locked)
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=\ref[src];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=-5'>-</a> "
		dat += "[src.heal_threshold] "
		dat += "<a href='?src=\ref[src];adj_threshold=5'>+</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=\ref[src];adj_inject=-5'>-</a> "
		dat += "[src.injection_amount] "
		dat += "<a href='?src=\ref[src];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=\ref[src];use_beaker=1'>[src.use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

	user << browse("<HEAD><TITLE>Medibot v1.0 controls</TITLE></HEAD>[dat]", "window=automed")
	onclose(user, "automed")
	return

/obj/machinery/bot/medbot/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()

	else if((href_list["adj_threshold"]) && (!src.locked))
		var/adjust_num = text2num(href_list["adj_threshold"])
		src.heal_threshold += adjust_num
		if(src.heal_threshold < 5)
			src.heal_threshold = 5
		if(src.heal_threshold > 75)
			src.heal_threshold = 75

	else if((href_list["adj_inject"]) && (!src.locked))
		var/adjust_num = text2num(href_list["adj_inject"])
		src.injection_amount += adjust_num
		if(src.injection_amount < 5)
			src.injection_amount = 5
		if(src.injection_amount > 15)
			src.injection_amount = 15

	else if((href_list["use_beaker"]) && (!src.locked))
		src.use_beaker = !src.use_beaker

	else if (href_list["eject"] && (!isnull(src.reagent_glass)))
		if(!src.locked)
			src.reagent_glass.loc = get_turf(src)
			src.reagent_glass = null
		else
			usr << "You cannot eject the beaker because the panel is locked!"

	src.updateUsrDialog()
	return

/obj/machinery/bot/medbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/card/emag)) && (!src.emagged))

		user << "\red You short out [src]'s reagent synthesis circuits."
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("\red <B>[src] buzzes oddly!</B>", 1)
		flick("medibot_spark", src)
		src.patient = null
		src.oldpatient = user
		src.currently_healing = 0
		src.last_found = world.time
		src.anchored = 0
		src.emagged = 1
		src.on = 1
		src.icon_state = "medibot[src.on]"

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user))
			src.locked = !src.locked
			user << "Controls are now [src.locked ? "locked." : "unlocked."]"
			src.updateUsrDialog()
		else
			user << "\red Access denied."

	else if (istype(W, /obj/item/weapon/reagent_containers/glass))
		if(src.locked)
			user << "You cannot insert a beaker because the panel is locked!"
			return
		if(!isnull(src.reagent_glass))
			user << "There is already a beaker loaded!"
			return

		user.drop_item()
		W.loc = src
		src.reagent_glass = W
		user << "You insert [W]."
		src.updateUsrDialog()
		return

	else
		..()
		if (health < maxhealth && !istype(W, /obj/item/weapon/screwdriver) && W.force)
			step_to(src, (get_step_away(src,user)))


/obj/machinery/bot/medbot/process()
	set background = 1

	if(!src.on)
		src.stunned = 0
		return

	if(src.stunned)
		src.icon_state = "medibota"
		src.stunned--

		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0

		if(src.stunned <= 0)
			src.icon_state = "medibot[src.on]"
			src.stunned = 0
		return

	if(src.frustration > 8)
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		src.path = new()

	if(!src.patient)
		if(prob(1))
			var/message = pick("Radar, put a mask on!","There's always a catch, and it's the best there is.","I knew it, I should've been a plastic surgeon.","What kind of medbay is this? Everyone's dropping like dead flies.","Delicious!")
			src.speak(message)

		for (var/mob/living/carbon/C in view(7,src)) //Time to find a patient!
			if ((C.stat == 2) || !istype(C, /mob/living/carbon/human))
				continue

			if ((C == src.oldpatient) && (world.time < src.last_found + 100))
				continue

			if(src.assess_patient(C))
				src.patient = C
				src.oldpatient = C
				src.last_found = world.time
				spawn(0)
					if((src.last_newpatient_speak + 100) < world.time) //Don't spam these messages!
						var/message = pick("Hey, you! Hold on, I'm coming.","Wait! I want to help!","You appear to be injured!")
						src.speak(message)
						src.last_newpatient_speak = world.time
					src.visible_message("<b>[src]</b> points at [C.name]!")
				break
			else
				continue


	if(src.patient && (get_dist(src,src.patient) <= 1))
		if(!src.currently_healing)
			src.currently_healing = 1
			src.frustration = 0
			src.medicate_patient(src.patient)
		return

	else if(src.patient && (src.path.len) && (get_dist(src.patient,src.path[src.path.len]) > 2))
		src.path = new()
		src.currently_healing = 0
		src.last_found = world.time

	if(src.patient && src.path.len == 0 && (get_dist(src,src.patient) > 1))
		spawn(0)
			src.path = AStar(src.loc, get_turf(src.patient), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 30,id=botcard)
			src.path = reverselist(src.path)
			if(src.path.len == 0)
				src.oldpatient = src.patient
				src.patient = null
				src.currently_healing = 0
				src.last_found = world.time
		return

	if(src.path.len > 0 && src.patient)
		step_to(src, src.path[1])
		src.path -= src.path[1]
		spawn(3)
			if(src.path.len)
				step_to(src, src.path[1])
				src.path -= src.path[1]

	if(src.path.len > 8 && src.patient)
		src.frustration++

	return

/obj/machinery/bot/medbot/proc/assess_patient(mob/living/carbon/C as mob)
	//Time to see if they need medical help!
	if(C.stat == 2)
		return 0 //welp too late for them!

	if(C.suiciding)
		return 0 //Kevorkian school of robotic medical assistants.

	if(src.emagged) //Everyone needs our medicine. (Our medicine is toxins)
		return 1

	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((src.reagent_glass) && (src.use_beaker) && ((C.bruteloss >= heal_threshold) || (C.toxloss >= heal_threshold) || (C.toxloss >= heal_threshold) || (C.oxyloss >= (heal_threshold + 15))))
		for(var/datum/reagent/R in src.reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R))
				return 1
			continue

	//They're injured enough for it!
	if((C.bruteloss >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_brute)))
		return 1 //If they're already medicated don't bother!

	if((C.oxyloss >= (15 + heal_threshold)) && (!C.reagents.has_reagent(src.treatment_oxy)))
		return 1

	if((C.fireloss >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_fire)))
		return 1

	if((C.toxloss >= heal_threshold) && (!C.reagents.has_reagent(src.treatment_tox)))
		return 1

//	if(C.virus && ((C.virus.stage > 1) || (C.virus.spread_type == AIRBORNE)))
//		if (!C.reagents.has_reagent(src.treatment_virus))
//			return 1 //STOP DISEASE FOREVER

	return 0

/obj/machinery/bot/medbot/proc/medicate_patient(mob/living/carbon/C as mob)
	if(!src.on)
		return

	if(!istype(C))
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		return

	if(C.stat == 2)
		var/death_message = pick("No! NO!","Live, damnit! LIVE!","I...I've never lost a patient before. Not today, I mean.")
		src.speak(death_message)
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		return

	var/reagent_id = null

	//Use whatever is inside the loaded beaker. If there is one.
	if((src.use_beaker) && (src.reagent_glass) && (src.reagent_glass.reagents.total_volume))
		reagent_id = "internal_beaker"

	if(src.emagged) //Emagged! Time to poison everybody.
		reagent_id = "toxin"

//	if (!reagent_id && (C.virus))
//		if(!C.reagents.has_reagent(src.treatment_virus))
//			reagent_id = src.treatment_virus

	if (!reagent_id && (C.bruteloss >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_brute))
			reagent_id = src.treatment_brute

	if (!reagent_id && (C.oxyloss >= (15 + heal_threshold)))
		if(!C.reagents.has_reagent(src.treatment_oxy))
			reagent_id = src.treatment_oxy

	if (!reagent_id && (C.fireloss >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_fire))
			reagent_id = src.treatment_fire

	if (!reagent_id && (C.toxloss >= heal_threshold))
		if(!C.reagents.has_reagent(src.treatment_tox))
			reagent_id = src.treatment_tox

	if(!reagent_id) //If they don't need any of that they're probably cured!
		src.oldpatient = src.patient
		src.patient = null
		src.currently_healing = 0
		src.last_found = world.time
		var/message = pick("All patched up!","An apple a day keeps me away.","Feel better soon!")
		src.speak(message)
		return
	else
		src.icon_state = "medibots"
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src] is trying to inject [src.patient]!</B>", 1)
		spawn(30)
			if ((get_dist(src, src.patient) <= 1) && (src.on))
				if((reagent_id == "internal_beaker") && (src.reagent_glass) && (src.reagent_glass.reagents.total_volume))
					src.reagent_glass.reagents.trans_to(src.patient,src.injection_amount) //Inject from beaker instead.
					src.reagent_glass.reagents.reaction(src.patient, 2)
				else
					src.patient.reagents.add_reagent(reagent_id,src.injection_amount)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[src] injects [src.patient] with the syringe!</B>", 1)

			src.icon_state = "medibot[src.on]"
			src.currently_healing = 0
			return

//	src.speak(reagent_id)
	reagent_id = null
	return


/obj/machinery/bot/medbot/proc/speak(var/message)
	if((!src.on) || (!message))
		return
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return

/obj/machinery/bot/medbot/bullet_act(flag, A as obj)
	if (flag == PROJECTILE_TASER)
		src.stunned = min(stunned+10,20)
	..()

/obj/machinery/bot/medbot/emp_act(severity)
	if (cam)
		cam.emp_act(severity)
	..()

/obj/machinery/bot/medbot/explode()
	src.on = 0
	for(var/mob/O in hearers(src, null))
		O.show_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/storage/firstaid(Tsec)

	new /obj/item/device/prox_sensor(Tsec)

	new /obj/item/device/healthanalyzer(Tsec)

	if(src.reagent_glass)
		src.reagent_glass.loc = Tsec
		src.reagent_glass = null

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(src)
	return

/obj/machinery/bot/medbot/Bump(M as mob|obj) //Leave no door unopened!
	spawn(0)
		if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
			var/obj/machinery/door/D = M
			if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
				D.open()
				src.frustration = 0
		else if ((istype(M, /mob/living/)) && (!src.anchored))
			src.loc = M:loc
			src.frustration = 0

		return
	return

/obj/machinery/bot/medbot/Bumped(M as mob|obj)
	spawn(0)
		var/turf/T = get_turf(src)
		M:loc = T


/*
 *	Pathfinding procs, allow the medibot to path through doors it has access to.
 */

//Pretty ugh
/*
/turf/proc/AdjacentTurfsAllowMedAccess()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindowNonDoor(t,get_access("Medical Doctor")))
				L.Add(t)
	return L


//It isn't blocked if we can open it, man.
/proc/TurfBlockedNonWindowNonDoor(turf/loc, var/list/access)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/window) && !istype(O, /obj/machinery/door))
			return 1

		if (O.density && (istype(O, /obj/machinery/door)) && (access.len))
			var/obj/machinery/door/D = O
			for(var/req in D.req_access)
				if(!(req in access)) //doesn't have this access
					return 1

	return 0
*/

/*
 *	Medbot Assembly -- Can be made out of all three medkits.
 */

/obj/item/weapon/storage/firstaid/attackby(var/obj/item/robot_parts/S, mob/user as mob)
	//..()
	if ((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		if (src.contents.len >= 7)
			return
		if ((S.w_class >= 2 || istype(S, /obj/item/weapon/storage)))
			return
		..()
		return

	//Syringekit doesn't count EVER.
	if(src.type == /obj/item/weapon/storage/firstaid/syringes)
		return

	if(src.contents.len >= 1)
		user << "\red You need to empty [src] out first!"
		return
	else
		var/obj/item/weapon/firstaid_arm_assembly/A = new /obj/item/weapon/firstaid_arm_assembly
		if(istype(src,/obj/item/weapon/storage/firstaid/fire))
			A.skin = "ointment"
		else if(istype(src,/obj/item/weapon/storage/firstaid/toxin))
			A.skin = "tox"
		else if(istype(src,/obj/item/weapon/storage/firstaid/oxydep))
			A.skin = "o2"

		A.loc = user
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = A
		else
			user.u_equip(S)
			user.l_hand = A
		A.layer = 20
		user << "You add the robot arm to the first aid kit"
		del(S)
		del(src)

/obj/item/weapon/firstaid_arm_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/device/healthanalyzer)) && (!src.build_step))
		src.build_step++
		user << "You add the health sensor to [src]!"
		src.name = "First aid/robot arm/health analyzer assembly"
		src.overlays += image('aibots.dmi', "na_scanner")
		del(W)

	else if ((istype(W, /obj/item/device/prox_sensor)) && (src.build_step == 1))
		src.build_step++
		user << "You complete the Medibot! Beep boop."
		var/obj/machinery/bot/medbot/S = new /obj/machinery/bot/medbot
		S.skin = src.skin
		S.loc = get_turf(src)
		S.name = src.created_name
		del(W)
		del(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t