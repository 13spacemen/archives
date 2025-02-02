#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4

// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	name = "area power controller"

	icon_state = "apc0"
	anchored = 1
	req_access = list(access_engine_equip)
	var/area/area
	var/areastring = null
	var/obj/item/weapon/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = 0 //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/charging = 0
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/aidisabled = 0
	var/tdir = null
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/light_consumption = 0 //not used
	var/equip_consumption = 0 //not used
	var/environ_consumption = 0 //not used
	var/emagged = 0
	var/wiresexposed = 0
	var/apcwires = 15
	netnum = -1		// set so that APCs aren't found as powernet nodes
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
//	luminosity = 1
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/overload = 1 //used for the Blackout malf module

/proc/RandomAPCWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/apcwires = list(0, 0, 0, 0)
	APCIndexToFlag = list(0, 0, 0, 0)
	APCIndexToWireColor = list(0, 0, 0, 0)
	APCWireColorToIndex = list(0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<16, flag+=flag)
		var/valid = 0
		while (!valid)
			var/colorIndex = rand(1, 4)
			if (apcwires[colorIndex]==0)
				valid = 1
				apcwires[colorIndex] = flag
				APCIndexToFlag[flagIndex] = flag
				APCIndexToWireColor[flagIndex] = colorIndex
				APCWireColorToIndex[colorIndex] = flagIndex
		flagIndex+=1
	return apcwires

/obj/machinery/power/apc/updateDialog()
	if (stat & (BROKEN|MAINT))
		return
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if (M.client && M.machine == src)
			src.interact(M)
	AutoUpdateAI(src)

/obj/machinery/power/apc/New(turf/loc, var/ndir, var/building=0)
	..()

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	src.tdir = dir		// to fix Vars bug
	dir = SOUTH

	pixel_x = (src.tdir & 3)? 0 : (src.tdir == 4 ? 24 : -24)
	pixel_y = (src.tdir & 3)? (src.tdir ==1 ? 24 : -24) : 0
	if (building==0)
		init()
	else
		area = src.loc.loc:master
		opened = 1
		operating = 0
		name = "[area.name] APC"
		stat |= MAINT
		src.updateicon()
		spawn(5)
			src.update()



/obj/machinery/power/apc/proc/make_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.dir = tdir
	terminal.master = src

/obj/machinery/power/apc/proc/init()
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new/obj/item/weapon/cell(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	var/area/A = src.loc.loc

	//if area isn't specified use current
	if(isarea(A) && src.areastring == null)
		src.area = A
	else
		src.area = get_area_name(areastring)
	updateicon()

	make_terminal()

	spawn(5)
		src.update()

/obj/machinery/power/apc/examine()
	set src in oview(1)

	if(usr /*&& !usr.stat*/)
		usr << "A control terminal for the area electrical systems."
		if(stat & BROKEN)
			usr << "Looks broken."
			return
		if(opened)
			if(has_electronics && terminal)
				usr << "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"]."
			else if (!has_electronics && terminal)
				usr << "There are some wires but no any electronics."
			else if (has_electronics && !terminal)
				usr << "Electronics installed but not wired."
			else /* if (!has_electronics && !terminal) */
				usr << "There is no electronics nor connected wires."

		else
			if (stat & MAINT)
				usr << "The cover is closed. Something wrong with it: it's doesn't work."
			else if (malfhack)
				usr << "The cover is broken. It's may be hard to force it open."
			else
				usr << "The cover is closed."


// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/proc/updateicon()
	if(opened)
		var/basestate = "apc[ cell ? "2" : "1" ]"	// if opened, show cell if it's inserted
		if (opened==1)
			if (stat & MAINT)
				icon_state = "apcmaint" //disassembled APC cannot hold cell
			else
				icon_state = basestate
		else if (opened == 2)
			if ((stat & BROKEN) || malfhack )
				icon_state = "[basestate]-b-nocover"
			else /* if (emagged)*/
				icon_state = "[basestate]-nocover"
		src.overlays = null							// also delete all overlays
		return
	else if(emagged || malfhack)
		icon_state = "apcemag"
		src.overlays = null
		return
	else if(wiresexposed)
		icon_state = "apcewires"
		src.overlays = null
		return
	else if (stat & BROKEN)
		icon_state = "apc-b"
		src.overlays = null
		return
	else
		icon_state = "apc0"

		// if closed, update overlays for channel status

		src.overlays = null
		if (!(stat & (BROKEN|MAINT)))
			overlays += image('power.dmi', "apcox-[locked]")	// 0=blue 1=red
			overlays += image('power.dmi', "apco3-[charging]") // 0=red, 1=yellow/black 2=green


			if(operating)
				overlays += image('power.dmi', "apco0-[equipment]")	// 0=red, 1=green, 2=blue
				overlays += image('power.dmi', "apco1-[lighting]")
				overlays += image('power.dmi', "apco2-[environ]")

//attack with an item - open/close cover, insert cell, or (un)lock interface

/obj/machinery/power/apc/attackby(obj/item/W, mob/user)

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)
	if (istype(W, /obj/item/weapon/crowbar) && opened)
		if (has_electronics==1)
			if (terminal)
				user << "\red Disconnect wires first."
				return
			playsound(src.loc, 'Crowbar.ogg', 50, 1)
			user << "You trying to remove the power control board..."
			if(do_after(user, 50))
				has_electronics = 0
				if ((stat & BROKEN) || malfhack)
					user.visible_message(\
						"\red [user.name] has broken the power control board inside [src.name]!",\
						"You broke the charred power control board and remove remains.",
						"You hear crack")
					//ticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
				else
					user.visible_message(\
						"\red [user.name] has removed the power control board from [src.name]!",\
						"You remove the power control board.")
					new /obj/item/weapon/module/power_control(loc)
		else if (opened!=2) //cover isn't removed
			opened = 0
			updateicon()
	else if (istype(W, /obj/item/weapon/crowbar) && !((stat & BROKEN) || malfhack) )
		if(coverlocked && !(stat & MAINT))
			user << "\red The cover is locked and cannot be opened."
			return
		else
			opened = 1
			updateicon()
	else if	(istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(cell)
			user << "There is a power cell already installed."
			return
		else
			if (stat & MAINT)
				user << "\red There is no any connector for your power cell."
				return
			user.drop_item()
			W.loc = src
			cell = W
			user.visible_message(\
				"\red [user.name] has inserted the power cell to [src.name]!",\
				"You insert the power cell.")
			chargecount = 0
			updateicon()
	else if	(istype(W, /obj/item/weapon/screwdriver))	// haxing
		if(opened)
			if (cell)
				user << "\red Close the APC first." //Less hints more mystery!
				return
			else
				if (has_electronics==1 && terminal)
					has_electronics = 2
					stat &= ~MAINT
					playsound(src.loc, 'Screwdriver.ogg', 50, 1)
					user << "You screw the circuit electronics into place."
				else if (has_electronics==2)
					has_electronics = 1
					stat |= MAINT
					playsound(src.loc, 'Screwdriver.ogg', 50, 1)
					user << "You unfasten the electronics."
				else /* has_electronics==0 */
					user << "\red There is nothing to secure."
					return
				updateicon()
		else if(emagged || malfhack)
			user << "The interface is broken"
		else
			wiresexposed = !wiresexposed
			user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
			updateicon()

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card or a PDA
		if(emagged || malfhack)
			user << "The interface is broken."
		else if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel"
		else if(stat & (BROKEN|MAINT))
			user << "Nothing happens."
		else
			if(src.allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] the APC interface."
				updateicon()
			else
				user << "\red Access denied."
	else if (istype(W, /obj/item/weapon/card/emag) && !(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel first"
		else if(stat & (BROKEN|MAINT))
			user << "Nothing happens."
		else
			flick("apc-spark", src)
			if (do_after(user,6))
				if(prob(50))
					emagged = 1
					locked = 0
					user << "You emag the APC interface."
					updateicon()
				else
					user << "You fail to [ locked ? "unlock" : "lock"] the APC interface."
	else if (istype(W, /obj/item/weapon/cable_coil) && !terminal && opened && has_electronics!=2)
		if (src.loc:intact)
			user << "\red You must remove the floor plating first."
			return
		var/obj/item/weapon/cable_coil/C = W
		if(C.amount < 10)
			user << "\red You need more wires."
			return
		user << "You start adding cables to the APC frame..."
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		if(do_after(user, 20) && C.amount >= 10)
			var/turf/T = get_turf_loc(src)
			var/obj/cable/N = T.get_cable_node()
			if (prob(80) && electrocute_mob(usr, N, N))
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			C.use(10)
			user.visible_message(\
				"\red [user.name] has added cables to the APC frame!",\
				"You add cables to the APC frame.")
			make_terminal()
			terminal.connect_to_network()
	else if (istype(W, /obj/item/weapon/wirecutters) && terminal && opened && has_electronics!=2)
		if (src.loc:intact)
			user << "\red You must remove the floor plating first."
			return
		user << "You begin to cut cables..."
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		if(do_after(user, 50))
			if (prob(80) && electrocute_mob(usr, terminal.powernet, terminal))
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			new /obj/item/weapon/cable_coil(loc,10)
			user.visible_message(\
				"\red [user.name] cut cables and dismantled the power terminal.",\
				"You cut cables and dismantle the power terminal.")
			del(terminal)
	else if (istype(W, /obj/item/weapon/module/power_control) && opened && has_electronics==0 && !((stat & BROKEN) || malfhack))
		user << "You trying to insert the power control board into the frame..."
		playsound(src.loc, 'Deconstruct.ogg', 50, 1)
		if(do_after(user, 10))
			has_electronics = 1
			user << "You place the power control board inside the frame."
			del(W)
	else if (istype(W, /obj/item/weapon/weldingtool) && W:welding && opened && has_electronics==0 && !terminal)
		if (W:get_fuel() < 3)
			user << "\blue You need more welding fuel to complete this task."
			return
		user << "You start welding APC frame..."
		if(W:remove_fuel(2,user))
			playsound(src.loc, 'Welder.ogg', 50, 1)
			if(do_after(user, 50))
				if (emagged || malfhack || (stat & BROKEN) || opened==2)
					new /obj/item/stack/sheet/metal(loc)
					user.visible_message(\
						"\red [src] has been cut apart by [user.name] with the weldingtool.",\
						"You disassembled brocken APC frame.",\
						"\red You hear welding.")
				else
					new /obj/item/apc_frame(loc)
					user.visible_message(\
						"\red [src] has been cut from the wall by [user.name] with the weldingtool.",\
						"You cut APC frame from the wall.",\
						"\red You hear welding.")
				del(src)
				return
	else if (istype(W, /obj/item/apc_frame) && opened && emagged)
		emagged = 0
		if (opened==2)
			opened = 1
		user.visible_message(\
			"\red [user.name] has replaced the damaged APC frontal panel with new one.",\
			"You replace the damaged APC frontal panel with new one.")
		del(W)
		updateicon()
	else if (istype(W, /obj/item/apc_frame) && opened && ((stat & BROKEN) || malfhack))
		if (has_electronics)
			user << "You cannot repair this heavy damaged APC until broken electronics stills inside."
			return
		user << "You begin to replace the damaged APC frame..."
		if(do_after(user, 50))
			user.visible_message(\
				"\red [user.name] has replaced the damaged APC frame with new one.",\
				"You replace the damaged APC frame with new one.")
			del(W)
			stat &= ~BROKEN
			malfai = null
			malfhack = 0
			if (opened==2)
				opened = 1
			updateicon()
	else
		if (	((stat & BROKEN) || malfhack) \
				&& !opened \
				&& W.force >= 5 \
				&& W.w_class >= 3.0 \
				&& prob(20) )
			opened = 2
			user.visible_message("\red The APC cover was knocked down with the [W.name] by [user.name]!", \
				"\red You knock down the APC cover with your [W.name]!", \
				"You hear bang")
			updateicon()
		else
			if (istype(user, /mob/living/silicon))
				return src.attack_hand(user)
			if (wiresexposed && \
				(istype(W, /obj/item/device/multitool) || \
				istype(W, /obj/item/weapon/wirecutters)))
				return src.attack_hand(user)
			user.visible_message("\red The [src.name] has been hit with the [W.name] by [user.name]!", \
				"\red You hit the [src.name] with your [W.name]!", \
				"You hear bang")

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
	add_fingerprint(user)
	if(opened && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.loc = usr
			cell.layer = 20
			if (user.hand )
				user.l_hand = cell
			else
				user.r_hand = cell

			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user.visible_message("\red [user.name] removes the power cell from [src.name]!", "You remove the power cell.")
			//user << "You remove the power cell."
			charging = 0
			src.updateicon()

	else
		if(stat & (BROKEN|MAINT)) return
		// do APC interaction
		user.machine = src
		src.interact(user)



/obj/machinery/power/apc/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ))
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=apc")
			return
		else if (istype(user, /mob/living/silicon) && src.aidisabled && !src.malfhack)
			user << "AI control for this APC interface has been disabled."
			user << browse(null, "window=apc")
			return
		else if (src.malfai)
			if (src.malfai != user)
				user << "AI control for this APC interface has been disabled."
				user << browse(null, "window=apc")
				return
	if(wiresexposed && (!istype(user, /mob/living/silicon)))
		var/t1 = text("<html><head><title>[area.name] APC wires</title></head><body><B>Access Panel</B><br>\n")
		var/list/apcwires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
		)
		for(var/wiredesc in apcwires)
			var/is_uncut = src.apcwires & APCWireColorToFlag[apcwires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];apcwires=[apcwires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];apcwires=[apcwires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[apcwires[wiredesc]]'>Pulse</a> "
			t1 += "<br>"
		t1 += text("<br>\n[(src.locked ? "The APC is locked." : "The APC is unlocked.")]<br>\n[(src.shorted ? "The APCs power has been shorted." : "The APC is working properly!")]<br>\n[(src.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p></body></html>")
		user << browse(t1, "window=apcwires")
		onclose(user, "apcwires")

	user.machine = src
	var/t = "<html><head><title>[area.name] APC</title></head><body><TT><B>Area Power Controller</B> ([area.name])<HR>"

	if(locked && (!istype(user, /mob/living/silicon)))
		t += "<I>(Swipe ID card to unlock inteface.)</I><BR>"
		t += "Main breaker : <B>[operating ? "On" : "Off"]</B><BR>"
		t += "External power : <B>[ main_status ? (main_status ==2 ? "<FONT COLOR=#004000>Good</FONT>" : "<FONT COLOR=#D09000>Low</FONT>") : "<FONT COLOR=#F00000>None</FONT>"]</B><BR>"
		t += "Power cell: <B>[cell ? "[round(cell.percent())]%" : "<FONT COLOR=red>Not connected.</FONT>"]</B>"
		if(cell)
			t += " ([charging ? ( charging == 1 ? "Charging" : "Fully charged" ) : "Not charging"])"
			t += " ([chargemode ? "Auto" : "Off"])"

		t += "<BR><HR>Power channels<BR><PRE>"

		var/list/L = list ("Off","Off (Auto)", "On", "On (Auto)")

		t += "Equipment:    [add_lspace(lastused_equip, 6)] W : <B>[L[equipment+1]]</B><BR>"
		t += "Lighting:     [add_lspace(lastused_light, 6)] W : <B>[L[lighting+1]]</B><BR>"
		t += "Environmental:[add_lspace(lastused_environ, 6)] W : <B>[L[environ+1]]</B><BR>"

		t += "<BR>Total load: [lastused_light + lastused_equip + lastused_environ] W</PRE>"
		t += "<HR>Cover lock: <B>[coverlocked ? "Engaged" : "Disengaged"]</B>"

	else
		if (!istype(user, /mob/living/silicon))
			t += "<I>(Swipe ID card to lock interface.)</I><BR>"
		t += "Main breaker: [operating ? "<B>On</B> <A href='?src=\ref[src];breaker=1'>Off</A>" : "<A href='?src=\ref[src];breaker=1'>On</A> <B>Off</B>" ]<BR>"
		t += "External power : <B>[ main_status ? (main_status ==2 ? "<FONT COLOR=#004000>Good</FONT>" : "<FONT COLOR=#D09000>Low</FONT>") : "<FONT COLOR=#F00000>None</FONT>"]</B><BR>"
		if(cell)
			t += "Power cell: <B>[round(cell.percent())]%</B>"
			t += " ([charging ? ( charging == 1 ? "Charging" : "Fully charged" ) : "Not charging"])"
			t += " ([chargemode ? "<A href='?src=\ref[src];cmode=1'>Off</A> <B>Auto</B>" : "<B>Off</B> <A href='?src=\ref[src];cmode=1'>Auto</A>"])"

		else
			t += "Power cell: <B><FONT COLOR=red>Not connected.</FONT></B>"

		t += "<BR><HR>Power channels<BR><PRE>"


		t += "Equipment:    [add_lspace(lastused_equip, 6)] W : "
		switch(equipment)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];eqp=2'>On</A> <A href='?src=\ref[src];eqp=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <A href='?src=\ref[src];eqp=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <B>On</B> <A href='?src=\ref[src];eqp=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];eqp=1'>Off</A> <A href='?src=\ref[src];eqp=2'>On</A> <B>Auto (On)</B>"
		t +="<BR>"

		t += "Lighting:     [add_lspace(lastused_light, 6)] W : "

		switch(lighting)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];lgt=2'>On</A> <A href='?src=\ref[src];lgt=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <A href='?src=\ref[src];lgt=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <B>On</B> <A href='?src=\ref[src];lgt=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];lgt=1'>Off</A> <A href='?src=\ref[src];lgt=2'>On</A> <B>Auto (On)</B>"
		t +="<BR>"


		t += "Environmental:[add_lspace(lastused_environ, 6)] W : "
		switch(environ)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];env=2'>On</A> <A href='?src=\ref[src];env=3'>Auto</A>"
			if(1)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <A href='?src=\ref[src];env=2'>On</A> <B>Auto (Off)</B>"
			if(2)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <B>On</B> <A href='?src=\ref[src];env=3'>Auto</A>"
			if(3)
				t += "<A href='?src=\ref[src];env=1'>Off</A> <A href='?src=\ref[src];env=2'>On</A> <B>Auto (On)</B>"



		t += "<BR>Total load: [lastused_light + lastused_equip + lastused_environ] W</PRE>"
		t += "<HR>Cover lock: [coverlocked ? "<B><A href='?src=\ref[src];lock=1'>Engaged</A></B>" : "<B><A href='?src=\ref[src];lock=1'>Disengaged</A></B>"]"


		if (istype(user, /mob/living/silicon))
			t += "<BR><HR><A href='?src=\ref[src];overload=1'><I>Overload lighting circuit</I></A><BR>"
		if (ticker)
//		 world << "there's a ticker"
			if(ticker.mode.name == "AI malfunction")
//				world << "ticker says its malf"
				var/datum/game_mode/malfunction/malf = ticker.mode
				for (var/datum/mind/B in malf.malf_ai)
					if (user == B.current)
						if (!src.malfai)
							t += "<BR><HR><A href='?src=\ref[src];malfhack=1'><I>Override Programming</I></A><BR>"
						else
							t += "<BR><HR><I>APC Hacked</I><BR>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT></body></html>"
	user << browse(t, "window=apc")
	onclose(user, "apc")
	return

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"




/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
//		if (area.name == "AI Chamber")
//			spawn(10)
//				world << " [area.name] [area.power_equip]"
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
//		if (area.name == "AI Chamber")
//			world << "[area.power_equip]"
	area.power_change()

/obj/machinery/power/apc/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/get_connection()
	if(stat & (BROKEN|MAINT))	return 0
	return 1

/obj/machinery/power/apc/proc/shock(mob/user, prb)
	if(!prob(prb))
		return 0
	var/is_powered = get_connection()		// find the powernet of the connected cable
	return src.apcelectrocute(user, is_powered)

/obj/machinery/power/apc/proc/apcelectrocute(mob/user, is_powered)

	if(!is_powered)		// unconnected cable is unpowered
		return 0

	var/prot = 1

	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			prot = G.siemens_coefficient
	else if (istype(user, /mob/living/silicon))
		return 0

	if(prot == 0)		// elec insulted gloves protect completely
		return 0

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	var/shock_damage = 0
	if (cell.charge >=2500)
		shock_damage = min(rand(70,145),rand(70,145))*prot
		cell.use(2000)
	else if(cell.charge >=1750)
		shock_damage = min(rand(35,110),rand(35,110))*prot
		cell.use(1600)
	else if(cell.charge >=1500)
		shock_damage = min(rand(30,100),rand(30,100))*prot
		cell.use(1000)
	else if(cell.charge >=750)
		shock_damage = min(rand(25,90),rand(25,90))*prot
		cell.use(500)
	else if(cell.charge >=250)
		shock_damage = min(rand(20,80),rand(20,80))*prot
		cell.use(125)
	else if(cell.charge >=100)
		shock_damage = min(rand(20,65),rand(20,65))*prot
		cell.use(50)
	else
		return 0

	user.burn_skin(shock_damage)
	user.fireloss += shock_damage
	user.updatehealth()
	user.visible_message("\red [user.name] was shocked by the [src.name]!", "\red <B>You feel a powerful shock course through your body!</B>", "\red You hear a heavy electrical crack")
	if(prob(1))
		new /obj/decal/cleanable/urine(user.loc)
		user.achievement_give("Danger Danger! High Voltage!", 16, 70)
	//user << "\red <B>You feel a powerful shock course through your body!</B>"
	sleep(1)

	if(user.stunned < shock_damage)	user.stunned = shock_damage
	if(user.weakened < 20*prot)	user.weakened = 20*prot

/*
 *	for(var/mob/M in viewers(src))
		if(M == user)	continue
		M.show_message("\red [user.name] was shocked by the [src.name]!", 3, "\red You hear a heavy electrical crack", 2)
*/
	return 1


/obj/machinery/power/apc/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	apcwires &= ~wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			src.shock(usr, 50)			//this doesn't work for some reason, give me a while I'll figure it out
			src.shorted = 1
			src.updateDialog()
		if(APC_WIRE_MAIN_POWER2)
			src.shock(usr, 50)
			src.shorted = 1
			src.updateDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateDialog()
//		if(APC_WIRE_IDSCAN)		nothing happens when you cut this wire, add in something if you want whatever


/obj/machinery/power/apc/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	apcwires |= wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			if ((!src.isWireCut(APC_WIRE_MAIN_POWER1)) && (!src.isWireCut(APC_WIRE_MAIN_POWER2)))
				src.shorted = 0
				src.shock(usr, 50)
				src.updateDialog()
		if(APC_WIRE_MAIN_POWER2)
			if ((!src.isWireCut(APC_WIRE_MAIN_POWER1)) && (!src.isWireCut(APC_WIRE_MAIN_POWER2)))
				src.shorted = 0
				src.shock(usr, 50)
				src.updateDialog()
		if (APC_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aidisabledDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if (src.aidisabled == 1)
				src.aidisabled = 0
			src.updateDialog()
//		if(APC_WIRE_IDSCAN)		nothing happens when you cut this wire, add in something if you want whatever

/obj/machinery/power/apc/proc/pulse(var/wireColor)
	//var/wireFlag = apcWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(APC_WIRE_IDSCAN)			//unlocks the APC for 30 seconds, if you have a better way to hack an APC I'm all ears
			src.locked = 0
			spawn(300)
				src.locked = 1
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER1)
			if(shorted == 0)
				shorted = 1
			spawn(1200)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_MAIN_POWER2)
			if(shorted == 0)
				shorted = 1
			spawn(1200)
				if(shorted == 1)
					shorted = 0
				src.updateDialog()
		if (APC_WIRE_AI_CONTROL)
			if (src.aidisabled == 0)
				src.aidisabled = 1
			src.updateDialog()
			spawn(10)
				if (src.aidisabled == 1)
					src.aidisabled = 0
				src.updateDialog()


/obj/machinery/power/apc/Topic(href, href_list)
	..()
	if (((in_range(src, usr) && istype(src.loc, /turf))) || ((istype(usr, /mob/living/silicon) && !(src.aidisabled))))
		usr.machine = src
		if (href_list["apcwires"])
			var/t1 = text2num(href_list["apcwires"])
			if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)
		else if (href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(t1))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(t1)
		else if (href_list["lock"])
			coverlocked = !coverlocked

		else if (href_list["breaker"])
			operating = !operating
			src.update()
			updateicon()

		else if (href_list["cmode"])
			chargemode = !chargemode
			if(!chargemode)
				charging = 0
				updateicon()

		else if (href_list["eqp"])
			var/val = text2num(href_list["eqp"])

			equipment = (val==1) ? 0 : val

			updateicon()
			update()

		else if (href_list["lgt"])
			var/val = text2num(href_list["lgt"])

			lighting = (val==1) ? 0 : val

			updateicon()
			update()
		else if (href_list["env"])
			var/val = text2num(href_list["env"])

			environ = (val==1) ? 0 :val

			updateicon()
			update()
		else if( href_list["close"] )
			usr << browse(null, "window=apc")
			usr.machine = null
			return
		else if (href_list["close2"])
			usr << browse(null, "window=apcwires")
			usr.machine = null
			return

		else if (href_list["overload"])
			if( istype(usr, /mob/living/silicon) && !src.aidisabled )
				src.overload_lighting()

		else if (href_list["malfhack"])
			var/mob/living/silicon/ai/malfai = usr
			if( istype(malfai, /mob/living/silicon/ai) && !src.aidisabled )
				if (malfai.malfhacking)
					malfai << "You are already hacking an APC."
					return
				malfai << "Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process."
				malfai.malfhack = src
				malfai.malfhacking = 1
				sleep(600)
				if (!src.aidisabled)
					malfai.malfhack = null
					malfai.malfhacking = 0
					if (src.z == 1)
						ticker.mode:apcs++
					src.malfai = usr
					src.locked = 1
					if (src.cell)
						if (src.cell.charge > 0)
							src.cell.charge = 0
							cell.corrupt()
							src.malfhack = 1
							malfai << "Hack complete. The APC is now under your exclusive control. Discharging cell to fuse interface."
							updateicon()

							var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
							smoke.set_up(3, 0, src.loc)
							smoke.attach(src)
							smoke.start()
							var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
							s.set_up(3, 1, src)
							s.start()
							for(var/mob/M in viewers(src))
								M.show_message("\red The [src.name] suddenly lets out a blast of smoke and some sparks!", 3, "\red You hear sizzling electronics.", 2)
						else
							malfai << "Hack complete. The APC is now under your exclusive control. Unable to fuse interface due to insufficient cell charge."
					else
						malfai << "Hack complete. The APC is now under your exclusive control. Unable to fuse interface due to lack of cell to discharge."


		src.updateDialog()
		return

	else
		usr << browse(null, "window=apc")
		usr.machine = null

	return

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(var/amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()

	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return


	/*
	if (equipment > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.equip_consumption, EQUIP)
	if (lighting > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.light_consumption, LIGHT)
	if (environ > 1) // off=0, off auto=1, on=2, on auto=3
		use_power(src.environ_consumption, ENVIRON)

	area.calc_lighting() */

	lastused_light = area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_environ = area.usage(ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!src.avail())
		main_status = 0
	else if(excess < 0)
		main_status = 1
	else
		main_status = 2

	var/perapc = 0
	if(terminal && terminal.powernet)
		perapc = terminal.powernet.perapc

	if(cell && !shorted)

		// draw power from cell as before

		var/cellused = min(cell.charge, CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > 0 || perapc > lastused_total)		// if power excess, or enough anyway, recharge the cell
														// by the same amount just used

			cell.give(cellused)
			add_load(cellused/CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc

			if( (cell.charge/CELLRATE+perapc) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?

				cell.charge = min(cell.maxcharge, cell.charge + CELLRATE * perapc)	//recharge with what we can
				add_load(perapc)		// so draw what we can from the grid
				charging = 0

			else	// not enough power available to run the last tick!
				charging = 0
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)

		// set channels depending on how much charge we have left

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15)			// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 30)			// <30%, turn off equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		// now trickle-charge the cell

		if(chargemode && charging == 1 && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is perapc share, capped to cell capacity, or % per second constant (Whichever is smallest)
/*				var/ch = min(perapc, (cell.maxcharge - cell.charge), (cell.maxcharge*CHARGELEVEL))
				add_load(ch) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell
*/
				var/ch = min(perapc*CELLRATE, (cell.maxcharge - cell.charge), (cell.maxcharge*CHARGELEVEL))
				add_load(ch/CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = 0		// stop charging
				chargecount = 0

		// show cell as fully charged if so

		if(cell.charge >= cell.maxcharge)
			charging = 2

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = 1

		else // chargemode off
			charging = 0
			chargecount = 0

	else // no cell, switch everything off

		charging = 0
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	// update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ || last_ch != charging)
		updateicon()
		update()

	//src.updateDialog()
	src.updateDialog()

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff

/proc/autoset(var/val, var/on)

	if(on==0)
		if(val==2)			// if on, return off
			return 0
		else if(val==3)		// if auto-on, return auto-off
			return 1

	else if(on==1)
		if(val==1)			// if auto-off, return auto-on
			return 3

	else if(on==2)
		if(val==3)			// if auto-on, return auto-off
			return 1

	return val

// damage and destruction acts

/obj/machinery/power/apc/meteorhit(var/obj/O as obj)

	set_broken()
	return

/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	spawn(600)
		equipment = 3
		environ = 3
	..()

/obj/machinery/power/apc/ex_act(severity)

	switch(severity)
		if(1.0)
			//set_broken() //now Del() do what we need
			if (cell)
				cell.ex_act(1.0) // more lags woohoo
			del(src)
			return
		if(2.0)
			if (prob(50))
				set_broken()
				if (cell && prob(50))
					cell.ex_act(2.0)
		if(3.0)
			if (prob(25))
				set_broken()
				if (cell && prob(25))
					cell.ex_act(3.0)
	return

/obj/machinery/power/apc/blob_act()
	if (prob(75))
		set_broken()
		if (cell && prob(5))
			cell.blob_act()

/obj/machinery/power/apc/proc/set_broken()
	stat |= BROKEN
	operating = 0
	updateicon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(!get_connection() || !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20);
		spawn(0)
			for(var/area/A in area.related)
				for(var/obj/machinery/light/L in A)
					L.on = 1
					L.broken()
					sleep(1)

/obj/machinery/power/apc/Del()
	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()
	..()