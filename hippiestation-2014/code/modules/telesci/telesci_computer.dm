/obj/machinery/computer/telescience
	name = "\improper Telepad Control Console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	circuit = /obj/item/weapon/circuitboard/telesci_console
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Telescience control console initialized.<BR>Welcome."

	// VARIABLES //
	var/teles_left = 0	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	//var/angle_off
	var/last_target

	var/rotation = 0
	var/angle = 45
	var/power = 5

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80, 100)
	var/teleporting = 0
	var/starting_crystals = 3
	var/max_crystals = 4
	var/list/crystals = list()
	var/obj/item/device/gps/inserted_gps

/obj/machinery/computer/telescience/New()
	..()
	recalibrate()

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.loc = loc
		inserted_gps = null
	..()

/obj/machinery/computer/telescience/examine()
	..()
	usr << "There are [crystals.len ? crystals.len : "no"] bluespace crystals in the crystal slots."

/obj/machinery/computer/telescience/initialize()
	..()
	for(var/i = 1; i <= starting_crystals; i++)
		crystals += new /obj/item/bluespace_crystal/artificial(null) // starting crystals

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/telescience/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/telescience/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/bluespace_crystal))
		if(crystals.len >= max_crystals)
			user << "<span class='warning'>There are not enough crystal slots.</span>"
			return
		user.drop_item()
		crystals += W
		W.loc = null
		user.visible_message("<span class='notice'>[user] inserts [W] into \the [src]'s crystal slot.</span>")
		updateDialog()
	else if(istype(W, /obj/item/device/gps))
		if(!inserted_gps)
			inserted_gps = W
			user.unEquip(W)
			W.loc = src
			user.visible_message("<span class='notice'>[user] inserts [W] into \the [src]'s GPS device slot.</span>")
	else if(istype(W, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/telepad))
			telepad = M.buffer
			M.buffer = null
			user << "<span class = 'caution'>You upload the data from the [W.name]'s buffer.</span>"
	else
		..()

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <BR>Please add telepad data.</div><BR>"
	else
		if(inserted_gps)
			t += "<A href='?src=\ref[src];ejectGPS=1'>Eject GPS</A>"
			t += "<A href='?src=\ref[src];setMemory=1'>Set GPS memory</A>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><BR>"
		t += "<A href='?src=\ref[src];setrotation=1'>Set Bearing</A>"
		t += "<div class='statusDisplay'>[rotation]�</div>"
		t += "<A href='?src=\ref[src];setangle=1'>Set Elevation</A>"
		t += "<div class='statusDisplay'>[angle]�</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= power_options.len; i++)
			if(crystals.len + telepad.efficiency  < i)
				t += "<span class='linkOff'>[power_options[i]]</span>"
				continue
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<A href='?src=\ref[src];setpower=[i]'>[power_options[i]]</A>"
		t += "</div>"

		t += "<A href='?src=\ref[src];setz=1'>Set Sector</A>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		t += "<BR><A href='?src=\ref[src];send=1'>Send</A>"
		t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
		t += "<BR><A href='?src=\ref[src];recal=1'>Recalibrate Crystals</A> <A href='?src=\ref[src];eject=1'>Eject Crystals</A>"

		// Information about the last teleport
		t += "<BR><div class='statusDisplay'>"
		if(!last_tele_data)
			t += "No teleport data found."
		else
			t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<BR>"
			//t += "Distance: [round(last_tele_data.distance, 0.1)]m<BR>"
			t += "Time: [round(last_tele_data.time, 0.1)] secs<BR>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, get_turf(telepad))
		s.start()
	else
		return

// Shake everyone on the z level to let them know that telescience has FUUUUUCKED UP
/obj/machinery/computer/telescience/proc/shake_everyone()
	var/turf/our_turf = get_turf(src)
	for(var/mob/M in mob_list)
		var/turf/their_turf = get_turf(M)
		if(their_turf.z == our_turf.z)
			if(M.client)
				shake_camera(M, 15, 1) //obligatory BOOM BOOM SHAKE THE ROOM
				return


/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message("<span class='warning'>The telepad weakly fizzles.</span>")

	if(prob(25))
		// light irradiation
		for(var/mob/living/M in range(rand(6,10),src))
			M.apply_effect((rand(25, 120)), IRRADIATE, 0)
			M << "\red You feel a warm sensation."
		return
	if(prob(10))
		//war never changes
		for(var/mob/living/M in range(rand(11,40),src))
			M.apply_effect((rand(120, 500)), IRRADIATE, 0)
			M << "\red You feel a wave of heat wash over you."

	/*if(prob(1))
		// AI CALL SHUTTLE I SAW RUNE, SUPER LOW CHANCE, CAN HARDLY HAPPEN
		for(var/mob/living/carbon/O in viewers(src, null))
			var/datum/game_mode/cult/temp = new
			O.show_message("\red The telepad flashes with a strange light, and you have a sudden surge of allegiance toward the true dark one!", 2)
			O.mind.make_Cultist()
			temp.grant_runeword(O)
			sparks()
		return
	if(prob(1))
		// VIVA LA FUCKING REVOLUTION BITCHES, SUPER LOW CHANCE, CAN HARDLY HAPPEN
		for(var/mob/living/carbon/O in viewers(src, null))
			O.show_message("\red The telepad flashes with a strange light, and you see all kind of images flash through your mind, of murderous things Nanotrasen has done, and you decide to rebel!", 2)
			O.mind.make_Rev()
			sparks()
		return*/

	if(prob(8))
		// meteors because frrrak you
		for(var/mob/living/carbon/O in viewers(src, null))
			shake_everyone()
			priority_announce("Unexpected bluespace anomaly detected at [station_name()]. No further information is avalible at this time.", "Telescience Anomaly")
			spawn_meteors(pick((rand(1,10)),(rand(1,30)),(rand(1,50))), pick("meteorsA","meteorsB","meteorsC"))
			sparks()
		return
	if(prob(15))
		//haha i was only pretending to be retarded
		for(var/mob/living/carbon/O in viewers(src, null))
			shake_everyone()
			priority_announce("Unexpected bluespace anomaly detected at [station_name()]. No further information is avalible at this time.", "Telescience Anomaly")
			sparks()
		return
	if(prob(20))
		// i am not removing this
		for(var/mob/living/M in range(rand(6,30),src))
			M << sound('sound/items/AirHorn.ogg')
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			M << "<font color='red' size='7'>HONK</font>"
			M.sleeping = 0
			M.stuttering += 40
			M.ear_deaf += 50
			M.Weaken(5)
			if(prob(30))
				M.Stun(30)
				M.Paralyse(10)
			else
				M.Jitter(500)
			sparks()
		return
	if(prob(15))
		// ASS BLAST USA
		for(var/mob/living/carbon/M in range(rand(20,45),src))
			playsound(src.loc, 'sound/misc/fartmassive.ogg', 60, 1, 5)
			M.emote("scream")
			var/obj/item/clothing/head/butt/B = null
			B = locate() in M.internal_organs
			if(B)
				new /obj/item/clothing/head/butt(M.loc)
				M.internal_organs -= B
				M.apply_damage(9,"brute","chest")
				M << "\red Holy shit, a bluespace portal tears your butt off!"
			if(!B)
				return
			return
	if(prob(5))
		// the station loses it's shit
		for(var/mob/living/carbon/M in range(rand(80,200),src))
			playsound(src.loc, 'sound/misc/fartmassive.ogg', 80, 1, 5)
			var/obj/item/clothing/head/butt/B = null
			B = locate() in M.internal_organs
			if(B)
				new /obj/item/clothing/head/butt(M.loc)
				M.internal_organs -= B
				M << "\red Holy shit, a bluespace portal relocates your butt!"
				new /obj/item/clothing/head/butt(M.loc = ((M.x + rand(-20,20)) + (M.y + rand(-20,20))))
			if(!B)
				return
			return
	if(prob(35))
		// They did the mash! (They did the monster mash!) The monster mash! (It was a graveyard smash!)
		sparks()
		var/L = get_turf(E)
		var/blocked = list(/mob/living/simple_animal/hostile,
			/mob/living/simple_animal/hostile/alien/queen/large,
			/mob/living/simple_animal/hostile/retaliate,
			/mob/living/simple_animal/hostile/retaliate/clown,
			/mob/living/simple_animal/hostile/giant_spider/nurse) // Makes sure certain monsters don't spawn, add your monster to the list if you don't want it to spawn here.
		var/list/hostiles = typesof(/mob/living/simple_animal/hostile) - blocked
		playsound(L, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/human/M in viewers(L, null))
			flick("e_flash", M.flash)
		var/chosen = pick(hostiles)
		var/mob/living/simple_animal/hostile/H = new chosen
		H.loc = L
		return
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Telepad is recharging power.<BR>Please wait [round((teleport_cooldown - world.time) / 10)] seconds."
		return

	if(teleporting)
		temp_msg = "Telepad is in use.<BR>Please wait."
		return

	if(telepad)

		var/truePower = Clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = Clamp(angle, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = Clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = Clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		last_target = target
		var/area/A = get_area(target)
		flick("pad-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, 1)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Powering up bluespace crystals.<BR>Please wait."


		spawn(round(proj_data.time) * 10) // in seconds
			if(!telepad)
				return
			if(telepad.stat & NOPOWER)
				return
			teleporting = 0
			teleport_cooldown = world.time + (power * 2)
			teles_left -= 1

			// use a lot of power
			use_power(power * 10)

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, get_turf(telepad))
			s.start()

			temp_msg = "Teleport successful.<BR>"
			if(teles_left < 3)
				temp_msg += "<BR>Calibration required soon."
			else
				temp_msg += "Data printed below."

			var/sparks = get_turf(target)
			var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
			y.set_up(5, 1, sparks)
			y.start()

			var/turf/source = target
			var/turf/dest = get_turf(telepad)
			var/log_msg = ""
			log_msg += ": [key_name(user)] has teleported "

			if(sending)
				source = dest
				dest = target

			flick("pad-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			for(var/atom/movable/ROI in source)
				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						if(L.buckled)
							// TP people on office chairs
							if(L.buckled.anchored)
								continue

							log_msg += "[key_name(L)] (on a chair), "
						else
							continue
					else if(!isobserver(ROI))
						continue
				if(ismob(ROI))
					var/mob/T = ROI
					log_msg += "[key_name(T)], "
				else
					log_msg += "[ROI.name]"
					if (istype(ROI, /obj/structure/closet))
						var/obj/structure/closet/C = ROI
						log_msg += " ("
						for(var/atom/movable/Q as mob|obj in C)
							if(ismob(Q))
								log_msg += "[key_name(Q)], "
							else
								log_msg += "[Q.name], "
						if (dd_hassuffix(log_msg, "("))
							log_msg += "empty)"
						else
							log_msg = dd_limittext(log_msg, length(log_msg) - 2)
							log_msg += ")"
					log_msg += ", "
				do_teleport(ROI, dest)

			if (dd_hassuffix(log_msg, ", "))
				log_msg = dd_limittext(log_msg, length(log_msg) - 2)
			else
				log_msg += "nothing"
			log_msg += " [sending ? "to" : "from"] [trueX], [trueY], [z_co] ([A ? A.name : "null area"])"
			investigate_log(log_msg, "telesci")
			updateDialog()

/obj/machinery/computer/telescience/proc/teleport(mob/user)

	var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y)
	last_tele_data = proj_data

	var/trueX = Clamp(round(proj_data.dest_x, 1), 1, world.maxx)
	var/trueY = Clamp(round(proj_data.dest_y, 1), 1, world.maxy)

	if(rotation == null || angle == null || z_co == null)
		temp_msg = "ERROR!<BR>Set a angle, rotation and sector."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ERROR!<BR>No power selected!"
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ERROR!<BR>Elevation is less than 1 or greater than 90."
		return
	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name == "awaystart")
			if((z_co == L.z && trueX == L.x && trueY == L.y) && (teles_left > 0))
				doteleport(user)
			else if(z_co == 2 || z_co < 1 || z_co >= 18) //HAHA THIS IS HOW YOU DO IT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				telefail()
				temp_msg = "ERROR! Sector is less than 1, <BR>or equal to 2."
				return
			else if(teles_left > 0)
				doteleport(user)
			else
				telefail()
				temp_msg = "ERROR!<BR>Calibration required."
				return
	return

/obj/machinery/computer/telescience/proc/eject()
	for(var/obj/item/I in crystals)
		I.loc = src.loc
		crystals -= I
	power = 0

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(!telepad)
		updateDialog()
		return
	if(telepad.panel_open)
		temp_msg = "Telepad undergoing physical maintenance operations."

	if(href_list["setrotation"])
		var/new_rot = input("Please input desired bearing in degrees.", name, rotation) as num
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = Clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = input("Please input desired elevation in degrees.", name, angle) as num
		if(..())
			return
		angle = Clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			if(crystals.len + telepad.efficiency >= index)
				power = power_options[index]

	if(href_list["setz"])
		var/new_z = input("Please input desired sector.", name, z_co) as num
		if(..())
			return
		z_co = Clamp(round(new_z), 1, 99999999)

	if(href_list["ejectGPS"])
		inserted_gps.loc = loc
		inserted_gps = null

	if(href_list["setMemory"])
		if(last_target)
			inserted_gps.locked_location = last_target
			temp_msg = "Location saved."
		else
			temp_msg = "ERROR!<BR>No data stored."

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "NOTICE:<BR>Calibration successful."

	if(href_list["eject"])
		eject()
		temp_msg = "NOTICE:<BR>Bluespace crystals ejected."

	updateDialog()

/obj/machinery/computer/telescience/proc/recalibrate()
	teles_left = rand(8, 50)
	//angle_off = rand(-25, 25)
	power_off = rand(-4, 0)
	rotation_off = rand(-10, 10)