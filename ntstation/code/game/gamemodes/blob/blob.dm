//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

//Few global vars to track the blob
var/list/blobs = list()
var/list/blob_cores = list()
var/list/blob_nodes = list()


/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"
	antag_flag = BE_BLOB

	required_players = 17
	required_enemies = 1
	recommended_enemies = 1

	restricted_jobs = list("Cyborg", "AI")

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/declared = 0

	var/cores_to_spawn = 1
	var/players_per_core = 30
	var/blob_point_rate = 1.75

	var/blobwincount = 450

	var/list/infected_crew = list()

/datum/game_mode/blob/pre_setup()
	cores_to_spawn = max(round(num_players()/players_per_core, 1), 1)

	blobwincount = initial(blobwincount) * cores_to_spawn

	if(num_players() < 30)
		blob_point_rate = min((num_players()*0.1)+(0.4-((num_players()-17)/40)), 3)

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	for(var/j = 0, j < cores_to_spawn, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/blob = pick(antag_candidates)
		infected_crew += blob
		blob.special_role = "Blob"
		log_game("[blob.key] (ckey) has been selected as a Blob")
		antag_candidates -= blob

	if(!infected_crew.len)
		return 0

	return 1


/datum/game_mode/blob/announce()
	world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
	world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
	world << "You must kill it all while minimizing the damage to the station."


/datum/game_mode/blob/proc/greet_blob(var/datum/mind/blob)
	blob.current << "<B>\red You are infected by the Blob!</B>"
	blob.current << "<b>Your body is ready to give spawn to a new blob core which will eat this station.</b>"
	blob.current << "<b>Find a good location to spawn the core and then take control and overwhelm the station!</b>"
	blob.current << "<b>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</b>"
	blob.current << "<b>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</b>"
	return

/datum/game_mode/blob/proc/show_message(var/message)
	for(var/datum/mind/blob in infected_crew)
		blob.current << message

/datum/game_mode/blob/proc/burst_blobs()
	for(var/datum/mind/blob in infected_crew)

		var/client/blob_client = null
		var/turf/location = null

		if(iscarbon(blob.current))
			var/mob/living/carbon/C = blob.current
			if(directory[ckey(blob.key)])
				blob_client = directory[ckey(blob.key)]
				location = get_turf(C)
				if(location.z != 1 || istype(location, /turf/space))
					location = null
				C.gib()


		if(blob_client && location)
			var/obj/effect/blob/core/core = new(location, 200, blob_client, blob_point_rate)
			if(core.overmind && core.overmind.mind)
				core.overmind.mind.name = blob.name
				infected_crew -= blob
				infected_crew += core.overmind.mind


/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in infected_crew)
		greet_blob(blob)

	if(emergency_shuttle)
		emergency_shuttle.always_fake_recall = 1

	// Disable the blob event for this round.
	if(events)
		var/datum/round_event_control/blob/B = locate() in events.control
		if(B)
			B.max_occurrences = 0 // disable the event
	else
		ERROR("Events variable is null in blob gamemode post setup.")

	spawn(10)
		start_state = new /datum/station_state()
		start_state.count()

	spawn(0)

		var/wait_time = rand(waittime_l, waittime_h)

		sleep(wait_time)

		send_intercept(0)

		sleep(100)

		show_message("<span class='alert'>You feel tired and bloated.</span>")

		sleep(wait_time)

		show_message("<span class='alert'>You feel like you are about to burst.</span>")

		sleep(wait_time / 2)

		burst_blobs()

		// Stage 0
		sleep(40)
		stage(0)

		// Stage 1
		sleep(2000)
		stage(1)

	..()

/datum/game_mode/blob/proc/stage(var/stage)

	switch(stage)
		if (0)
			send_intercept(1)
			declared = 1
			return

		if (1)
			priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')
			return

	return

