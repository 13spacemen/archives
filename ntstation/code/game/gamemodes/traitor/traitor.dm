/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	antag_flag = BE_TRAITOR
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")//AI", Currently out of the list as malf does not work for shit
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4


	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/scale_modifier = 1 // Used for gamemodes, that are a child of traitor, that need more than the usual.


/datum/game_mode/traitor/announce()
	world << "<B>The current game mode is - Traitor!</B>"
	world << "<B>There are syndicate traitors on the station. Do not let the traitors succeed!</B>"


/datum/game_mode/traitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/num_traitors = 1

	if(config.traitor_scaling_coeff)
		num_traitors = max(1, round((num_players())/((config.traitor_scaling_coeff * scale_modifier))))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				antag_candidates -= player

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = pick(antag_candidates)
		traitors += traitor
		traitor.special_role = traitor_name
		log_game("[traitor.key] (ckey) has been selected as a [traitor_name]")
		antag_candidates.Remove(traitor)


	if(traitors.len < required_enemies)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		if(!exchange_blue && traitors.len >= 5) //Set up an exchange if there are enough traitors
			if(!exchange_red)
				exchange_red = traitor
			else
				exchange_blue = traitor
				assign_exchange_role(exchange_red)
				assign_exchange_role(exchange_blue)
		else
			forge_traitor_objectives(traitor)
		spawn(rand(10,100))
			finalize_traitor(traitor)
			greet_traitor(traitor)
	modePlayer += traitors
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1

/datum/game_mode/traitor/make_antag_chance(var/mob/living/carbon/human/character) //Assigns traitor to latejoiners
	var/traitorcap = round(joined_player_list.len / (config.traitor_scaling_coeff * scale_modifier))
	if(traitors.len >= traitorcap + 1) //Upper cap for number of latejoin antagonists
		return
	if(traitors.len <= (traitorcap - 1) || prob(100 / (config.traitor_scaling_coeff * scale_modifier)))
		if(character.client.prefs.be_special & BE_TRAITOR)
			if(!jobban_isbanned(character.client, "traitor") && !jobban_isbanned(character.client, "Syndicate"))
				if(!(character.job in ticker.mode.restricted_jobs))
					add_latejoin_traitor(character.mind)
	..()

/datum/game_mode/traitor/proc/add_latejoin_traitor(var/datum/mind/character)
	character.make_Traitor()


/datum/game_mode/proc/forge_traitor_objectives(var/datum/mind/traitor)
	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective

	else
		if(prob(50))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = traitor
			kill_objective.find_target()
			traitor.objectives += kill_objective
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = traitor
			steal_objective.find_target()
			traitor.objectives += steal_objective

		forge_escape_objective(traitor)

	return


/datum/game_mode/proc/forge_escape_objective(var/datum/mind/traitor)
	if(prob(90))
		if (!(locate(/datum/objective/escape) in traitor.objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = traitor
			traitor.objectives += escape_objective
	else
		if (!(locate(/datum/objective/hijack) in traitor.objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = traitor
			traitor.objectives += hijack_objective


/datum/game_mode/proc/greet_traitor(var/datum/mind/traitor)
	traitor.current << "<B><font size=3 color=red>You are the [traitor_name].</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in traitor.objectives)
		traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/finalize_traitor(var/datum/mind/traitor)
	if (istype(traitor.current, /mob/living/silicon))
		add_law_zero(traitor.current)
	else
		equip_traitor(traitor.current)
	return


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.


/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer.set_zeroth_law(law, law_borg)
	killer << "New law: 0. [law]"

	//Begin code phrase.
	killer << "The Syndicate provided you with the following information on how to identify their agents:"
	if(prob(80))
		killer << "\red Code Phrase: \black [syndicate_code_phrase]"
		killer.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	else
		killer << "Unfortunately, the Syndicate did not provide you with a code phrase."
	if(prob(80))
		killer << "\red Code Response: \black [syndicate_code_response]"
		killer.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
	else
		killer << "Unfortunately, the Syndicate did not provide you with a code response."
	killer << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	//End code phrase.


/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<br><font size=3><b>The [traitor_name]s were:</b></font>"
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = 1

			text += "<br><b>[traitor.key]</b> was <b>[traitor.name]</b> ("
			if(traitor.current)
				if(traitor.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(traitor.current.real_name != traitor.name)
					text += " as <b>[traitor.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"


			var/TC_uses = 0
			var/uplink_true = 0
			var/purchases = ""
			for(var/obj/item/device/uplink/H in world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==traitor.key)
					TC_uses += H.used_TC
					uplink_true=1
					purchases += H.purchase_log

			var/objectives = ""
			if(traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			if(uplink_true)
				text += " (used [TC_uses] TC) [purchases]"
				if(TC_uses==0 && traitorwin)
					text += "<BIG><IMG CLASS=icon SRC=\ref['icons/BadAss.dmi'] ICONSTATE='badass'></BIG>"

			text += objectives

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"


			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")

			text += "<br>"

		world << text
	return 1


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, var/safety = 0)
	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			traitor_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			traitor_mob.remove_organic_effect(/datum/organic_effect/clumsy)

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/R = locate(/obj/item/device/pda) in traitor_mob.contents //Hide the uplink in a PDA if available, otherwise radio
	if(!R)
		R = locate(/obj/item/device/radio) in traitor_mob.contents

	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
		. = 0
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/obj/item/device/radio/target_radio = R
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/hidden/T = new(R)
			target_radio.hidden_uplink = T
			T.uplink_owner = "[traitor_mob.key]"
			target_radio.traitor_frequency = freq
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/hidden/T = new(R)
			R.hidden_uplink = T
			T.uplink_owner = "[traitor_mob.key]"
			var/obj/item/device/pda/P = R
			P.lock_code = pda_pass

			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
	//Begin code phrase.
	if(!safety)//If they are not a rev. Can be added on to.
		traitor_mob << "The Syndicate provided you with the following information on how to identify other agents:"
		if(prob(80))
			traitor_mob << "\red Code Phrase: \black [syndicate_code_phrase]"
			traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
		else
			traitor_mob << "Unfortunetly, the Syndicate did not provide you with a code phrase."
		if(prob(80))
			traitor_mob << "\red Code Response: \black [syndicate_code_response]"
			traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			traitor_mob << "Unfortunately, the Syndicate did not provide you with a code response."
		traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	//End code phrase.

/datum/game_mode/proc/assign_exchange_role(var/datum/mind/owner)
	//set faction
	var/faction = "red"
	if(owner == exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? exchange_blue : exchange_red))
	exchange_objective.owner = owner
	owner.objectives += exchange_objective

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		owner.objectives += backstab_objective

	forge_escape_objective(owner)

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/weapon/folder/syndicate/folder
	if(owner == exchange_red)
		folder = new/obj/item/weapon/folder/syndicate/red(mob.locs)
	else
		folder = new/obj/item/weapon/folder/syndicate/blue(mob.locs)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	mob << "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>"
	mob.update_icons()
