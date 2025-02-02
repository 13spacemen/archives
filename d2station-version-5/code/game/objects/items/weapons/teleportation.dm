/*
CONTAINS:
LOCATOR
HAND_TELE

*/

/obj/item/weapon/locator/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.temp)
		dat = "<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' />[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = {"
<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' />
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

<A href='?src=\ref[src];refresh=1'>Refresh</A>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location||current_location.z==2)//If turf was not found or they're on z level 2.
		usr << "The [src] is malfunctioning."
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["refresh"])
			src.temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Beacons:</B><BR>"

				for(var/obj/item/device/radio/beacon/W in world)
					if (W.frequency == src.frequency)
						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							src.temp += "[W.code]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>Extranneous Signals:</B><BR>"
				for (var/obj/item/weapon/implant/tracking/W in world)
					if (W.frequency == src.frequency)
						if (!W.implanted || !ismob(W.loc))
							continue
						else
							var/mob/M = W.loc
							if (M.stat == 2)
								if (M.timeofdeath + 6000 < world.time)
									continue

						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 20)
								if (direct < 5)
									direct = "very strong"
								else
									if (direct < 10)
										direct = "strong"
									else
										direct = "weak"
								src.temp += "[W.id]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				src.frequency += text2num(href_list["freq"])
				src.frequency = sanitize_frequency(src.frequency)
			else
				if (href_list["temp"])
					src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/// HAND TELE

/obj/item/weapon/hand_tele/attack_self(mob/user as mob)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(!current_location||current_location.z==2)//If turf was not found or they're on z level 2.
		user << "The [src] is malfunctioning."
		return
	var/list/L = list(  )
	for(var/obj/machinery/teleport/hub/R in machines)
		var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(R.x - 2, R.y, R.z))
		if (istype(com, /obj/machinery/computer/teleporter) && com.locked)
			if(R.icon_state == "tele1")
				L["[com.id] (Active)"] = com.locked
			else
				L["[com.id] (Inactive)"] = com.locked
	var/list/turfs = list(	)
	for(var/turf/T in orange(10))
		if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-4 || T.y<4)	continue
		turfs += T
	L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") in L
	if ((user.equipped() != src || user.stat || user.restrained()))
		return
	var/count = 0	//num of portals from this teleport in world
	for(var/obj/portal/PO in world)
		if(PO.creator == src)	count++
	if(count >= 3)
		user.show_message("\red The hand teleporter is recharging!")
		return
	var/T = L[t1]
	for(var/mob/O in hearers(user, null))
		O.show_message("\blue Locked In", 2)
	var/obj/portal/P = new /obj/portal( get_turf(src) )
	P.target = T
	P.creator = src
	src.add_fingerprint(user)
	return


