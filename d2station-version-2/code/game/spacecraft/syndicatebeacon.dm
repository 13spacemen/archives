//  Beacon randomly spawns in space
//	When a non-traitor (no special role in /mind) uses it, he is given the choice to become a traitor
//	If he accepts there is a random chance he will be accepted, rejected, or rejected and killed
//	Bringing certain items can help improve the chance to become a traitor


/obj/machinery/syndicate_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1

	var
		temptext = ""
		selfdestructing = 0
		charges = 1

	attack_hand(var/mob/user as mob)
		usr.machine = src
		var/dat = "<font color=#005500><i>Scanning [pick("retina pattern", "voice print", "fingerprints", "dna sequence")]...<br>Identity confirmed,<br></i></font>"
		if(istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
			if(checktraitor(user))
				dat += "<font color=#07700><i>Operative record found. Greetings, Agent [user.name].</i></font><br>"
			else if(charges < 1)
				dat += "<TT>Connection severed.</TT><BR>"
			else
				var/honorific = "Mr."
				if(user.gender == "female")
					honorific = "Ms."
				dat += "<font color=red><i>Identity not found in operative database. What can the Syndicate do for you today, [honorific] [user.name]?</i></font><br>"
				if(!selfdestructing)
					dat += "<br><br><A href='?src=\ref[src];betraitor=1;traitormob=\ref[user]'>\"[pick("I want to switch teams.", "I want to work for you.", "Let me join you.", "I can be of use to you.", "You want me working for you, and here's why...", "Give me an objective.", "How's the 401k over at the Syndicate?")]\"</A><BR>"
		dat += temptext
		user << browse(dat, "window=syndbeacon")
		onclose(user, "syndbeacon")

	Topic(href, href_list)
		if(href_list["betraitor"])
			if(charges < 1)
				src.updateUsrDialog()
				return
			var/mob/M = locate(href_list["traitormob"])
			if(M.mind.special_role)
				temptext = "<i>We have no need for you at this time. Have a pleasant day.</i><br>"
				src.updateUsrDialog()
				return
			charges -= 1
			switch(rand(1,2))
				if(1)
					temptext = "<font color=red><i><b>Double-crosser. You planned to betray us from the start. Allow us to repay the favor in kind.</b></i></font>"
					src.updateUsrDialog()
					spawn(rand(50,200)) selfdestruct()
					return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/N = M
				//ticker.mode.equip_traitor(N)
				ticker.mode.traitors += N.mind
				N.mind.special_role = "traitor"
				var/objective = "Free Objective"
				switch(rand(1,100))
					if(1 to 50)
						objective = "Steal [pick("a hand teleporter", "the Captain's antique laser gun", "a jetpack", "the Captain's ID", "the Captain's jumpsuit")]."
					if(51 to 60)
						objective = "Destroy 70% or more of the station's plasma tanks."
					if(61 to 70)
						objective = "Cut power to 80% or more of the station's tiles."
					if(71 to 80)
						objective = "Destroy the AI."
					if(81 to 90)
						objective = "Kill all monkeys aboard the station."
					else
						objective = "Make certain at least 80% of the station evacuates on the shuttle."
				var/datum/objective/custom_objective = new(objective)
				custom_objective.owner = N.mind
				N.mind.objectives += custom_objective

				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = N.mind
				N.mind.objectives += escape_objective


				M << "<B>You have joined the ranks of the Syndicate and become a traitor to the station!</B>"

				var/obj_count = 1
				for(var/datum/objective/OBJ in M.mind.objectives)
					M << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
					obj_count++

		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return


	proc/selfdestruct()
		selfdestructing = 1
		spawn() explosion(src.loc, rand(3,8), rand(1,3), 1, 10)
