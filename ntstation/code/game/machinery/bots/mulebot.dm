//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

var/global/mulebot_count = 0

/obj/machinery/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	layer = MOB_LAYER
	density = 1
	anchored = 1
	animate_movement=1
	health = 150 //yeah, it's tougher than ed209 because it is a big metal box with wheels --rastaf0
	maxhealth = 150
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
	var/atom/movable/load = null		// the loaded crate (usually)
	var/list/delivery_beacons = list() //List of beacons that serve as delivery locations.
	beacon_freq = 1400
	control_freq = 1447
	bot_type = MULE_BOT
	bot_filter = RADIO_MULEBOT

	suffix = ""

	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	new_destination = ""	// pending new destination (waiting for beacon response)
	destination = ""		// destination description
	var/home_destination = "" 	// tag of home beacon
	req_one_access = list(access_cargo) // added robotics access so assembly line drop-off works properly -veyveyr //I don't think so, Tim. You need to add it to the MULE's hidden robot ID card. -NEO

	mode = BOT_IDLE

	blockcount	= 0		//number of times retried a blocked path
	var/reached_target = 1 	//true if already reached the target

	var/refresh = 1		// true to refresh dialogue
	var/auto_return = 1	// true if auto return to home beacon after unload
	var/auto_pickup = 1 // true if auto-pickup at beacon

	var/obj/item/weapon/stock_parts/cell/cell
	var/datum/wires/mulebot/wires = null
						// the installed power cell

	// constants for internal wiring bitflags
	/*

	var/wires = 1023		// all flags on

	var/list/wire_text	// list of wire colours
	var/list/wire_order	// order of wire indices
	*/


	var/bloodiness = 0		// count of bloodiness

/obj/machinery/bot/mulebot/New()
	..()
	wires = new(src)
	var/datum/job/cargo_tech/J = new/datum/job/cargo_tech
	botcard.access = J.get_access()
	prev_access = botcard.access
//	botcard.access += access_robotics //Why --Ikki
	cell = new(src)
	cell.charge = 2000
	cell.maxcharge = 2000

	spawn(5)	// must wait for map loading to finish
		add_to_beacons(bot_filter)

		mulebot_count += 1
		if(!suffix)
			suffix = "#[mulebot_count]"
		name = "\improper Mulebot ([suffix])"


	verbs -= /atom/movable/verb/pull



// attack by item
// emag : lock/unlock,
// screwdriver: open/close hatch
// cell: insert it
// other: chance to knock rider off bot
/obj/machinery/bot/mulebot/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/card/emag))
		locked = !locked
		user << "\blue You [locked ? "lock" : "unlock"] the mulebot's controls!"
		flick("mulebot-emagged", src)
		playsound(loc, 'sound/effects/sparks1.ogg', 100, 0)
	else if(istype(I, /obj/item/weapon/card/id))
		if(toggle_lock(user))
			user << "\blue Controls [(locked ? "locked" : "unlocked")]."

	else if(istype(I,/obj/item/weapon/stock_parts/cell) && open && !cell)
		var/obj/item/weapon/stock_parts/cell/C = I
		user.drop_item()
		C.loc = src
		cell = C
		updateDialog()
	else if(istype(I,/obj/item/weapon/screwdriver))
		if(locked)
			user << "\blue The maintenance hatch cannot be opened or closed while the controls are locked."
			return

		open = !open
		if(open)
			visible_message("[user] opens the maintenance hatch of [src]", "\blue You open [src]'s maintenance hatch.")
			on = 0
			icon_state="mulebot-hatch"
		else
			visible_message("[user] closes the maintenance hatch of [src]", "\blue You close [src]'s maintenance hatch.")
			icon_state = "mulebot0"

		updateDialog()
	else if (istype(I, /obj/item/weapon/wrench))
		if (health < maxhealth)
			health = min(maxhealth, health+25)
			user.visible_message(
				"\red [user] repairs [src]!",
				"\blue You repair [src]!"
			)
		else
			user << "\blue [src] does not need a repair!"
	else if(istype(I, /obj/item/device/multitool) || istype(I, /obj/item/weapon/wirecutters))
		if(open)
			attack_hand(usr)
	else if(load && ismob(load))  // chance to knock off rider
		if(prob(1+I.force * 2))
			unload(0)
			user.visible_message("\red [user] knocks [load] off [src] with \the [I]!", "\red You knock [load] off [src] with \the [I]!")
		else
			user << "You hit [src] with \the [I] but to no effect."
	else
		..()
	return


/obj/machinery/bot/mulebot/ex_act(var/severity)
	unload(0)
	switch(severity)
		if(2)
			for(var/i = 1; i < 3; i++)
				wires.RandomCut()
		if(3)
			wires.RandomCut()
	..()
	return

/obj/machinery/bot/mulebot/bullet_act()
	if(prob(50) && !isnull(load))
		unload(0)
	if(prob(25))
		visible_message("\red Something shorts out inside [src]!")
		wires.RandomCut()
	..()


/obj/machinery/bot/mulebot/attack_ai(var/mob/user)
	user.set_machine(src)
	interact(user, 1)

/obj/machinery/bot/mulebot/attack_hand(var/mob/user)
	. = ..()
	if (.)
		return
	user.set_machine(src)
	interact(user, 0)

/obj/machinery/bot/mulebot/interact(var/mob/user, var/ai=0)
	var/dat
	dat += "<h3>Multiple Utility Load Effector Mk. III</h3>"
	dat += "<b>ID:</b> [suffix]<BR>"
	dat += "<b>Power:</b> [on ? "On" : "Off"]<BR>"

	if(!open)

		dat += "<h3>Status</h3>"

		dat += "<div class='statusDisplay'>"
		switch(mode)
			if(BOT_IDLE)
				dat += "Ready"
			if(BOT_LOADING)
				dat += "<span class='good'>[mode_name[BOT_LOADING]]</span>"
			if(BOT_DELIVER)
				dat += "<span class='good'>[mode_name[BOT_DELIVER]]</span>"
			if(BOT_GO_HOME)
				dat += "<span class='good'>[mode_name[BOT_GO_HOME]]</span>"
			if(BOT_BLOCKED)
				dat += "<span class='average'>[mode_name[BOT_BLOCKED]]</span>"
			if(BOT_NAV,BOT_WAIT_FOR_NAV)
				dat += "<span class='average'>[mode_name[BOT_NAV]]</span>"
			if(BOT_NO_ROUTE)
				dat += "<span class='bad'>[mode_name[BOT_NO_ROUTE]]</span>"
		dat += "</div>"

		dat += "<b>Current Load:</b> [load ? load.name : "<i>none</i>"]<BR>"
		dat += "<b>Destination:</b> [!destination ? "<i>none</i>" : destination]<BR>"
		dat += "<b>Power level:</b> [cell ? cell.percent() : 0]%"

		if(locked && !ai)
			dat += "&nbsp;<br /><div class='notice'>Controls are locked</div><A href='byond://?src=\ref[src];op=unlock'>Unlock Controls</A>"
		else
			dat += "&nbsp;<br /><div class='notice'>Controls are unlocked</div><A href='byond://?src=\ref[src];op=lock'>Lock Controls</A><BR><BR>"

			dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
			dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"

			if(load)
				dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
			dat += "<div class='notice'>The maintenance hatch is closed.</div>"

	else
		if(!ai)
			dat += "<div class='notice'>The maintenance hatch is open.</div><BR>"
			dat += "<b>Power cell:</b> "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinsert'>Removed</A><BR>"

			dat += wires()
		else
			dat += "<div class='notice'>The bot is in maintenance mode and cannot be controlled.</div><BR>"

	//user << browse("<HEAD><TITLE>M.U.L.E. Mk. III [suffix ? "([suffix])" : ""]</TITLE></HEAD>[dat]", "window=mulebot;size=350x500")
	//onclose(user, "mulebot")
	var/datum/browser/popup = new(user, "mulebot", "M.U.L.E. Mk. III [suffix ? "([suffix])" : ""]", 350, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()
	return

// returns the wire panel text
/obj/machinery/bot/mulebot/proc/wires()
	return wires.GetInteractWindow()


/obj/machinery/bot/mulebot/Topic(href, href_list)
	if(..())
		return
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		switch(href_list["op"])
			if("lock", "unlock")
				toggle_lock(usr)

			if("power")
				if (on)
					turn_off()
				else if (cell && !open)
					if (!turn_on())
						usr << "\red You can't switch on [src]."
						return
				else
					return
				visible_message("[usr] switches [on ? "on" : "off"] [src].")
				updateDialog()


			if("cellremove")
				if(open && cell && !usr.get_active_hand())
					cell.updateicon()
					usr.put_in_active_hand(cell)
					cell.add_fingerprint(usr)
					cell = null

					usr.visible_message("\blue [usr] removes the power cell from [src].", "\blue You remove the power cell from [src].")
					updateDialog()

			if("cellinsert")
				if(open && !cell)
					var/obj/item/weapon/stock_parts/cell/C = usr.get_active_hand()
					if(istype(C))
						usr.drop_item()
						cell = C
						C.loc = src
						C.add_fingerprint(usr)

						usr.visible_message("\blue [usr] inserts a power cell into [src].", "\blue You insert the power cell into [src].")
						updateDialog()


			if("stop")
				if(mode >= BOT_DELIVER)
					bot_reset()
					updateDialog()

			if("go")
				if(mode == BOT_IDLE)
					start()
					updateDialog()

			if("home")
				if(mode == BOT_IDLE || mode == BOT_DELIVER)
					start_home()
					updateDialog()

			if("destination")
				refresh=0
				var/new_dest = input("Select M.U.L.E. Destination", "Mulebot [suffix ? "([suffix])" : ""]", destination) as null|anything in delivery_beacons
				refresh=1
				if(new_dest)
					set_destination(new_dest)


			if("setid")
				refresh=0
				var/new_id = copytext(sanitize(input("Enter new bot ID", "Mulebot [suffix ? "([suffix])" : ""]", suffix) as text|null),1,MAX_NAME_LEN)
				refresh=1
				if(new_id)
					suffix = new_id
					name = "\improper Mulebot ([suffix])"
					updateDialog()

			if("sethome")
				refresh=0
				var/new_home = input("Enter new home tag", "Mulebot [suffix ? "([suffix])" : ""]", home_destination) as null|anything in delivery_beacons
				refresh=1
				if(new_home)
					home_destination = new_home
					updateDialog()

			if("unload")
				if(load && mode !=1)
					if(loc == target)
						unload(loaddir)
					else
						unload(0)

			if("autoret")
				auto_return = !auto_return

			if("autopick")
				auto_pickup = !auto_pickup

			if("close")
				usr.unset_machine()
				usr << browse(null,"window=mulebot")

		updateDialog()
		//updateUsrDialog()
	else
		usr << browse(null, "window=mulebot")
		usr.unset_machine()
	return



// returns true if the bot has power
/obj/machinery/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && wires.HasPower()

/obj/machinery/bot/mulebot/proc/toggle_lock(var/mob/user)
	if(allowed(user))
		locked = !locked
		updateDialog()
		return 1
	else
		user << "\red Access denied."
		return 0

// mousedrop a crate to load the bot
// can load anything if emagged

/obj/machinery/bot/mulebot/MouseDrop_T(var/atom/movable/C, mob/user)

	if(user.stat)
		return

	if (!on || !istype(C)|| C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
		return

	if(load)
		return

	load(C)


// called to load a crate
/obj/machinery/bot/mulebot/proc/load(var/atom/movable/C)
	if(wires.LoadCheck() && !istype(C,/obj/structure/closet/crate))
		visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return		// if not emagged, only allow crates to be loaded

	//I'm sure someone will come along and ask why this is here... well people were dragging screen items onto the mule, and that was not cool.
	//So this is a simple fix that only allows a selection of item types to be considered. Further narrowing-down is below.
	if(!istype(C,/obj/item) && !istype(C,/obj/machinery) && !istype(C,/obj/structure) && !ismob(C))
		return
	if(!isturf(C.loc)) //To prevent the loading from stuff from someone's inventory, which wouldn't get handled properly.
		return

	if(get_dist(C, src) > 1 || load || !on)
		return
	mode = BOT_LOADING

	// if a create, close before loading
	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	C.loc = loc
	sleep(2)
	if(C.loc != loc) //To prevent you from going onto more thano ne bot.
		return
	C.loc = src
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	overlays += C

	if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

	mode = BOT_IDLE
	send_status()

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/obj/machinery/bot/mulebot/proc/unload(var/dirn)
	if(!load)
		return

	mode = BOT_LOADING
	overlays.Cut()

	if(ismob(load))
		var/mob/M = load
		if(M.client)
			M.client.perspective = MOB_PERSPECTIVE
			M.client.eye = src


	load.loc = loc
	load.pixel_y -= 9
	load.layer = initial(load.layer)
	if(dirn)
		var/turf/T = loc
		var/turf/newT = get_step(T,dirn)
		if(load.CanPass(load,newT)) //Can't get off onto anything that wouldn't let you pass normally
			step(load, dirn)

	load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		if(AM == cell || istype(AM , botcard)) continue

		AM.loc = loc
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = src
	mode = BOT_IDLE


/obj/machinery/bot/mulebot/process()
	if(!has_power())
		on = 0
		return
	if(on)
		var/speed = (wires.Motor1() ? 1 : 0) + (wires.Motor2() ? 2 : 0)
		//world << "speed: [speed]"
		switch(speed)
			if(0)
				// do nothing
			if(1)
				process_bot()
				spawn(2)
					process_bot()
					sleep(2)
					process_bot()
					sleep(2)
					process_bot()
					sleep(2)
					process_bot()
			if(2)
				process_bot()
				spawn(4)
					process_bot()
			if(3)
				process_bot()

	if(refresh) updateDialog()

/obj/machinery/bot/mulebot/proc/process_bot()
	//if(mode) world << "Mode: [mode]"
	var/area/dest_area
	if (call_path && call_path.len)
		target = call_path[call_path.len] //Target is the end point of the path, the waypoint set by the AI.
		dest_area = get_area(target)
		destination = format_text(dest_area.name)
		path = call_path
		call_path = null //Once the MULE is commanded, follow normal procedures to reach the waypoint.
		pathset = 1 //Indicates the AI's custom path is initialized.
		start()

	switch(mode)
		if(BOT_IDLE)		// idle
			icon_state = "mulebot0"
			return
		if(BOT_LOADING)		// loading/unloading
			return
		if(BOT_DELIVER,BOT_GO_HOME,BOT_BLOCKED)		// navigating to deliver,home, or blocked

			if(loc == target)		// reached target
				at_target()
				return

			else if(path.len > 0 && target)		// valid path

				var/turf/next = path[1]
				reached_target = 0
				if(next == loc)
					path -= next
					return


				if(istype( next, /turf/simulated))
					//world << "at ([x],[y]) moving to ([next.x],[next.y])"


					if(bloodiness)
						var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
						var/newdir = get_dir(next, loc)
						if(newdir == dir)
							B.dir = newdir
						else
							newdir = newdir | dir
							if(newdir == 3)
								newdir = 1
							else if(newdir == 12)
								newdir = 4
							B.dir = newdir
						bloodiness--



					var/moved = step_towards(src, next)	// attempt to move
					if(cell) cell.use(1)
					if(moved)	// successful move
						//world << "Successful move."
						blockcount = 0
						path -= loc


						if(mode == BOT_BLOCKED)
							spawn(1)
								send_status()

						if(destination == home_destination)
							mode = BOT_GO_HOME
						else
							mode = BOT_DELIVER

					else		// failed to move

						//world << "Unable to move."



						blockcount++
						mode = BOT_BLOCKED
						if(blockcount == 3)
							visible_message("[src] makes an annoyed buzzing sound.", "You hear an electronic buzzing sound.")
							playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)

						if(blockcount > 5)	// attempt 5 times before recomputing
							// find new path excluding blocked turf
							visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
							playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)

							spawn(2)
								calc_path(next)
								if(path.len > 0)
									visible_message("[src] makes a delighted ping!", "You hear a ping.")
									playsound(loc, 'sound/machines/ping.ogg', 50, 0)
								mode = BOT_BLOCKED
							mode = BOT_WAIT_FOR_NAV
							return
						return
				else
					visible_message("[src] makes an annoyed buzzing sound.", "You hear an electronic buzzing sound.")
					playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
					//world << "Bad turf."
					mode = BOT_NAV
					return
			else
				//world << "No path."
				mode = BOT_NAV
				return

		if(BOT_NAV)	// calculate new path
			//world << "Calc new path."
			mode = BOT_WAIT_FOR_NAV
			spawn(0)

				calc_path()

				if(path.len > 0)
					blockcount = 0
					mode = BOT_BLOCKED
					visible_message("[src] makes a delighted ping!", "You hear a ping.")
					playsound(loc, 'sound/machines/ping.ogg', 50, 0)

				else
					visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)

					mode = BOT_NO_ROUTE
		//if(6)
			//world << "Pending path calc."
		//if(7)
			//world << "No dest / no route."

	return


// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/mulebot/calc_path(var/turf/avoid = null)
	path = AStar(loc, target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 250, id=botcard, exclude=avoid)
	if(!path)
		path = list()


// sets the current destination
// signals all beacons matching the delivery code
// beacons will return a signal giving their locations
/obj/machinery/bot/mulebot/set_destination(var/new_dest)
	spawn(0)
		new_destination = new_dest
		post_signal(beacon_freq, "findbeacon", "delivery")
		updateDialog()

// starts bot moving to current destination
/obj/machinery/bot/mulebot/proc/start()
	if(destination == home_destination)
		mode = BOT_GO_HOME
	else
		mode = BOT_DELIVER
	icon_state = "mulebot[(wires.MobAvoid() != 0)]"

// starts bot moving to home
// sends a beacon query to find
/obj/machinery/bot/mulebot/proc/start_home()
	spawn(0)
		set_destination(home_destination)
		mode = BOT_BLOCKED
	icon_state = "mulebot[(wires.MobAvoid() != 0)]"

// called when bot reaches current target
/obj/machinery/bot/mulebot/proc/at_target()
	if(!reached_target)
		visible_message("[src] makes a chiming sound!", "You hear a chime.")
		playsound(loc, 'sound/machines/chime.ogg', 50, 0)
		reached_target = 1

		if(pathset) //The AI called us here, so tell it we arrived.
			loaddir = dir //The MULE will attempt to load a crate in whatever direction the MULE is "facing".
			if(calling_ai)
				calling_ai << "[src] wirelessly plays a chiming sound!"
				playsound(calling_ai, 'sound/machines/chime.ogg',40, 0)
				calling_ai = null
			bot_reset()

		if(load)		// if loaded, unload at target
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup)		// find a crate
				var/atom/movable/AM
				if(!wires.LoadCheck())		// if emagged, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM)
					load(AM)
		// whatever happened, check to see if we return home

		if(auto_return && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = BOT_BLOCKED
		else
			bot_reset()	// otherwise go idle

	send_status()	// report status to anyone listening

	return

// called when bot bumps into anything
/obj/machinery/bot/mulebot/Bump(var/atom/obs)
	if(!wires.MobAvoid())		//usually just bumps, but if avoidance disabled knock over mobs
		var/mob/M = obs
		if(ismob(M))
			if(istype(M,/mob/living/silicon/robot))
				visible_message("<span class='danger'>[src] bumps into [M]!</span>")
			else
				visible_message("<span class='danger'>[src] knocks over [M]!</span>")
				M.stop_pulling()
				M.Stun(8)
				M.Weaken(5)
	..()

/obj/machinery/bot/mulebot/alter_health()
	return get_turf(src)


// called from mob/living/carbon/human/Crossed()
// when mulebot is in the same loc
/obj/machinery/bot/mulebot/proc/RunOver(var/mob/living/carbon/human/H)
	visible_message("<span class='danger'>[src] drives over [H]!</span>")
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, "head")
	H.apply_damage(2*damage, BRUTE, "chest")
	H.apply_damage(0.5*damage, BRUTE, "l_leg")
	H.apply_damage(0.5*damage, BRUTE, "r_leg")
	H.apply_damage(0.5*damage, BRUTE, "l_arm")
	H.apply_damage(0.5*damage, BRUTE, "r_arm")

	var/obj/effect/decal/cleanable/blood/B = new(loc)
	B.blood_DNA = list()
	B.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type

	bloodiness += 4

// player on mulebot attempted to move
/obj/machinery/bot/mulebot/relaymove(var/mob/user)
	if(user.stat)
		return
	if(load == user)
		unload(0)
	return

// receive a radio signal
// used for control and beacon reception

/obj/machinery/bot/mulebot/receive_signal(datum/signal/signal)

	if(!on)
		return

	/*
	world << "rec signal: [signal.source]"
	for(var/x in signal.data)
		world << "* [x] = [signal.data[x]]"
	*/
	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status" && wires.RemoteRX())
		send_status()


	recv = signal.data["command [suffix]"]
	if(wires.RemoteRX())
		// process control input
		switch(recv)
			if("stop")
				bot_reset()
				return

			if("go")
				start()
				return

			if("target")
				set_destination(signal.data["destination"] )
				return

			if("unload")
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
				return

			if("home")
				start_home()
				return

			if("bot_status")
				send_status()
				return

			if("autoret")
				auto_return = text2num(signal.data["value"])
				return

			if("autopick")
				auto_pickup = text2num(signal.data["value"])
				return

	// receive response from beacon
	recv = signal.data["beacon"]

	if(wires.BeaconRX())
		if(recv == new_destination)	// if the recvd beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			target = signal.source.loc
			var/direction = signal.data["dir"]	// this will be the load/unload dir
			if(direction)
				loaddir = text2num(direction)
			else
				loaddir = 0
			icon_state = "mulebot[(wires.MobAvoid() != null)]"
			calc_path()
			updateDialog()

	//Detects and stores current active delivery beacons.
	if(signal.data["beacon"])
		if(!delivery_beacons)
			delivery_beacons = new()
		delivery_beacons[signal.data["beacon"] ] = signal.source

// send a radio signal with a single data key/value pair
/obj/machinery/bot/mulebot/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/mulebot/post_signal_multiple(var/freq, var/list/keyval)

	if(freq == beacon_freq && !(wires.BeaconRX()))
		return
	if(freq == control_freq && !(wires.RemoteTX()))
		return

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return



	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
	signal.data = keyval
		//world << "sent [key],[keyval[key]] on [freq]"
	if (signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if (signal.data["type"] == MULE_BOT)
		frequency.post_signal(src, signal, filter = RADIO_MULEBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/mulebot/send_status()
	var/list/kv = list(
		"type" = MULE_BOT,
		"name" = suffix,
		"loca" = get_area(src),
		"mode" = mode,
		"powr" = (cell ? cell.percent() : 0),
		"dest" = destination,
		"home" = home_destination,
		"load" = load,
		"retn" = auto_return,
		"pick" = auto_pickup,
	)
	post_signal_multiple(control_freq, kv)

/obj/machinery/bot/mulebot/emp_act(severity)
	if (cell)
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)
	..()


/obj/machinery/bot/mulebot/explode()
	visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if (cell)
		cell.loc = Tsec
		cell.update_icon()
		cell = null

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/oil(loc)
	unload(0)
	qdel(src)
