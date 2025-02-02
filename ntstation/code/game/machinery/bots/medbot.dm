//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY


/obj/machinery/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "medibot0"
	layer = 5.0
	density = 0
	anchored = 0
	health = 20
	maxhealth = 20
	req_one_access =list(access_medical, access_robotics)
	var/stunned = 0 //It can be stunned by tasers. Delicate circuits.
//	var/emagged = 0
	var/list/botcard_access = list(access_medical)
	var/obj/item/weapon/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	var/declare_crit = 1 //If active, the bot will transmit a critical patient alert to MedHUD users.
	var/declare_cooldown = 0 //Prevents spam of critical patient alerts.
	var/stationary_mode = 0 //If enabled, the Medibot will not move automatically.
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "tricordrazine"
	var/treatment_oxy = "tricordrazine"
	var/treatment_fire = "tricordrazine"
	var/treatment_tox = "tricordrazine"
	var/treatment_virus = "spaceacillin"
	var/treat_virus = 1 //If on, the bot will attempt to treat viral infections, curing them if possible.
	var/shut_up = 0 //self explanatory :)
	bot_type = MED_BOT
	bot_filter = RADIO_MEDBOT

/obj/machinery/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = "dexalinp"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "anti_toxin"

/obj/item/weapon/firstaid_arm_assembly
	name = "first aid/robot arm assembly"
	desc = "A first aid kit with a robot arm permanently grafted to it."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "firstaid_arm"
	var/build_step = 0
	var/created_name = "Medibot" //To preserve the name if it's a unique medbot I guess
	var/skin = null //Same as medbot, set to tox or ointment for the respective kits.
	w_class = 3.0

	/obj/item/weapon/firstaid_arm_assembly/New()
		..()
		spawn(5)
			if(skin)
				overlays += image('icons/obj/aibots.dmi', "kit_skin_[skin]")

/obj/machinery/bot/medbot/proc/updateicon()
	if(!on)
		icon_state = "medibot0"
	if(mode == BOT_HEALING)
		icon_state = "medibots[stationary_mode]"
		return
	else if(stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "medibot2"
	else
		icon_state = "medibot1"

/obj/machinery/bot/medbot/New()
	..()
	updateicon()

	spawn(4)
		if(skin)
			overlays += image('icons/obj/aibots.dmi', "medskin_[skin]")

		if(isnull(botcard_access) || (botcard_access.len < 1))
			var/datum/job/doctor/J = new/datum/job/doctor
			botcard.access = J.get_access()
		else
			botcard.access = botcard_access
		prev_access = botcard.access
		add_to_beacons(bot_filter)

/obj/machinery/bot/medbot/turn_on()
	. = ..()
	updateicon()
	updateUsrDialog()

/obj/machinery/bot/medbot/turn_off()
	..()
	updateicon()
	updateUsrDialog()

/obj/machinery/bot/medbot/bot_reset()
	..()
	patient = null
	oldpatient = null
	oldloc = null
	last_found = world.time
	declare_cooldown = 0

/obj/machinery/bot/medbot/set_custom_texts()

	text_hack = "You corrupt [name]'s reagent processor circuits."
	text_dehack = "You reset [name]'s reagent processor circuits."
	text_dehack_fail = "[name] seems damaged and does not respond to reprogramming!"

/obj/machinery/bot/medbot/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/bot/medbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat
	dat += hack(user)
	dat += "<TT><B>Medical Unit Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Beaker: "
	if (reagent_glass)
		dat += "<A href='?src=\ref[src];eject=1'>Loaded \[[reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [locked ? "locked" : "unlocked"]<hr>"
	if(!locked || issilicon(user))
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=\ref[src];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=-5'>-</a> "
		dat += "[heal_threshold] "
		dat += "<a href='?src=\ref[src];adj_threshold=5'>+</a> "
		dat += "<a href='?src=\ref[src];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=\ref[src];adj_inject=-5'>-</a> "
		dat += "[injection_amount] "
		dat += "<a href='?src=\ref[src];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=\ref[src];use_beaker=1'>[use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

		dat += "Treat Viral Infections: <a href='?src=\ref[src];virus=1'>[treat_virus ? "Yes" : "No"]</a><br>"
		dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a><br>"
		dat += "Critical Patient Alerts: <a href='?src=\ref[src];critalerts=1'>[declare_crit ? "Yes" : "No"]</a><br>"
		dat += "Patrol Station: <a href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</a><br>"
		dat += "Stationary Mode: <a href='?src=\ref[src];stationary=1'>[stationary_mode ? "Yes" : "No"]</a><br>"

	var/datum/browser/popup = new(user, "automed", "Automatic Medical Unit v1.1")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bot/medbot/Topic(href, href_list)
	..()
	if(locked && !issilicon(usr))
		return

	if(href_list["adj_threshold"])
		var/adjust_num = text2num(href_list["adj_threshold"])
		heal_threshold += adjust_num
		if(heal_threshold < 5)
			heal_threshold = 5
		if(heal_threshold > 75)
			heal_threshold = 75

	else if(href_list["adj_inject"])
		var/adjust_num = text2num(href_list["adj_inject"])
		injection_amount += adjust_num
		if(injection_amount < 5)
			injection_amount = 5
		if(injection_amount > 15)
			injection_amount = 15

	else if(href_list["use_beaker"])
		use_beaker = !use_beaker

	else if (href_list["eject"] && (!isnull(reagent_glass)))
		reagent_glass.loc = get_turf(src)
		reagent_glass = null

	else if (href_list["togglevoice"])
		shut_up = !shut_up

	else if (href_list["critalerts"])
		declare_crit = !declare_crit

	else if (href_list["stationary"])
		stationary_mode = !stationary_mode
		path = new()
		updateicon()

	else if (href_list["virus"])
		treat_virus = !treat_virus

	updateUsrDialog()
	return

/obj/machinery/bot/medbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (allowed(user) && !open && !emagged)
			locked = !locked
			user << "<span class='notice'>Controls are now [locked ? "locked." : "unlocked."]</span>"
			updateUsrDialog()
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='warning'>Access denied.</span>"

	else if (istype(W, /obj/item/weapon/reagent_containers/glass))
		if(locked)
			user << "<span class='notice'>You cannot insert a beaker because the panel is locked.</span>"
			return
		if(!isnull(reagent_glass))
			user << "<span class='notice'>There is already a beaker loaded.</span>"
			return

		user.drop_item()
		W.loc = src
		reagent_glass = W
		user << "<span class='notice'>You insert [W].</span>"
		updateUsrDialog()
		return

	else
		..()
		if (health < maxhealth && !istype(W, /obj/item/weapon/screwdriver) && W.force)
			step_to(src, (get_step_away(src,user)))

/obj/machinery/bot/medbot/Emag(mob/user as mob)
	..()
	if(emagged == 2)
		declare_crit = 0
		if(user)
			user << "<span class='warning'>You short out [src]'s reagent synthesis circuits.</span>"
		spawn(0)
			visible_message("<span class='userdanger'>[src] buzzes oddly!</span>", 1)
		flick("medibot_spark", src)
		if(user)
			oldpatient = user

/obj/machinery/bot/medbot/process()
	set background = BACKGROUND_ENABLED

	if(!on)
		stunned = 0
		return

	if(stunned)
		icon_state = "medibota"
		stunned--

		oldpatient = patient
		patient = null
		mode = BOT_IDLE

		if(stunned <= 0)
			updateicon()
			stunned = 0
		return

	if(call_path) //Stop what you are doing and answer the call!
		call_mode()
		return

	if(frustration > 8)
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		last_found = world.time
		path = new()

	if(!patient)
		if(mode == BOT_SUMMON) //A medibot will not search for new patients when summoned!
			bot_summon()
			return

		if(!shut_up && prob(1))
			var/message = pick("Radar, put a mask on!","There's always a catch, and it's the best there is.","I knew it, I should've been a plastic surgeon.","What kind of medbay is this? Everyone's dropping like dead flies.","Delicious!")
			speak(message)

		var/scan_range = (stationary_mode ? 1 : 7) //If in stationary mode, scan range is limited to adjacent patients.
		for (var/mob/living/carbon/C in view(scan_range,src)) //Time to find a patient!
			if ((C.stat == 2) || !istype(C, /mob/living/carbon/human))
				continue

			if ((C == oldpatient) && (world.time < last_found + 100))
				continue

			if(assess_patient(C))
				patient = C
				oldpatient = C
				last_found = world.time
				spawn(0)
					if((last_newpatient_speak + 100) < world.time) //Don't spam these messages!
						var/message = pick("Hey, you! Hold on, I'm coming.","Wait! I want to help!","You appear to be injured!")
						speak(message)
						last_newpatient_speak = world.time
					visible_message("<span class='name'>[src]</span> points at [C.name]!")
				break
			else
				continue


	if(patient && (get_dist(src,patient) <= 1))
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			updateicon()
			frustration = 0
			medicate_patient(patient)
		return

	else if(patient && (path.len) && (get_dist(patient,path[path.len]) > 2))
		path = new()
		mode = BOT_IDLE
		last_found = world.time

	if(!stationary_mode && patient && path.len == 0 && (get_dist(src,patient) > 1))
		spawn(0)
			path = AStar(loc, get_turf(patient), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 30,id=botcard)
			if(!path)
				path = list()
			if(path.len == 0)
				oldpatient = patient
				patient = null
				mode = BOT_IDLE
				last_found = world.time
		return

	if(path.len > 0 && patient)
		step_to(src, path[1])
		path -= path[1]
		spawn(3)
			if(path.len)
				step_to(src, path[1])
				path -= path[1]

	if(path.len > 8 && patient)
		frustration++

	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	return

/obj/machinery/bot/medbot/proc/assess_patient(mob/living/carbon/C as mob)
	//Time to see if they need medical help!
	if(C.stat == 2)
		return 0 //welp too late for them!

	if(C.suiciding)
		return 0 //Kevorkian school of robotic medical assistants.

	if(emagged == 2) //Everyone needs our medicine. (Our medicine is toxins)
		return 1

	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare(C)

	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((reagent_glass) && (use_beaker) && ((C.getBruteLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getOxyLoss() >= (heal_threshold + 15))))
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R.id))
				return 1

	//They're injured enough for it!
	if((C.getBruteLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_brute)))
		return 1 //If they're already medicated don't bother!

	if((C.getOxyLoss() >= (15 + heal_threshold)) && (!C.reagents.has_reagent(treatment_oxy)))
		return 1

	if((C.getFireLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_fire)))
		return 1

	if((C.getToxLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_tox)))
		return 1

	if(treat_virus) //This check is so that virologists can spread (hopefully benign) viruses.
		for(var/datum/disease/D in C.viruses)
			if((D.stage > 1) || (D.spread_type == AIRBORNE))

				if (!C.reagents.has_reagent(treatment_virus))
					return 1 //STOP DISEASE FOREVER

	return 0

/obj/machinery/bot/medbot/proc/medicate_patient(mob/living/carbon/C as mob)
	if(!on)
		return

	if(!istype(C))
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		last_found = world.time
		return

	if(C.stat == 2)
		var/death_message = pick("No! NO!","Live, damnit! LIVE!","I...I've never lost a patient before. Not today, I mean.")
		speak(death_message)
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		last_found = world.time
		return

	var/reagent_id = null

	if(emagged == 2) //Emagged! Time to poison everybody.
		reagent_id = "toxin"

	else
		if(treat_virus)
			var/virus = 0
			for(var/datum/disease/D in C.viruses)
				virus = 1

			if (!reagent_id && (virus))
				if(!C.reagents.has_reagent(treatment_virus))
					reagent_id = treatment_virus

		if (!reagent_id && (C.getBruteLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_brute))
				reagent_id = treatment_brute

		if (!reagent_id && (C.getOxyLoss() >= (15 + heal_threshold)))
			if(!C.reagents.has_reagent(treatment_oxy))
				reagent_id = treatment_oxy

		if (!reagent_id && (C.getFireLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_fire))
				reagent_id = treatment_fire

		if (!reagent_id && (C.getToxLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_tox))
				reagent_id = treatment_tox

		//If the patient is injured but doesn't have our special reagent in them then we should give it to them first
		if(reagent_id && use_beaker && reagent_glass && reagent_glass.reagents.total_volume)
			for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
				if(!C.reagents.has_reagent(R.id))
					reagent_id = "internal_beaker"
					break

	if(!reagent_id) //If they don't need any of that they're probably cured!
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		last_found = world.time
		var/message = pick("All patched up!","An apple a day keeps me away.","Feel better soon!")
		speak(message)
		updateicon()
		return
	else
		C.visible_message("<span class='danger'>[src] is trying to inject [patient]!</span>", \
			"<span class='userdanger'>[src] is trying to inject [patient]!</span>")

		spawn(30)
			if ((get_dist(src, patient) <= 1) && (on))
				if((reagent_id == "internal_beaker") && (reagent_glass) && (reagent_glass.reagents.total_volume))
					reagent_glass.reagents.trans_to(patient,injection_amount) //Inject from beaker instead.
					reagent_glass.reagents.reaction(patient, 2)
				else
					patient.reagents.add_reagent(reagent_id,injection_amount)
				C.visible_message("<span class='danger'>[src] injects [patient] with the syringe!</span>", \
					"<span class='userdanger'>[src] injects [patient] with the syringe!</span>")

			mode = BOT_IDLE
			updateicon()
			return

	reagent_id = null
	return

/obj/machinery/bot/medbot/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.flag == "taser")
		stunned = min(stunned+10,20)
	..()

/obj/machinery/bot/medbot/explode()
	on = 0
	visible_message("<span class='userdanger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/storage/firstaid(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	new /obj/item/device/healthanalyzer(Tsec)

	if(reagent_glass)
		reagent_glass.loc = Tsec
		reagent_glass = null

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/obj/machinery/bot/medbot/declare(var/crit_patient)
	if(declare_cooldown)
		return
	var/area/location = get_area(src)
	declare_message = "<span class='info'>\icon[src] Medical emergency! [crit_patient ? "<b>[crit_patient]</b>" : "A patient"] is in critical condition at <b>[location]</b>!</span>"
	..()
	declare_cooldown = 1
	spawn(100) //Ten seconds
	declare_cooldown = 0


/* terrible
/obj/machinery/bot/medbot/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if (M)
			var/turf/T = get_turf(src)
			M:loc = T
*/

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
		if(O.density && !istype(O, /obj/structure/window) && !istype(O, /obj/machinery/door))
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

	if ((!istype(S, /obj/item/robot_parts/l_arm)) && (!istype(S, /obj/item/robot_parts/r_arm)))
		..()
		return

	//Making a medibot!
	if(contents.len >= 1)
		user << "<span class='notice'>You need to empty [src] out first.</span>"
		return

	var/obj/item/weapon/firstaid_arm_assembly/A = new /obj/item/weapon/firstaid_arm_assembly
	if(istype(src,/obj/item/weapon/storage/firstaid/fire))
		A.skin = "ointment"
	else if(istype(src,/obj/item/weapon/storage/firstaid/toxin))
		A.skin = "tox"
	else if(istype(src,/obj/item/weapon/storage/firstaid/o2))
		A.skin = "o2"

	qdel(S)
	user.put_in_hands(A)
	user << "<span class='notice'>You add the robot arm to the first aid kit.</span>"
	user.unEquip(src, 1)
	qdel(src)


/obj/item/weapon/firstaid_arm_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return
		created_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W, /obj/item/device/healthanalyzer))
					user.drop_item()
					qdel(W)
					build_step++
					user << "<span class='notice'>You add the health sensor to [src].</span>"
					name = "First aid/robot arm/health analyzer assembly"
					overlays += image('icons/obj/aibots.dmi', "na_scanner")

			if(1)
				if(isprox(W))
					user.drop_item()
					qdel(W)
					build_step++
					user << "<span class='notice'>You complete the Medibot! Beep boop.</span>"
					var/turf/T = get_turf(src)
					var/obj/machinery/bot/medbot/S = new /obj/machinery/bot/medbot(T)
					S.skin = skin
					S.name = created_name
					user.unEquip(src, 1)
					qdel(src)

