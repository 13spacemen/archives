var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	antag_flag = BE_CHANGELING
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/const/changeling_amount = 4 //hard limit on changelings if scaling is turned off

/datum/game_mode/changeling/announce()
	world << "<b>The current game mode is - Changeling!</b>"
	world << "<b>There are alien changelings on the station. Do not let the changelings succeed!</b>"

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/num_changelings = 1

	if(config.changeling_scaling_coeff)
		num_changelings = max(1, round((num_players())/(config.changeling_scaling_coeff)))
	else
		num_changelings = max(1, min(num_players(), changeling_amount))

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	if(antag_candidates.len>0)
		for(var/i = 0, i < num_changelings, i++)
			if(!antag_candidates.len) break
			var/datum/mind/changeling = pick(antag_candidates)
			antag_candidates -= changeling
			changelings += changeling
			modePlayer += changelings
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		log_game("[changeling.key] (ckey) has been selected as a changeling")
		changeling.current.make_changeling()
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return

/datum/game_mode/changeling/make_antag_chance(var/mob/living/carbon/human/character) //Assigns changeling to latejoiners
	var/changelingcap = round(joined_player_list.len / config.changeling_scaling_coeff)
	if(changelings.len >= changelingcap + 1) //Caps number of latejoin antagonists
		return
	if(changelings.len <= (changelingcap - 1) || prob(100 / config.changeling_scaling_coeff))
		if(character.client.prefs.be_special & BE_CHANGELING)
			if(!jobban_isbanned(character.client, "changeling") && !jobban_isbanned(character.client, "Syndicate"))
				if(!(character.job in ticker.mode.restricted_jobs))
					character.mind.make_Changling()
	..()

/datum/game_mode/proc/forge_changeling_objectives(var/datum/mind/changeling)
	//OBJECTIVES - Always absorb at least 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 4)
	changeling.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = changeling
	kill_objective.find_target()
	changeling.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective

	if (!(locate(/datum/objective/escape) in changeling.objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = changeling
		changeling.objectives += escape_objective

	return

/datum/game_mode/proc/greet_changeling(var/datum/mind/changeling, var/you_are=1)
	if (you_are)
		changeling.current << "<b>\red You are a changeling! You have absorbed and taken the form of a human.</b>"
	changeling.current << "<b>\red Use say \":g message\" to communicate with your fellow changelings.</b>"
	changeling.current << "<b>You must complete the following tasks:</b>"

	if (changeling.current.mind)
		if (changeling.current.mind.assigned_role == "Clown")
			changeling.current << "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself."
			changeling.current.remove_organic_effect(/datum/organic_effect/clumsy)

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		changeling.current << "<b>Objective #[obj_count]</b>: [objective.explanation_text]"
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/auto_declare_completion_changeling()
	if(changelings.len)
		var/text = "<br><font size=3><b>The changelings were:</b></font>"
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = 1

			text += "<br><b>[changeling.key]</b> was <b>[changeling.name]</b> ("
			if(changeling.current)
				if(changeling.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(changeling.current.real_name != changeling.name)
					text += " as <b>[changeling.current.real_name]</b>"
			else
				text += "body destroyed"
				changelingwin = 0
			text += ")"

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			text += "<br><b>Changeling ID:</b> [changeling.changeling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [changeling.changeling.absorbedcount]"

			if(changeling.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in changeling.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("changeling_objective","[objective.type]|FAIL")
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><b>The changeling was successful!</b></font>"
				feedback_add_details("changeling_success","SUCCESS")
			else
				text += "<br><font color='red'><b>The changeling has failed.</b></font>"
				feedback_add_details("changeling_success","FAIL")
			text += "<br>"

		world << text


	return 1

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/absorbed_dna = list()
	var/dna_max = 4 //How many extra DNA strands the changeling can store for transformation.
	var/absorbedcount = 1 //We would require at least 1 sample of compatible DNA to have taken on the form of a human.
	var/chem_charges = 20
	var/chem_storage = 50
	var/chem_recharge_rate = 0.5
	var/chem_recharge_slowdown = 0
	var/sting_range = 2
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/purchasedpowers = list()
	var/mimicing = ""
	var/canrespec = 0
	var/datum/dna/chosen_dna
	var/obj/effect/proc_holder/changeling/sting/chosen_sting
	var/space_suit_active = 0

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"
	absorbed_dna.len = dna_max


/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
	geneticdamage = max(0, geneticdamage-1)


/datum/changeling/proc/get_dna(var/dna_owner)
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			return DNA

/datum/changeling/proc/can_absorb_dna(var/mob/living/carbon/user, var/mob/living/carbon/target)
	if(absorbed_dna[1] == user.dna)//If our current DNA is the stalest, we gotta ditch it.
		user << "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>"
		return
	if(!target)
		return
	if(target.has_organic_effect(/datum/organic_effect/noclone) || target.has_organic_effect(/datum/organic_effect/husk))
		user << "<span class='warning'>DNA of [target] is ruined beyond usability!</span>"
		return
	if(!ishuman(target))//Absorbing monkeys is entirely possible, but it can cause issues with transforming. That's what lesser form is for anyway!
		user << "<span class='warning'>We could gain no benefit from absorbing a lesser creature.</span>"
		return
	if(!check_dna_integrity(target))
		user << "<span class='warning'>[target] is not compatible with our biology.</span>"
		return
	return 1

/datum/changeling/proc/can_extract_sting(var/mob/living/carbon/user, var/mob/living/carbon/target)
	if(can_absorb_dna(user, target) != 1) return
	var/datum/dna/tDna = target.dna
	for(var/datum/dna/D in absorbed_dna)
		if(tDna.is_same_as(D))
			user << "<span class='warning'>We already have that DNA in storage.</span>"
			return
	return 1