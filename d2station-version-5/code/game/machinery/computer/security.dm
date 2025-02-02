/obj/machinery/computer/secure_data/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/computerframe/A = new /obj/computerframe( loc )
				new /obj/item/weapon/shard( loc )
				var/obj/item/weapon/circuitboard/secure_data/M = new /obj/item/weapon/circuitboard/secure_data( A )
				for (var/obj/C in src)
					C.loc = loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/computerframe/A = new /obj/computerframe( loc )
				var/obj/item/weapon/circuitboard/secure_data/M = new /obj/item/weapon/circuitboard/secure_data( A )
				for (var/obj/C in src)
					C.loc = loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		attack_hand(user)
	return

/obj/machinery/computer/secure_data/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/secure_data/attack_paw(mob/user as mob)
	return attack_hand(user)

//Someone needs to break down the dat += into chunks instead of long ass lines.
/obj/machinery/computer/secure_data/attack_hand(mob/user as mob)
	if(..())
		return
	var/dat
	if (temp)
		dat = text("<TT>[]</TT><BR><BR><A href='?src=\ref[];choice=Clear Screen'>Clear Screen</A>", temp, src)
	else
		dat = text("Confirm Identity: <A href='?src=\ref[];choice=Confirm Identity'>[]</A><HR>", src, (scan ? text("[]", scan.name) : "----------"))
		if (authenticated)
			switch(screen)
				if(1.0)
					dat += text("<A href='?src=\ref[];choice=Search Records'>Search Records</A><BR>\n<A href='?src=\ref[];choice=List Records'>List Records</A><BR>\n<A href='?src=\ref[];choice=Search Fingerprints'>Search Fingerprints</A><BR>\n<A href='?src=\ref[];choice=New Record (General)'>New General Record</A><BR>\n<BR>\n<A href='?src=\ref[];choice=Record Maintenance'>Record Maintenance</A><BR>\n<A href='?src=\ref[];choice=Log Out'>{Log Out}</A><BR>\n", src, src, src, src, src, src)
				if(2.0)
					dat += "<B>Record List</B>:<HR>"
					for(var/datum/data/record/R in data_core.general)
						dat += text("<A href='?src=\ref[];choice=Browse Record;d_rec=\ref[]'>[]: []<BR>", src, R, R.fields["id"], R.fields["name"])
					dat += text("<HR><A href='?src=\ref[];choice=Return'>Back</A>", src)
				if(3.0)
					dat += text("<B>Records Maintenance</B><HR>\n<A href='?src=\ref[];choice=Delete All Records'>Delete All Records</A><BR>\n<BR>\n<A href='?src=\ref[];choice=Return'>Back</A>", src, src)
				if(4.0)
					dat += "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						dat += text("Name: <A href='?src=\ref[];choice=Edit Field;field=name'>[]</A> ID: <A href='?src=\ref[];choice=Edit Field;field=id'>[]</A><BR>\nSex: <A href='?src=\ref[];choice=Edit Field;field=sex'>[]</A><BR>\nAge: <A href='?src=\ref[];choice=Edit Field;field=age'>[]</A><BR>\nRank: <A href='?src=\ref[];choice=Edit Field;field=rank'>[]</A><BR>\nFingerprint: <A href='?src=\ref[];choice=Edit Field;field=fingerprint'>[]</A><BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", src, active1.fields["name"], src, active1.fields["id"], src, active1.fields["sex"], src, active1.fields["age"], src, active1.fields["rank"], src, active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						dat += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						dat += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: <A href='?src=\ref[];choice=Edit Field;field=criminal'>[]</A><BR>\n<BR>\nMinor Crimes: <A href='?src=\ref[];choice=Edit Field;field=mi_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];choice=Edit Field;field=mi_crim_d'>[]</A><BR>\n<BR>\nMajor Crimes: <A href='?src=\ref[];choice=Edit Field;field=ma_crim'>[]</A><BR>\nDetails: <A href='?src=\ref[];choice=Edit Field;field=ma_crim_d'>[]</A><BR>\n<BR>\nImportant Notes:<BR>\n\t<A href='?src=\ref[];choice=Edit Field;field=notes'>[]</A><BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", src, active2.fields["criminal"], src, active2.fields["mi_crim"], src, active2.fields["mi_crim_d"], src, active2.fields["ma_crim"], src, active2.fields["ma_crim_d"], src, active2.fields["notes"])
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							dat += text("[]<BR><A href='?src=\ref[];choice=Delete Entry;del_c=[]'>Delete Entry</A><BR><BR>", active2.fields[text("com_[]", counter)], src, counter)
							counter++
						dat += text("<A href='?src=\ref[];choice=Add Entry'>Add Entry</A><BR><BR>", src)
						dat += text("<A href='?src=\ref[];choice=Delete Record (Security)'>Delete Record (Security Only)</A><BR><BR>", src)
					else
						dat += "<B>Security Record Lost!</B><BR>"
						dat += text("<A href='?src=\ref[];choice=New Record (Security)'>New Security Record</A><BR><BR>", src)
					dat += text("\n<A href='?src=\ref[];choice=Delete Record (ALL)'>Delete Record (ALL)</A><BR><BR>\n<A href='?src=\ref[];choice=Print Record'>Print Record</A><BR>\n<A href='?src=\ref[];choice=Return'>Back</A><BR>", src, src, src)
				else
		else
			dat += text("<A href='?src=\ref[];choice=Log In'>{Log In}</A>", src)
	user << browse(text("<HEAD><link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' /><TITLE>Security Records</TITLE></HEAD><TT>[]</TT>", dat), "window=secure_rec")
	onclose(user, "secure_rec")
	return

/*Revised /N
I can't be bothered to look more of the actual code outside of switch but that probably needs revising too.
What a mess.*/
/obj/machinery/computer/secure_data/Topic(href, href_list)
	if(..())
		return
	if (!( data_core.general.Find(active1) ))
		active1 = null
	if (!( data_core.security.Find(active2) ))
		active2 = null
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		switch(href_list["choice"])
//BASIC FUNCTIONS
			if("Clear Screen")
				temp = null

			if ("Return")
				screen = 1
				active1 = null
				active2 = null

			if("Confirm Identity")
				if (scan)
					scan.loc = loc
					scan = null
				else
					var/obj/item/I = usr.equipped()
					if (istype(I, /obj/item/weapon/card/id))
						usr.drop_item()
						I.loc = src
						scan = I

			if("Log Out")
				authenticated = null
				screen = null
				active1 = null
				active2 = null

			if("Log In")
				if (istype(usr, /mob/living/silicon))
					active1 = null
					active2 = null
					authenticated = 1
					rank = "AI"
					screen = 1
				else if (istype(scan, /obj/item/weapon/card/id))
					active1 = null
					active2 = null
					if(check_access(scan))
						authenticated = scan.registered
						rank = scan.assignment
						screen = 1
//RECORD FUNCTIONS
			if("List Records")
				screen = 2
				active1 = null
				active2 = null

			if("Search Records")
				var/t1 = strip_html(input("Search String: (Name or ID)", "Secure. records", null, null))  as text
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || !in_range(src, usr)))
					return
				active1 = null
				active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in data_core.general)
					if ((lowertext(R.fields["name"]) == t1 || t1 == lowertext(R.fields["id"])))
						active1 = R
				if (!( active1 ))
					temp = text("Could not locate record [].", t1)
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == active1.fields["name"] || E.fields["id"] == active1.fields["id"]))
							active2 = E
					screen = 4

			if("Record Maintenance")
				screen = 3
				active1 = null
				active2 = null

			if ("Browse Record")
				var/datum/data/record/R = locate(href_list["d_rec"])
				var/S = locate(href_list["d_rec"])
				if (!( data_core.general.Find(R) ))
					temp = "Record Not Found!"
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
							S = E
					active1 = R
					active2 = S
					screen = 4

			if ("Search Fingerprints")
				var/t1 = strip_html(input("Search String: (Fingerprint)", "Secure. records", null, null))  as text
				if ((!( t1 ) || usr.stat || !( authenticated ) || usr.restrained() || (!in_range(src, usr)) && (!istype(usr, /mob/living/silicon))))
					return
				active1 = null
				active2 = null
				t1 = lowertext(t1)
				for(var/datum/data/record/R in data_core.general)
					if (lowertext(R.fields["fingerprint"]) == t1)
						active1 = R
					else
						//Foreach continue //goto(3414)
				if (!( active1 ))
					temp = text("Could not locate record [].", t1)
				else
					for(var/datum/data/record/E in data_core.security)
						if ((E.fields["name"] == active1.fields["name"] || E.fields["id"] == active1.fields["id"]))
							active2 = E
					screen = 4

			if ("Print Record")
				if (!( printing ))
					printing = 1
					sleep(50)
					var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( loc )
					P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
					if ((istype(active1, /datum/data/record) && data_core.general.Find(active1)))
						P.info += text("Name: [] ID: []<BR>\nSex: []<BR>\nAge: []<BR>\nFingerprint: []<BR>\nPhysical Status: []<BR>\nMental Status: []<BR>", active1.fields["name"], active1.fields["id"], active1.fields["sex"], active1.fields["age"], active1.fields["fingerprint"], active1.fields["p_stat"], active1.fields["m_stat"])
					else
						P.info += "<B>General Record Lost!</B><BR>"
					if ((istype(active2, /datum/data/record) && data_core.security.Find(active2)))
						P.info += text("<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: []<BR>\n<BR>\nMinor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nMajor Crimes: []<BR>\nDetails: []<BR>\n<BR>\nImportant Notes:<BR>\n\t[]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>", active2.fields["criminal"], active2.fields["mi_crim"], active2.fields["mi_crim_d"], active2.fields["ma_crim"], active2.fields["ma_crim_d"], active2.fields["notes"])
						var/counter = 1
						while(active2.fields[text("com_[]", counter)])
							P.info += text("[]<BR>", active2.fields[text("com_[]", counter)])
							counter++
					else
						P.info += "<B>Security Record Lost!</B><BR>"
					P.info += "</TT>"
					P.name = "paper- 'Security Record'"
					printing = null
//RECORD DELETE
			if ("Delete All Records")
				temp = ""
				temp += "Are you sure you wish to delete all Security records?<br>"
				temp += "<a href='?src=\ref[src];choice=Purge All Records'>Yes</a><br>"
				temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Purge All Records")
				for(var/datum/data/record/R in data_core.security)
					del(R)
				temp = "All Security records deleted."

			if ("Add Entry")
				if (!( istype(active2, /datum/data/record) ))
					return
				var/a2 = active2
				var/t1 = strip_html(input("Add Comment:", "Secure. records", null, null))  as message
				if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
					return
				var/counter = 1
				while(active2.fields[text("com_[]", counter)])
					counter++
				active2.fields[text("com_[]", counter)] = text("Made by [] ([]) on [], 2053<BR>[]", authenticated, rank, time2text(world.realtime, "DDD MMM DD hh:mm:ss"), t1)

			if ("Delete Record (ALL)")
				if (active1)
					temp = "<h5>Are you sure you wish to delete the record (ALL)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (ALL) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Delete Record (Security)")
				if (active2)
					temp = "<h5>Are you sure you wish to delete the record (Security Portion Only)?</h5>"
					temp += "<a href='?src=\ref[src];choice=Delete Record (Security) Execute'>Yes</a><br>"
					temp += "<a href='?src=\ref[src];choice=Clear Screen'>No</a>"

			if ("Delete Entry")
				if ((istype(active2, /datum/data/record) && active2.fields[text("com_[]", href_list["del_c"])]))
					active2.fields[text("com_[]", href_list["del_c"])] = "<B>Deleted</B>"
//RECORD CREATE
			if ("New Record (Security)")
				if ((istype(active1, /datum/data/record) && !( istype(active2, /datum/data/record) )))
					var/datum/data/record/R = new /datum/data/record()
					R.fields["name"] = active1.fields["name"]
					R.fields["id"] = active1.fields["id"]
					R.name = text("Security Record #[]", R.fields["id"])
					R.fields["criminal"] = "None"
					R.fields["mi_crim"] = "None"
					R.fields["mi_crim_d"] = "No minor crime convictions."
					R.fields["ma_crim"] = "None"
					R.fields["ma_crim_d"] = "No major crime convictions."
					R.fields["notes"] = "No notes."
					data_core.security += R
					active2 = R
					screen = 4

			if ("New Record (General)")
				var/datum/data/record/G = new /datum/data/record()
				G.fields["name"] = "New Record"
				G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
				G.fields["rank"] = "Unassigned"
				G.fields["sex"] = "Male"
				G.fields["age"] = "Unknown"
				G.fields["fingerprint"] = "Unknown"
				G.fields["p_stat"] = "Active"
				G.fields["m_stat"] = "Stable"
				data_core.general += G
				active1 = G
				active2 = null
//FIELD FUNCTIONS
			if ("Edit Field")
				var/a1 = active1
				var/a2 = active2
				switch(href_list["field"])
					if("name")
						if (istype(active1, /datum/data/record))
							var/t1 = strip_html(input("Please input name:", "Secure. records", active1.fields["name"], null))  as text
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon)))) || active1 != a1)
								return
							active1.fields["name"] = t1
					if("id")
						if (istype(active2, /datum/data/record))
							var/t1 = strip_html(input("Please input id:", "Secure. records", active1.fields["id"], null))  as text
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["id"] = t1
					if("fingerprint")
						if (istype(active1, /datum/data/record))
							var/t1 = strip_html(input("Please input fingerprint hash:", "Secure. records", active1.fields["fingerprint"], null))  as text
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["fingerprint"] = t1
					if("sex")
						if (istype(active1, /datum/data/record))
							if (active1.fields["sex"] == "Male")
								active1.fields["sex"] = "Female"
							else
								active1.fields["sex"] = "Male"
					if("age")
						if (istype(active1, /datum/data/record))
							var/t1 = strip_html(input("Please input age:", "Secure. records", active1.fields["age"], null))  as text
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active1 != a1))
								return
							active1.fields["age"] = t1
					if("mi_crim")
						if (istype(active2, /datum/data/record))
							var/t1 = strip_html(input("Please input minor disabilities list:", "Secure. records", active2.fields["mi_crim"], null))  as text
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["mi_crim"] = t1
					if("mi_crim_d")
						if (istype(active2, /datum/data/record))
							var/t1 = strip_html(input("Please summarize minor dis.:", "Secure. records", active2.fields["mi_crim_d"], null))  as message
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["mi_crim_d"] = t1
					if("ma_crim")
						if (istype(active2, /datum/data/record))
							var/t1 = strip_html(input("Please input major diabilities list:", "Secure. records", active2.fields["ma_crim"], null))  as text
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["ma_crim"] = t1
					if("ma_crim_d")
						if (istype(active2, /datum/data/record))
							var/t1 = strip_html(input("Please summarize major dis.:", "Secure. records", active2.fields["ma_crim_d"], null))  as message
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["ma_crim_d"] = t1
					if("notes")
						if (istype(active2, /datum/data/record))
							var/t1 = strip_html(input("Please summarize notes:", "Secure. records", active2.fields["notes"], null))  as message
							if ((!( t1 ) || !( authenticated ) || usr.stat || usr.restrained() || (!in_range(src, usr) && (!istype(usr, /mob/living/silicon))) || active2 != a2))
								return
							active2.fields["notes"] = t1
					if("criminal")
						if (istype(active2, /datum/data/record))
							temp = "<h5>Criminal Status:</h5>"
							temp += "<ul>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=none'>None</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=arrest'>*Arrest*</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=incarcerated'>Incarcerated</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=parolled'>Parolled</a></li>"
							temp += "<li><a href='?src=\ref[src];choice=Change Criminal Status;criminal2=released'>Released</a></li>"
							temp += "</ul>"
					if("rank")
						var/list/L = list( "Head of Personnel", "Captain", "AI" )
						//This was so silly before the change. Now it actually works without beating your head against the keyboard. /N
						if ((istype(active1, /datum/data/record) && L.Find(rank)))
							temp = "<h5>Rank:</h5>"
							temp += "<ul>"
							for(var/rank in get_all_jobs())
								temp += "<li><a href='?src=\ref[src];choice=Change Rank;rank=[rank]'>[rank]</a></li>"
							temp += "</ul>"
						else
							alert(usr, "You do not have the required rank to do this!")
//TEMPORARY MENU FUNCTIONS
			else//To properly clear as per clear screen.
				temp=null
				switch(href_list["choice"])
					if ("Change Rank")
						if (active1)
							active1.fields["rank"] = href_list["rank"]

					if ("Change Criminal Status")
						if (active2)
							switch(href_list["criminal2"])
								if("none")
									active2.fields["criminal"] = "None"
								if("arrest")
									radioalert("The [active1.fields["rank"]] '[active1.fields["name"]]' is wanted for arrest, all security staff be on the lookout for [active1.fields["name"]]. Thank you.","Security Records Computer","Security")
									active2.fields["criminal"] = "*Arrest*"
								if("incarcerated")
									active2.fields["criminal"] = "Incarcerated"
								if("parolled")
									active2.fields["criminal"] = "Parolled"
								if("released")
									active2.fields["criminal"] = "Released"

					if ("Delete Record (Security) Execute")
						if (active2)
							del(active2)

					if ("Delete Record (ALL) Execute")
						for(var/datum/data/record/R in data_core.medical)
							if ((R.fields["name"] == active1.fields["name"] || R.fields["id"] == active1.fields["id"]))
								del(R)
							else
						if (active2)
							del(active2)
						if (active1)
							del(active1)
					else
						temp = "This function does not appear to be working at the moment. Our apologies."
	add_fingerprint(usr)
	updateUsrDialog()
	return

