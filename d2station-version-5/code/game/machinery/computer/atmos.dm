/*CONTENTS
Gas Sensor
Siphon computer
Atmos alert computer
*/



//the station alerts computer
/obj/machinery/computer/station_alert/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/station_alert/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/station_alert/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var /obj/item/weapon/circuitboard/stationalert/M = new /obj/item/weapon/circuitboard/stationalert( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/stationalert/M = new /obj/item/weapon/circuitboard/stationalert( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return


/obj/machinery/computer/station_alert/proc/interact(mob/user)
	usr.machine = src
	var/dat = "<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' /><HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[user];mach_close=alerts'>Close</A><br><br>"
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "&bull; "
				dat += "[A.name]"
				if (sources.len > 1)
					dat += text(" - [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"
	user << browse(dat, "window=alerts")
	onclose(user, "alerts")

/obj/machinery/computer/station_alert/Topic(href, href_list)
	if(..())
		return
	return

/obj/machinery/computer/station_alert/proc/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if(stat & (BROKEN|NOPOWER))
		return
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	return 1

/obj/machinery/computer/station_alert/proc/cancelAlarm(var/class, area/A as area, obj/origin)
	if(stat & (BROKEN|NOPOWER))
		return
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	return !cleared

/obj/machinery/computer/station_alert/process()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "atmos0"
		return
	var/active_alarms = 0
	for (var/cat in src.alarms)
		var/list/L = src.alarms[cat]
		if(L.len) active_alarms = 1
	if(active_alarms)
		icon_state = "alert:2"
	else
		icon_state = "alert:0"

	..()
