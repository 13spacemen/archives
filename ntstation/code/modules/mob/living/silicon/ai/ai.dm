var/list/ai_list = list()

//Not sure why this is necessary...
/proc/AutoUpdateAI(obj/subject)
	var/is_in_use = 0
	if (subject!=null)
		for(var/A in ai_list)
			var/mob/living/silicon/ai/M = A
			if ((M.client && M.machine == subject))
				is_in_use = 1
				subject.attack_ai(M)
	return is_in_use


/mob/living/silicon/ai
	name = "AI"
	icon = 'icons/mob/AI.dmi'//
	icon_state = "ai"
	anchored = 1
	density = 1
	status_flags = CANSTUN|CANPARALYSE|CANPUSH
	var/list/network = list("SS13")
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())
	var/viewalerts = 0
	var/icon/holo_icon//Default is assigned when AI is created.
	var/obj/item/device/pda/ai/aiPDA = null
	var/obj/item/device/multitool/aiMulti = null
	var/obj/item/device/radio/headset/heads/ai_integrated/radio = null
	var/obj/item/device/camera/ai_camera/aicamera = null
	var/obj/machinery/bot/Bot = null

	//MALFUNCTION
	var/datum/module_picker/malf_picker
	var/processing_time = 100
	var/list/datum/AI_Module/current_modules = list()
	var/fire_res_on_core = 0
	var/malf_cooldown = 0

	var/control_disabled = 0 // Set to 1 to stop AI from interacting via Click()
	var/malfhacking = 0 // More or less a copy of the above var, so that malf AIs can hack and still get new cyborgs -- NeoFite

	var/obj/machinery/power/apc/malfhack = null
	var/explosive = 0 //does the AI explode when it dies?

	var/mob/living/silicon/ai/parent = null
	var/camera_light_on = 0
	var/list/obj/machinery/camera/lit_cameras = list()
	var/datum/trackable/track = new()

	var/last_paper_seen = null
	var/can_shunt = 1
	var/last_announcement = "" // For AI VOX, if enabled
	var/turf/waypoint //Holds the turf of the currently selected waypoint.
	var/waypoint_mode = 0 //Waypoint mode is for selecting a turf via clicking.

/mob/living/silicon/ai/New(loc, var/datum/ai_laws/L, var/obj/item/device/mmi/B, var/safety = 0)
	var/list/possibleNames = ai_names

	var/pickedName = null
	while(!pickedName)
		pickedName = pick(ai_names)
		for (var/mob/living/silicon/ai/A in mob_list)
			if (A.real_name == pickedName && possibleNames.len > 1) //fixing the theoretically possible infinite loop
				possibleNames -= pickedName
				pickedName = null

	real_name = pickedName
	name = real_name
	anchored = 1
	canmove = 0
	density = 1
	loc = loc

	holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))

	if(L)
		if (istype(L, /datum/ai_laws))
			laws = L
	else
		make_laws()

	verbs += /mob/living/silicon/ai/proc/show_laws_verb

	aiPDA = new/obj/item/device/pda/ai(src)
	aiPDA.owner = name
	aiPDA.ownjob = "AI"
	aiPDA.name = name + " (" + aiPDA.ownjob + ")"

	aiMulti = new(src)
	radio = new(src)
	radio.myAi = src
	aicamera = new/obj/item/device/camera/ai_camera(src)

	if (istype(loc, /turf))
		verbs.Add(/mob/living/silicon/ai/proc/ai_network_change, \
		/mob/living/silicon/ai/proc/ai_statuschange, /mob/living/silicon/ai/proc/ai_hologram_change, \
		/mob/living/silicon/ai/proc/botcall, /mob/living/silicon/ai/proc/control_integrateed_radio)

	if(!safety)//Only used by AIize() to successfully spawn an AI.
		if (!B)//If there is no player/brain inside.
			new/obj/structure/AIcore/deactivated(loc)//New empty terminal.
			qdel(src)//Delete AI.
			return
		else
			if (B.brainmob.mind)
				B.brainmob.mind.transfer_to(src)

			src << "<B>You are playing the station's AI. The AI cannot move, but can interact with many objects while viewing them (through cameras).</B>"
			src << "<B>To look at other parts of the station, click on yourself to get a camera menu.</B>"
			src << "<B>While observing through a camera, you can use most (networked) devices which you can see, such as computers, APCs, intercoms, doors, etc.</B>"
			src << "To use something, simply click on it."
			src << "Use say :b to speak to your cyborgs through binary."
			if (!(ticker && ticker.mode && (mind in ticker.mode.malf_ai)))
				show_laws()
				src << "<b>These laws may be changed by other players, or by you being the traitor.</b>"

			job = "AI"
	ai_list += src
	shuttle_caller_list += src
	..()
	return

/mob/living/silicon/ai/Destroy()
	ai_list -= src
	shuttle_caller_list -= src
	emergency_shuttle.autoshuttlecall()
	..()


/mob/living/silicon/ai/verb/pick_icon()
	set category = "AI Commands"
	set name = "Set AI Core Display"
	if(stat || aiRestorePowerRoutine)
		return

		//if(icon_state == initial(icon_state))
	var/icontype = input("Please, select a display!", "AI", null/*, null*/) in list("Clown", "Monochrome", "Blue", "Inverted", "Firewall", "Green", "Red", "Static", "Red October", "Hades", "Helios", "House", "President", "Gigyas", "Yuki", "SyndicatMeow", "Heartline", "Alter Ego", "Triumvirate", "Triumvirate-M", "Urist", "Text", "Smiley", "Matrix", "Dorf", "Bliss", "Completely Normal Not-Malf AI", "Fuzz", "Goon", "Database", "Glitchman", "AmericAI", "Nanotrasen", "Gentoo")
	if(icontype == "Clown")
		icon_state = "ai-clown2"
	else if(icontype == "Monochrome")
		icon_state = "ai-mono"
	else if(icontype == "Blue")
		icon_state = "ai"
	else if(icontype == "Inverted")
		icon_state = "ai-u"
	else if(icontype == "Firewall")
		icon_state = "ai-magma"
	else if(icontype == "Green")
		icon_state = "ai-wierd"
	else if(icontype == "Red")
		icon_state = "ai-malf"
	else if(icontype == "Static")
		icon_state = "ai-static"
	else if(icontype == "Red October")
		icon_state = "ai-redoctober"
	else if(icontype == "Hades")
		icon_state = "ai-hades"
	else if(icontype == "Helios")
		icon_state = "ai-helios"
	else if(icontype == "House")
		icon_state = "ai-house"
	else if(icontype == "President")
		icon_state = "ai-pres"
	else if(icontype == "Gigyas")
		icon_state = "ai-gigyas"
	else if(icontype == "Yuki")
		icon_state = "ai-yuki"
	else if(icontype == "SyndicatMeow")
		icon_state = "ai-syndicatmeow"
	else if(icontype == "Heartline")
		icon_state = "ai-heartline"
	else if (icontype == "Alter Ego")
		icon_state = "ai-alterego"
	else if (icontype == "Triumvirate")
		icon_state = "ai-triumvirate"
	else if (icontype == "Triumvirate-M")
		icon_state = "ai-triumvirate-malf"
	else if (icontype == "Urist")
		icon_state = "ai-toodeep"
	else if (icontype == "Text")
		icon_state = "ai-text"
	else if (icontype == "Smiley")
		icon_state = "ai-smiley"
	else if (icontype == "Matrix")
		icon_state = "ai-matrix"
	else if (icontype == "Dorf")
		icon_state = "ai-dorf"
	else if (icontype == "Bliss")
		icon_state = "ai-bliss"
	else if (icontype == "Completely Normal Not-Malf AI")
		icon_state = "ai-notmalf"
	else if (icontype == "Fuzz")
		icon_state = "ai-fuzz"
	else if (icontype == "Goon")
		icon_state = "ai-goon"
	else if (icontype == "Database")
		icon_state = "ai-database"
	else if (icontype == "Glitchman")
		icon_state = "ai-glitchman"
	else if (icontype == "AmericAI")
		icon_state = "ai-murica"
	else if (icontype == "Nanotrasen")
		icon_state = "ai-nanotrasen"
	else if (icontype == "Gentoo")
		icon_state = "ai-gentoo"
	//else
			//usr <<"You can only change your display once!"
			//return

/mob/living/silicon/ai/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		if(ticker.mode.name == "AI malfunction")
			var/datum/game_mode/malfunction/malf = ticker.mode
			for (var/datum/mind/malfai in malf.malf_ai)
				if (mind == malfai)
					if (malf.apcs >= 3)
						stat(null, "Time until station control secured: [max(malf.AI_win_timeleft/(malf.apcs/3), 0)] seconds")

		if(!stat)
			stat(null, text("System integrity: [(health+100)/2]%"))
		else
			stat(null, text("Systems nonfunctional"))

/mob/living/silicon/ai/proc/ai_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=aialerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/C = alm[2]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				if (C && istype(C, /list))
					var/dat2 = ""
					for (var/obj/machinery/camera/I in C)
						dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (dat2=="") ? "" : " | ", src, I, I.c_tag)
					dat += text("-- [] ([])", A.name, (dat2!="") ? dat2 : "No Camera")
				else if (C && istype(C, /obj/machinery/camera))
					var/obj/machinery/camera/Ctmp = C
					dat += text("-- [] (<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>)", A.name, src, C, Ctmp.c_tag)
				else
					dat += text("-- [] (No Camera)", A.name)
				if (sources.len > 1)
					dat += text("- [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=aialerts&can_close=0")

/mob/living/silicon/ai/proc/ai_roster()
	var/dat = "<html><head><title>Crew Roster</title></head><body><b>Crew Roster:</b><br><br>"

	for(var/datum/data/record/t in sortRecord(data_core.general))
		dat += t.fields["name"] + " - " + t.fields["rank"] + "<br>"
	dat += "</body></html>"

	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/ai/proc/ai_call_shuttle()
	if(src.stat == 2)
		src << "You can't call the shuttle because you are dead!"
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			usr << "Wireless control is disabled!"
			return

	var/reason = input(src, "What is the nature of your emergency? ([CALL_SHUTTLE_REASON_LENGTH] characters required.)", "Confirm Shuttle Call") as text

	if(length(trim(reason)) > 0)
		call_shuttle_proc(src, reason)

	// hack to display shuttle timer
	if(emergency_shuttle.online)
		var/obj/machinery/computer/communications/C = locate() in machines
		if(C)
			C.post_status("shuttle")

	return

/mob/living/silicon/ai/cancel_camera()
	src.view_core()

/mob/living/silicon/ai/verb/toggle_anchor()
        set category = "AI Commands"
        set name = "Toggle Floor Bolts"
        if(!isturf(loc)) // if their location isn't a turf
                return // stop
        anchored = !anchored // Toggles the anchor

        src << "[anchored ? "<b>You are now anchored.</b>" : "<b>You are now unanchored.</b>"]"
        // the message in the [] will change depending whether or not the AI is anchored

/mob/living/silicon/ai/update_canmove() //If the AI dies, mobs won't go through it anymore
	return 0

/mob/living/silicon/ai/proc/ai_cancel_call()
	set category = "AI Commands"
	if(src.stat == 2)
		src << "You can't send the shuttle back because you are dead!"
		return
	if(istype(usr,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = src
		if(AI.control_disabled)
			src	 << "Wireless control is disabled!"
			return
	cancel_call_proc(src)
	return

/mob/living/silicon/ai/check_eye(var/mob/user as mob)
	if (!current)
		return null
	user.reset_view(current)
	return 1

/mob/living/silicon/ai/blob_act()
	if (stat != 2)
		adjustBruteLoss(60)
		updatehealth()
		return 1
	return 0

/mob/living/silicon/ai/restrained()
	return 0

/mob/living/silicon/ai/emp_act(severity)
	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				ai_call_shuttle()
	..()

/mob/living/silicon/ai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			gib()
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)

	return


/mob/living/silicon/ai/Topic(href, href_list)
	if(usr != src)
		return
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "aialerts")
			viewalerts = 0
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)
	if (href_list["switchcamera"])
		switchCamera(locate(href_list["switchcamera"])) in cameranet.cameras
	if (href_list["showalerts"])
		ai_alerts()
#ifdef AI_VOX
	if(href_list["say_word"])
		play_vox_word(href_list["say_word"], null, src)
		return
#endif
	if(href_list["show_paper"])
		if(last_paper_seen)
			src << browse(last_paper_seen, "window=show_paper")
	//Carn: holopad requests
	if (href_list["jumptoholopad"])
		var/obj/machinery/hologram/holopad/H = locate(href_list["jumptoholopad"])
		if(stat == CONSCIOUS)
			if(H)
				H.attack_ai(src) //may as well recycle
			else
				src << "<span class='notice'>Unable to locate the holopad.</span>"
	if (href_list["track"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)
			A.ai_actual_track(target)
		return

	if (href_list["callbot"]) //Command a bot to move to a selected location.
		Bot = locate(href_list["callbot"]) in machines
		if(!Bot || Bot.remote_disabled || src.control_disabled)
			return //True if there is no bot found, the bot is manually emagged, or the AI is carded with wireless off.
		waypoint_mode = 1
		src << "<span class='notice'>Set your waypoint by clicking on a valid location free of obstructions.</span>"
		return

	if (href_list["interface"]) //Remotely connect to a bot!
		Bot = locate(href_list["interface"]) in machines
		if(!Bot || Bot.remote_disabled || src.control_disabled)
			return
		Bot.attack_ai(src)

	if (href_list["botrefresh"]) //Refreshes the bot control panel.
		botcall()
		return

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"]) in mob_list
		var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(A && target)

			A.cameraFollow = target
			A << text("Now tracking [] on camera.", target.name)
			if (usr.machine == null)
				usr.machine = usr

			while (src.cameraFollow == target)
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40)
				continue
		return
	return

/mob/living/silicon/ai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	updatehealth()
	return 2

/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)

		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src]'s plating with its scythe like arm."), 1)

		else //harm
			var/damage = rand(10, 20)
			if (prob(90))
				playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
				if(prob(8))
					flick("noise", flash)
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] took a swipe at []!</B>", M, src), 1)
	return

/mob/living/silicon/ai/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		add_logs(M, src, "attacked", admin=0)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/silicon/ai/reset_view(atom/A)
	if (camera_light_on)
		light_cameras()
	if(istype(A,/obj/machinery/camera))
		current = A
	..()


/mob/living/silicon/ai/proc/switchCamera(var/obj/machinery/camera/C)

	src.cameraFollow = null

	if (!C || stat == 2) //C.can_use())
		return 0

	if(!src.eyeobj)
		view_core()
		return
	// ok, we're alive, camera is good and in our network...
	eyeobj.setLoc(get_turf(C))
	//machine = src

	return 1

/mob/living/silicon/ai/proc/botcall()
	set category = "AI Commands"
	set name = "Access Robot Control"
	set desc = "Wirelessly control various automatic robots."
	if(stat == 2)
		src << "<span class='danger'>Critical error. System offline.</span>"
		return

	if(control_disabled)
		src << "Wireless communication is disabled."
		return
	var/turf/ai_current_turf = get_turf(src)
	var/ai_Zlevel = ai_current_turf.z
	var/d
	var/area/bot_area
	d += "<A HREF=?src=\ref[src];botrefresh=\ref[Bot]>Query network status</A><br>"
	d += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Status</h3></td><td width='30%'><h3>Location</h3></td><td width='10%'><h3>Control</h3></td></tr>"

	for (Bot in machines)
		if(Bot.z == ai_Zlevel && !Bot.remote_disabled) //Only non-emagged bots on the same Z-level are detected!
			bot_area = get_area(Bot)
			d += "<tr><td width='30%'>[Bot.hacked ? "<span class='bad'>(!) </span>[Bot.name]" : Bot.name]</td>"
			//If the bot is on, it will display the bot's current mode status. If the bot is not mode, it will just report "Idle". "Inactive if it is not on at all.
			d += "<td width='30%'>[Bot.on ? "[Bot.mode ? "<span class='average'>[ Bot.mode_name[Bot.mode] ]</span>": "<span class='good'>Idle</span>"]" : "<span class='bad'>Inactive</span>"]</td>"
			d += "<td width='30%'>[bot_area.name]</td>"
			d += "<td width='10%'><A HREF=?src=\ref[src];interface=\ref[Bot]>Interface</A></td>"
			d += "<td width='10%'><A HREF=?src=\ref[src];callbot=\ref[Bot]>Call</A></td>"
			d += "</tr>"
			d = format_text(d)

	var/datum/browser/popup = new(src, "botcall", "Remote Robot Control", 700, 400)
	popup.set_content(d)
	popup.open()

/mob/living/silicon/ai/proc/set_waypoint(var/atom/A)
	var/turf/turf_check = get_turf(A)
		//The target must be in view of a camera or near the core.
	if(turf_check in range(get_turf(src)))
		call_bot(turf_check)
	else if(cameranet && cameranet.checkTurfVis(turf_check))
		call_bot(turf_check)
	else
		src << "<span class='danger'>Selected location is not visible.</span>"

/mob/living/silicon/ai/proc/call_bot(var/turf/end_loc)

	if(!Bot)
		return

	if(Bot.calling_ai && Bot.calling_ai != src) //Prevents an override if another AI is controlling this bot.
		src << "<span class='danger'>Interface error. Unit is already in use.</span>"
		return

	var/area/end_area = get_area(end_loc)
	var/turf/start_loc = get_turf(Bot) //Get the bot's location.

	//For giving the bot all-access.
	var/obj/item/weapon/card/id/all_access = new /obj/item/weapon/card/id
	var/datum/job/captain/All = new/datum/job/captain
	all_access.access = All.get_access()

	var/list/call_path = list()
	call_path = AStar(start_loc, end_loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 150, id=all_access)

	if(call_path && call_path.len) //Ensures that a valid path is calculated!
		if(!Bot.on)
			Bot.turn_on() //Saves the AI the hassle of having to activate a bot manually.
		Bot.bot_reset() //Reset a bot becore setting it to call mode.
		Bot.pathset = 0 //Forces the bot to accept a new rute if already under an AI call.
		Bot.call_path = call_path //Send the path to the bot!
		Bot.botcard = all_access //Give the bot all-access while under the AI's command.
		Bot.calling_ai = src //Link the AI to the bot!
		src << "<span class='notice'>[Bot.name] called to [end_area.name]. [call_path.len-1] meters to destination.</span>"
	else
		src << "<span class='danger'>Failed to calculate a valid route. Ensure destination is clear of obstructions and within range.</span>"

/mob/living/silicon/ai/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = alarms[class]
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
	if (O)
		if (C && C.can_use())
			queueAlarm("--- [class] alarm detected in [A.name]! (<A HREF=?src=\ref[src];switchcamera=\ref[C]>[C.c_tag]</A>)", class)
		else if (CL && CL.len)
			var/foo = 0
			var/dat2 = ""
			for (var/obj/machinery/camera/I in CL)
				dat2 += text("[]<A HREF=?src=\ref[];switchcamera=\ref[]>[]</A>", (!foo) ? "" : " | ", src, I, I.c_tag)	//I'm not fixing this shit...
				foo = 1
			queueAlarm(text ("--- [] alarm detected in []! ([])", class, A.name, dat2), class)
		else
			queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	else
		queueAlarm(text("--- [] alarm detected in []! (No Camera)", class, A.name), class)
	if (viewalerts) ai_alerts()
	return 1

/mob/living/silicon/ai/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
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
	if (cleared)
		queueAlarm(text("--- [] alarm in [] has been cleared.", class, A.name), class, 0)
		if (viewalerts) ai_alerts()
	return !cleared

//Replaces /mob/living/silicon/ai/verb/change_network() in ai.dm & camera.dm
//Adds in /mob/living/silicon/ai/proc/ai_network_change() instead
//Addition by Mord_Sith to define AI's network change ability
/mob/living/silicon/ai/proc/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"
	unset_machine()
	src.cameraFollow = null
	var/cameralist[0]

	if(usr.stat == 2)
		usr << "You can't change your camera network because you are dead!"
		return

	var/mob/living/silicon/ai/U = usr

	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!C.can_use())
			continue

		var/list/tempnetwork = C.network
		tempnetwork.Remove("CREED", "thunder", "RD", "toxins", "Prison")
		if(tempnetwork.len)
			for(var/i in C.network)
				cameralist[i] = i
	var/old_network = network
	network = input(U, "Which network would you like to view?") as null|anything in cameralist

	if(!U.eyeobj)
		U.view_core()
		return

	if(isnull(network))
		network = old_network // If nothing is selected
	else
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!C.can_use())
				continue
			if(network in C.network)
				U.eyeobj.setLoc(get_turf(C))
				break
	src << "\blue Switched to [network] camera network."
//End of code by Mord_Sith


/mob/living/silicon/ai/proc/choose_modules()
	set category = "Malfunction"
	set name = "Choose Module"

	malf_picker.use(src)

/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI Status"

	if(usr.stat == 2)
		usr <<"You cannot change your emotional status because you are dead!"
		return
	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow","Little Happy","Tongue","Loading","Angry","Love")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/obj/machinery/M in machines) //change status
		if(istype(M, /obj/machinery/ai_status_display))
			var/obj/machinery/ai_status_display/AISD = M
			AISD.emotion = emote
		//if Friend Computer, change ALL displays
		else if(istype(M, /obj/machinery/status_display))

			var/obj/machinery/status_display/SD = M
			if(emote=="Friend Computer")
				SD.friendc = 1
			else
				SD.friendc = 0
	return

//I am the icon meister. Bow fefore me.	//>fefore
/mob/living/silicon/ai/proc/ai_hologram_change()
	set name = "Change Hologram"
	set desc = "Change the default hologram available to AI to something else."
	set category = "AI Commands"

	var/input
	if(alert("Would you like to select a hologram based on a crew member or switch to unique avatar?",,"Crew Member","Unique")=="Crew Member")

		var/personnel_list[] = list()

		for(var/datum/data/record/t in data_core.locked)//Look in data core locked.
			personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["image"]//Pull names, rank, and image.

		if(personnel_list.len)
			input = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[input]
			if(character_icon)
				del(holo_icon)//Clear old icon so we're not storing it in memory.
				holo_icon = getHologramIcon(icon(character_icon))
		else
			alert("No suitable records found. Aborting.")

	else
		var/icon_list[] = list(
		"default",
		"floating face",
		"xeno queen"
		)
		input = input("Please select a hologram:") as null|anything in icon_list
		if(input)
			del(holo_icon)
			switch(input)
				if("default")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo1"))
				if("floating face")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo2"))
				if("xeno queen")
					holo_icon = getHologramIcon(icon('icons/mob/AI.dmi',"holo3"))
	return

/mob/living/silicon/ai/proc/corereturn()
	set category = "Malfunction"
	set name = "Return to Main Core"

	var/obj/machinery/power/apc/apc = src.loc
	if(!istype(apc))
		src << "\blue You are already in your Main Core."
		return
	apc.malfvacate()

/mob/living/silicon/ai/proc/toggle_camera_light()
	if(stat != CONSCIOUS)
		return

	camera_light_on = !camera_light_on

	if (!camera_light_on)
		src << "Camera lights deactivated."

		for (var/obj/machinery/camera/C in lit_cameras)
			C.SetLuminosity(0)
			lit_cameras = list()

		return

	light_cameras()

	src << "Camera lights activated."
	return

//AI_CAMERA_LUMINOSITY

/mob/living/silicon/ai/proc/light_cameras()
	var/list/obj/machinery/camera/add = list()
	var/list/obj/machinery/camera/remove = list()
	var/list/obj/machinery/camera/visible = list()
	for (var/datum/camerachunk/CC in eyeobj.visibleCameraChunks)
		for (var/obj/machinery/camera/C in CC.cameras)
			if (!C.can_use() || C.light_disabled || get_dist(C, eyeobj) > 7)
				continue
			visible |= C

	add = visible - lit_cameras
	remove = lit_cameras - visible

	for (var/obj/machinery/camera/C in remove)
		C.SetLuminosity(0)
		lit_cameras -= C
	for (var/obj/machinery/camera/C in add)
		C.SetLuminosity(AI_CAMERA_LUMINOSITY)
		lit_cameras |= C

/mob/living/silicon/ai/verb/outputlaws()
	set category = "AI Commands"
	set name = "State Laws"

	checklaws()

/mob/living/silicon/ai/proc/control_integrateed_radio()
	set name = "Radio Settings"
	set desc = "Allows you to change settings of your radio."
	set category = "AI Commands"

	src << "Accessing Subspace Transceiver control..."
	if (src.radio)
		src.radio.interact(src)