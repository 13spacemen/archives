/datum/hook/mobAreaChange
	name = "MobAreaChange"

/area/
	var/global/global_uid = 0
	var/uid

/area/New()

	src.icon = 'alert.dmi'
	uid = ++global_uid
	spawn(1)
	//world.log << "New: [src] [tag]"
		if(name == "Space")			// override defaults for space
			ul_Lighting = 0
		ul_Prep()
		if(findtext(tag,":UL") != 0)
			related += src
			return
		master = src
		related = list(src)

		src.icon = 'alert.dmi'
		src.layer = 10
//		update_lights()
		if(name == "Space")			// override defaults for space
			requires_power = 0

		if(!requires_power)
			power_light = 0//rastaf0
			power_equip = 0//rastaf0
			power_environ = 0//rastaf0
			ul_Lighting = 0			// *DAL*
//			sd_lighting = 0			// *DAL*
		else
			luminosity = 0
			//ul_SetLuminosity(0)		// *DAL*


	/*spawn(5)
		for(var/turf/T in src)		// count the number of turfs (for lighting calc)
			if(no_air)
				T.oxygen = 0		// remove air if so specified for this area
				T.n2 = 0
				T.res_vars()

	*/


	spawn(15)
		src.power_change()		// all machines set to current power level, also updates lighting icon
		alldoors = get_doors(src)

/area/Entered(atom/movable/Obj,atom/OldLoc)
	if (istype(Obj, /mob))
		var/area/NewArea = get_area(Obj.loc)
		var/area/OldArea = get_area(OldLoc)
		var/NewTag = copytext(NewArea.tag, 1, findtext(NewArea.tag, ":UL"))
		var/OldTag = copytext(OldArea.tag, 1, findtext(OldArea.tag, ":UL"))
		if (NewTag != OldTag)
			CallHook("MobAreaChange", list("mob" = Obj, "newTag" = NewTag, "oldTag" = OldTag))


///proc/get_area(area/A)
//	while (A)
//		if (istype(A, /area))
//			return A
//
//		A = A.loc
//	return null
/*
/area/proc/update_lights()
	var/new_power = 0
	for(var/obj/machinery/light/L in src.contents)
		if(L.on)
			new_power += (L.luminosity * 20)
	lighting_power_usage = new_power
	return
*/
/area/proc/poweralert(var/state, var/source)
	if (state != poweralm)
		poweralm = state
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/aiPlayer in mobz)
			if (state == 1)
				aiPlayer.cancelAlarm("Power", src, source)
			else
				aiPlayer.triggerAlarm("Power", src, cameras, source)
		for(var/obj/machinery/computer/station_alert/a in machines)
			if(state == 1)
				a.cancelAlarm("Power", src, source)
			else
				a.triggerAlarm("Power", src, source)
	return

/area/proc/atmosalert(danger_level)
//	if(src.type==/area) //No atmos alarms in space
//		return 0 //redudant
	if(danger_level != src.atmosalm)
		//src.updateicon()
		//src.mouse_opacity = 0
		if (danger_level==2)
			var/list/cameras = list()
			for(var/area/RA in src.related)
				//src.updateicon()
				for(var/obj/machinery/camera/C in RA)
					cameras += C
			for(var/mob/living/silicon/aiPlayer in mobz)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.triggerAlarm("Atmosphere", src, cameras, src)
		else if (src.atmosalm == 2)
			for(var/mob/living/silicon/aiPlayer in mobz)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.cancelAlarm("Atmosphere", src, src)
		src.atmosalm = danger_level
		return 1
	return 0

/area/proc/firealert()
	if(src.name == "Space") //no fire alarms in space
		return
	if (!( src.fire ))
		src.fire = 1
		src.updateicon()
		src.mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = CLOSED
					D.close()
					D.level = 2
					D.layer = 2.7
				else if(!D.density)
					spawn(0)
					D.close()
			//		D.level = 2
			//		D.layer = 2.7
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/ai/aiPlayer in mobz)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			a.triggerAlarm("Fire", src, cameras, src)
	return

/area/proc/firereset()
	if (src.fire)
		src.fire = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
					D.open()
				else if(D.density)
					spawn(0)
					D.open()
		//			D.level = 1
		//			D.layer = 1
		for (var/mob/living/silicon/ai/aiPlayer in mobz)
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			a.cancelAlarm("Fire", src, src)
	return

/area/proc/readyalert()
	if(name == "Space")
		return
	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/partyalert()
	if(src.name == "Space") //no parties in space!!!
		return
	if (!( src.party ))
		src.party = 1
		src.updateicon()
		src.mouse_opacity = 0
	return

/area/proc/partyreset()
	if (src.party)
		src.party = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()
	return

/area/proc/updateicon()
	if ((fire || eject || party) && ((!requires_power)?(!requires_power):power_environ))//If it doesn't require power, can still activate this proc.
		if(fire && !eject && !party)
			icon_state = "blue"
		/*else if(atmosalm && !fire && !eject && !party)
			icon_state = "bluenew"*/
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else
	//	new lighting behaviour with obj lights
		icon_state = null


/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!master.requires_power)
		return 1
	switch(chan)
		if(EQUIP)
			return master.power_equip
		if(LIGHT)
			return master.power_light
		if(ENVIRON)
			return master.power_environ

	return 0

// called when power status changes

/area/proc/power_change()
	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)
		if (fire || eject || party)
			RA.updateicon()

/area/proc/usage(var/chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += master.used_light
		if(EQUIP)
			used += master.used_equip
		if(ENVIRON)
			used += master.used_environ
		if(TOTAL)
			used += master.used_light + master.used_equip + master.used_environ

	return used

/area/proc/clear_usage()

	master.used_equip = 0
	master.used_light = 0
	master.used_environ = 0

/area/proc/use_power(var/amount, var/chan)

	switch(chan)
		if(EQUIP)
			master.used_equip += amount
		if(LIGHT)
			master.used_light += amount
		if(ENVIRON)
			master.used_environ += amount

proc/get_doors(area/A) //Luckily for the CPU, this generally is only run once per area.
	set background = 1
	. = list()
	for(var/area/AR in A.related)
		for(var/obj/machinery/door/D in AR)
			. += D