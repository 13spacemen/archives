/obj/item/weapon/cartridge
	name = "generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	w_class = 1

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_medical = 0
	var/access_manifest = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 //Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_hydroponics = 0
	var/mode = null
	var/menu
	var/mmode = 0 //medical record viewing mode
	var/smode = 0 //Security record viewing mode???
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/message1	// used for status_displays
	var/message2

	engineering
		name = "Power-ON Cartridge"
		icon_state = "cart-e"
		access_engine = 1

	medical
		name = "Med-U Cartridge"
		icon_state = "cart-m"
		access_medical = 1

	security
		name = "R.O.B.U.S.T. Cartridge"
		icon_state = "cart-s"
		access_security = 1

		New()
			..()
			spawn(5)
				radio = new /obj/item/radio/integrated/beepsky(src)

	janitor
		name = "CustodiPRO Cartridge"
		desc = "The ultimate in clean-room design."
		icon_state = "cart-j"
		access_janitor = 1

	clown
		name = "Honkworks 5.0"
		icon_state = "cart-clown"
		access_clown = 1
		var/honk_charges = 5

	mime
		name = "Gestur-O 1000"
		icon_state = "cart-mi"
		access_mime = 1
		var/mime_charges = 5

	signal
		name = "generic signaler cartridge"
		desc = "A data cartridge with an integrated radio signaler module."

		toxins
			name = "Signal Ace 2"
			desc = "Complete with integrated radio signaler!"
			icon_state = "cart-tox"
			access_reagent_scanner = 1

		New()
			..()
			spawn(5)
				radio = new /obj/item/radio/integrated/signal(src)



	quartermaster
		name = "Space Parts & Space Vendors Cartridge"
		desc = "Perfect for the Quartermaster on the go!"
		icon_state = "cart-q"
		access_quartermaster = 1

		New()
			..()
			spawn(5)
				radio = new /obj/item/radio/integrated/mule(src)

	head
		name = "Easy-Record DELUXE"
		icon_state = "cart-h"
		access_manifest = 1
		access_engine = 1
		access_security = 1
		access_status_display = 1

	captain
		name = "Value-PAK Cartridge"
		desc = "Now with 200% more value!"
		icon_state = "cart-c"
		access_manifest = 1
		access_engine = 1
		access_security = 1
		access_medical = 1
		access_reagent_scanner = 1
		access_status_display = 1

	syndicate
		name = "Detomatix Cartridge"
		icon_state = "cart"
		access_remote_door = 1
		remote_door_id = "syndicate" //Make sure this matches the syndicate shuttle's shield/door id!!
		var/shock_charges = 4

	proc/unlock()
		if (!istype(loc, /obj/item/device/pda))
			return

		loc:mode = "cart" //Switch right to the notes program

		src.generate_menu()
		src.print_to_host(src.menu)
		return

	proc/print_to_host(var/text)
		if (!istype(loc, /obj/item/device/pda))
			return
		loc:cart = text

		for (var/mob/M in viewers(1, loc.loc))
			if (M.client && M.machine == loc)
				loc:attack_self(M)

		return

	proc/post_status(var/command, var/data1, var/data2)

		var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

		if(!frequency) return

		var/datum/signal/status_signal = new
		status_signal.source = src
		status_signal.transmission_method = 1
		status_signal.data["command"] = command

		switch(command)
			if("message")
				status_signal.data["msg1"] = data1
				status_signal.data["msg2"] = data2
			if("alert")
				status_signal.data["picture_state"] = data1
		sleep(-1)
		frequency.post_signal(src, status_signal)

	proc/generate_menu()
		switch(mode)

			if ("crew") //crew manifest

				menu = "<h4><img src=pda_notes.png> Crew Manifest</h4>"
				menu += "Entries cannot be modified from this terminal.<br><br>"

				for (var/datum/data/record/t in data_core.general)
					menu += "[t.fields["name"]] - [t.fields["rank"]]<br>"
				menu += "<br>"

			if ("power") //Muskets' power monitor
				menu = "<h4><img src=pda_power.png> Power Monitor</h4>"

				if(!powerreport)
					menu += "\red No connection"
				else
					var/list/L = list()
					for(var/obj/machinery/power/terminal/term in powerreportnodes)
						if(istype(term.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/A = term.master
							L += A

					menu += "<PRE>Total power: [powerreportavail] W<BR>Total load:  [num2text(powerreportviewload,10)] W<BR>"

					menu += "<FONT SIZE=-1>"

					if(L.len > 0)
						menu += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

						var/list/S = list(" Off","AOff","  On", " AOn")
						var/list/chg = list("N","C","F")

						for(var/obj/machinery/power/apc/A in L)
							menu += copytext(add_tspace(A.area.name, 30), 1, 30)
							menu += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

					menu += "</FONT></PRE>"

			if ("medical") //medical records
				if (!src.mmode)

					menu = "<h4><img src=pda_medical.png> Medical Record List</h4>"
					for (var/datum/data/record/R in data_core.general)
						menu += "<a href='byond://?src=\ref[src];d_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"
					menu += "<br>"

				else if (src.mmode)

					menu = "<h4><img src=pda_medical.png> Medical Record</h4>"

					menu += "<a href='byond://?src=\ref[src];pback=1'>Back</a><br>"

					if (istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1))
						menu += "Name: [src.active1.fields["name"]] ID: [src.active1.fields["id"]]<br>"
						menu += "Sex: [src.active1.fields["sex"]]<br>"
						menu += "Age: [src.active1.fields["age"]]<br>"
						menu += "Fingerprint: [src.active1.fields["fingerprint"]]<br>"
						menu += "Physical Status: [src.active1.fields["p_stat"]]<br>"
						menu += "Mental Status: [src.active1.fields["m_stat"]]<br>"
					else
						menu += "<b>Record Lost!</b><br>"

					menu += "<br>"

					menu += "<h4><img src=pda_medical.png> Medical Data</h4>"
					if (istype(src.active2, /datum/data/record) && data_core.medical.Find(src.active2))
						menu += "Blood Type: [src.active2.fields["b_type"]]<br><br>"

						menu += "Minor Disabilities: [src.active2.fields["mi_dis"]]<br>"
						menu += "Details: [src.active2.fields["mi_dis_d"]]<br><br>"

						menu += "Major Disabilities: [src.active2.fields["ma_dis"]]<br>"
						menu += "Details: [src.active2.fields["ma_dis_d"]]<br><br>"

						menu += "Allergies: [src.active2.fields["alg"]]<br>"
						menu += "Details: [src.active2.fields["alg_d"]]<br><br>"

						menu += "Current Diseases: [src.active2.fields["cdi"]]<br>"
						menu += "Details: [src.active2.fields["cdi_d"]]<br><br>"

						menu += "Important Notes: [src.active2.fields["notes"]]<br>"
					else
						menu += "<b>Record Lost!</b><br>"

					menu += "<br>"
			if ("security") //security records
				if (!src.smode)

					menu = "<h4><img src=pda_cuffs.png> Security Record List</h4>"

					for (var/datum/data/record/R in data_core.general)
						menu += "<a href='byond://?src=\ref[src];d_rec=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"

					menu += "<br>"

				else if (src.smode)

					menu = "<h4><img src=pda_cuffs.png> Security Record</h4>"

					menu += "<a href='byond://?src=\ref[src];pback=1'><img src=pda_back.png> Back</a><br>"

					if (istype(src.active1, /datum/data/record) && data_core.general.Find(src.active1))
						menu += "Name: [src.active1.fields["name"]] ID: [src.active1.fields["id"]]<br>"
						menu += "Sex: [src.active1.fields["sex"]]<br>"
						menu += "Age: [src.active1.fields["age"]]<br>"
						menu += "Fingerprint: [src.active1.fields["fingerprint"]]<br>"
						menu += "Physical Status: [src.active1.fields["p_stat"]]<br>"
						menu += "Mental Status: [src.active1.fields["m_stat"]]<br>"
					else
						menu += "<b>Record Lost!</b><br>"

					menu += "<br>"

					menu += "<h4><img src=pda_cuffs.png> Security Data</h4>"
					if (istype(src.active3, /datum/data/record) && data_core.security.Find(src.active3))
						menu += "Criminal Status: [src.active3.fields["criminal"]]<br>"

						menu += "Minor Crimes: [src.active3.fields["mi_crim"]]<br>"
						menu += "Details: [src.active3.fields["mi_crim"]]<br><br>"

						menu += "Major Crimes: [src.active3.fields["ma_crim"]]<br>"
						menu += "Details: [src.active3.fields["ma_crim_d"]]<br><br>"

						menu += "Important Notes:<br>"
						menu += "[src.active3.fields["notes"]]"
					else
						menu += "<b>Record Lost!</b><br>"

					menu += "<br>"

			if ("janitor") //janitorial locator
				menu = "<h4><img src=pda_bucket.png> Persistent Custodial Object Locator</h4>"

				var/turf/cl = get_turf(src)
				if (cl)
					menu += "Current Orbital Location: <b>\[[cl.x],[cl.y]\]</b>"

					menu += "<h4>Located Mops:</h4>"

					var/ldat
					for (var/obj/item/weapon/mop/M in world)
						var/turf/ml = get_turf(M)

						if (ml.z != cl.z)
							continue

						ldat += "Mop - <b>\[[ml.x],[ml.y]\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"

					if (!ldat)
						menu += "None"
					else
						menu += "[ldat]"

					menu += "<h4>Located Mop Buckets:</h4>"

					ldat = null
					for (var/obj/mopbucket/B in world)
						var/turf/bl = get_turf(B)

						if (bl.z != cl.z)
							continue

						ldat += "Bucket - <b>\[[bl.x],[bl.y]\]</b> - Water level: [B.reagents.total_volume]/70<br>"

					if (!ldat)
						menu += "None"
					else
						menu += "[ldat]"

					menu += "<h4>Located Cleanbots:</h4>"

					ldat = null
					for (var/obj/machinery/bot/cleanbot/B in world)
						var/turf/bl = get_turf(B)

						if (bl.z != cl.z)
							continue

						ldat += "Cleanbot - <b>\[[bl.x],[bl.y]\]</b> - [B.on ? "Online" : "Offline"]<br>"

					if (!ldat)
						menu += "None"
					else
						menu += "[ldat]"

				else
					menu += "ERROR: Unable to determine current location."

			if("signal") //signaller
				menu = "<h4><img src=pda_signaler.png> Remote Signaling System</h4>"

				menu += {"
<a href='byond://?src=\ref[src];ssend=1'>Send Signal</A><BR>
Frequency:
<a href='byond://?src=\ref[src];sfreq=-10'>-</a>
<a href='byond://?src=\ref[src];sfreq=-2'>-</a>
[format_frequency(src.radio:frequency)]
<a href='byond://?src=\ref[src];sfreq=2'>+</a>
<a href='byond://?src=\ref[src];sfreq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];scode=-5'>-</a>
<a href='byond://?src=\ref[src];scode=-1'>-</a>
[src.radio:code]
<a href='byond://?src=\ref[src];scode=1'>+</a>
<a href='byond://?src=\ref[src];scode=5'>+</a><br>"}

			if ("status") //status displays
				menu = "<h4><img src=pda_status.png> Station Status Display Interlink</h4>"

				menu += "\[ <A HREF='?src=\ref[src];statdisp=blank'>Clear</A> \]<BR>"
				menu += "\[ <A HREF='?src=\ref[src];statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
				menu += "\[ <A HREF='?src=\ref[src];statdisp=message'>Message</A> \]"
				menu += "<ul><li> Line 1: <A HREF='?src=\ref[src];statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>"
				menu += "<li> Line 2: <A HREF='?src=\ref[src];statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>"
				menu += "\[ Alert: <A HREF='?src=\ref[src];statdisp=alert;alert=default'>None</A> |"
				menu += " <A HREF='?src=\ref[src];statdisp=alert;alert=redalert'>Red Alert</A> |"
				menu += " <A HREF='?src=\ref[src];statdisp=alert;alert=lockdown'>Lockdown</A> |"
				menu += " <A HREF='?src=\ref[src];statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"

			if ("qm") //quartermaster order records
				menu = "<h4><img src=pda_crate.png> Supply Record Interlink</h4>"

				menu += "<BR><B>Supply shuttle</B><BR>"
				menu += "Location: [supply_shuttle_moving ? "Moving to station ([supply_shuttle_timeleft] Mins.)":supply_shuttle_at_station ? "Station":"Dock"]<BR>"
				menu += "Current approved orders: <BR><ol>"
				for(var/S in supply_shuttle_shoppinglist)
					var/datum/supply_order/SO = S
					menu += "<li>[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]</li>"
				menu += "</ol>"

				menu += "Current requests: <BR><ol>"
				for(var/S in supply_shuttle_requestlist)
					var/datum/supply_order/SO = S
					menu += "<li>[SO.object.name] requested by [SO.orderedby]</li>"
				menu += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."

			if ("mule") //mulebot control
				var/obj/item/radio/integrated/mule/QC = radio
				if(!QC)
					menu = "Interlink Error - Please reinsert cartridge."
					return

				menu = "<h4><img src=pda_mule.png> M.U.L.E. bot Interlink V0.8</h4>"

				if(!QC.active)
					// list of bots
					if(!QC.botlist || (QC.botlist && QC.botlist.len==0))
						menu += "No bots found.<BR>"

					else
						for(var/obj/machinery/bot/mulebot/B in QC.botlist)
							menu += "<A href='byond://?src=\ref[QC];op=control;bot=\ref[B]'>[B] at [B.loc.loc]</A><BR>"



					menu += "<BR><A href='byond://?src=\ref[QC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

				else	// bot selected, control it


					menu += "<B>[QC.active]</B><BR> Status: (<A href='byond://?src=\ref[QC];op=control;bot=\ref[QC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

					if(!QC.botstatus)
						menu += "Waiting for response...<BR>"
					else

						menu += "Location: [QC.botstatus["loca"] ]<BR>"
						menu += "Mode: "

						switch(QC.botstatus["mode"])
							if(0)
								menu += "Ready"
							if(1)
								menu += "Loading/Unloading"
							if(2)
								menu += "Navigating to Delivery Location"
							if(3)
								menu += "Navigating to Home"
							if(4)
								menu += "Waiting for clear path"
							if(5,6)
								menu += "Calculating navigation path"
							if(7)
								menu += "Unable to locate destination"
						var/obj/crate/C = QC.botstatus["load"]
						menu += "<BR>Current Load: [ !C ? "<i>none</i>" : "[C.name] (<A href='byond://?src=\ref[QC];op=unload'><i>unload</i></A>)" ]<BR>"
						menu += "Destination: [!QC.botstatus["dest"] ? "<i>none</i>" : QC.botstatus["dest"] ] (<A href='byond://?src=\ref[QC];op=setdest'><i>set</i></A>)<BR>"
						menu += "Power: [QC.botstatus["powr"]]%<BR>"
						menu += "Home: [!QC.botstatus["home"] ? "<i>none</i>" : QC.botstatus["home"] ]<BR>"
						menu += "Auto Return Home: [QC.botstatus["retn"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=retoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=reton'><i>On</i></A>) <B>Off</B>"]<BR>"
						menu += "Auto Pickup Crate: [QC.botstatus["pick"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=pickoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=pickon'><i>On</i></A>) <B>Off</B>"]<BR><BR>"

						menu += "\[<A href='byond://?src=\ref[QC];op=stop'>Stop</A>\] "
						menu += "\[<A href='byond://?src=\ref[QC];op=go'>Proceed</A>\] "
						menu += "\[<A href='byond://?src=\ref[QC];op=home'>Return Home</A>\]<BR>"
						menu += "<HR><A href='byond://?src=\ref[QC];op=botlist'><img src=pda_back.png>Return to bot list</A>"

			if ("beepsky") //beepsky control
				var/obj/item/radio/integrated/beepsky/SC = radio
				if(!SC)
					menu = "Interlink Error - Please reinsert cartridge."
					return

				menu = "<h4><img src=pda_cuffs.png> Securitron Interlink</h4>"

				if(!SC.active)
					// list of bots
					if(!SC.botlist || (SC.botlist && SC.botlist.len==0))
						menu += "No bots found.<BR>"

					else
						for(var/obj/machinery/bot/secbot/B in SC.botlist)
							menu += "<A href='byond://?src=\ref[SC];op=control;bot=\ref[B]'>[B] at [B.loc.loc]</A><BR>"



					menu += "<BR><A href='byond://?src=\ref[SC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

				else	// bot selected, control it


					menu += "<B>[SC.active]</B><BR> Status: (<A href='byond://?src=\ref[SC];op=control;bot=\ref[SC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

					if(!SC.botstatus)
						menu += "Waiting for response...<BR>"
					else

						menu += "Location: [SC.botstatus["loca"] ]<BR>"
						menu += "Mode: "

						switch(SC.botstatus["mode"])
							if(0)
								menu += "Ready"
							if(1)
								menu += "Apprehending target"
							if(2,3)
								menu += "Arresting target"
							if(4)
								menu += "Starting patrol"
							if(5)
								menu += "On patrol"
							if(6)
								menu += "Responding to summons"

						menu += "<BR>\[<A href='byond://?src=\ref[SC];op=stop'>Stop Patrol</A>\] "
						menu += "\[<A href='byond://?src=\ref[SC];op=go'>Start Patrol</A>\] "
						menu += "\[<A href='byond://?src=\ref[SC];op=summon'>Summon Bot</A>\]<BR>"
						menu += "<HR><A href='byond://?src=\ref[SC];op=botlist'><img src=pda_back.png>Return to bot list</A>"

/obj/item/weapon/cartridge/Topic(href, href_list)
	..()

	if (usr.stat || usr.restrained() || !in_range(src.loc, usr))
		return

	if (href_list["d_rec"])
		var/datum/data/record/R = locate(href_list["d_rec"])
		var/datum/data/record/M = locate(href_list["d_rec"])
		var/datum/data/record/S = locate(href_list["d_rec"])

		if (data_core.general.Find(R))
			for (var/datum/data/record/E in data_core.medical)
				if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
					M = E
					break

			for (var/datum/data/record/E in data_core.security)
				if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
					S = E
					break

			src.active1 = R
			src.active2 = M
			src.active3 = S

		if (src.mode == "medical")
			src.mmode = 1
		else
			src.smode = 1

	else if (href_list["pback"])
		if (src.mode == "medical")
			src.mmode = 0
		if (src.mode == "security")
			src.smode = 0
			loc:tmode = !loc:tmode


	else if ((href_list["ssend"]) && (istype(src,/obj/item/weapon/cartridge/signal)))
		for(var/obj/item/assembly/r_i_ptank/R in world) //Bomblist stuff
			if((R.part1.code == src/radio:code) && (R.part1.frequency == src.radio:frequency))
				bombers += "[key_name(usr)] has activated a radio bomb (Freq: [format_frequency(src.radio:frequency)], Code: [src.radio:code]). Temp = [R.part3.air_contents.temperature-T0C]."
		spawn( 0 )
			src.radio:send_signal("ACTIVATE")
			return

	else if ((href_list["sfreq"]) && (istype(src,/obj/item/weapon/cartridge/signal)))
		var/new_frequency = sanitize_frequency(src.radio:frequency + text2num(href_list["sfreq"]))
		src.radio:set_frequency(new_frequency)

	else if ((href_list["scode"]) && (istype(src,/obj/item/weapon/cartridge/signal)))
		src.radio:code += text2num(href_list["scode"])
		src.radio:code = round(src.radio:code)
		src.radio:code = min(100, src.radio:code)
		src.radio:code = max(1, src.radio:code)

	else if (href_list["statdisp"] && access_status_display)

		switch(href_list["statdisp"])
			if("message")
				post_status("message", message1, message2)
			if("alert")
				post_status("alert", href_list["alert"])

			if("setmsg1")
				message1 = input("Line 1", "Enter Message Text", message1) as text|null
				src.updateSelfDialog()
			if("setmsg2")
				message2 = input("Line 2", "Enter Message Text", message2) as text|null
				src.updateSelfDialog()
			else
				post_status(href_list["statdisp"])

	src.generate_menu()
	src.print_to_host(src.menu)
