/mob/living/proc/binarycheck()
	if (istype(src, /mob/living/silicon/pai)) return
	if (issilicon(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_binary) return 1

/mob/living/proc/hivecheck()
	if (isalien(src)) return 1
	if (!ishuman(src)) return
	var/mob/living/carbon/human/H = src
	if (H.ears)
		var/obj/item/device/radio/headset/dongle = H.ears
		if(!istype(dongle)) return
		if(dongle.translate_hive) return 1

/mob/living/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (length(message) >= 1)
		if (miming && copytext(message, 1, 2) != "*")
			return

	if (stat == 2)
		return say_dead(message)
	if (src.client)
		if (client.muted || silent)
			return

	//deathcheck
	if (stat == 2)
		return

	// emotes
	if (copytext(message, 1, 2) == "*" && !stat)
		return emote(copytext(message, 2))

	// wtf?
	if (stat)
		return

	// Mute disability
	if (sdisabilities & 2)
		return

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	var/alt_name = ""
	if (istype(src, /mob/living/carbon/human) && name != real_name)
		var/mob/living/carbon/human/H = src
		alt_name = " (as [H.get_visible_name()])"
	var/italics = 0
	var/message_range = null
	var/message_mode = null

	if (brainloss >= 60 && prob(50))
		if (ishuman(src))
			message_mode = "headset"
	// Special message handling
	else if (copytext(message, 1, 2) == ";")
		if (ishuman(src))
			message_mode = "headset"
		else if(istype(src, /mob/living/silicon/pai))
			message_mode = "pAI"
		message = copytext(message, 2)

	else if (length(message) >= 2)
		var/channel_prefix = copytext(message, 1, 3)

		var/list/keys = list(
			  ":r" = "right hand",
			  ":l" = "left hand",
			  ":i" = "intercom",
			  ":h" = "department",
			  ":c" = "Command",
			  ":n" = "Science",
			  ":m" = "Medical",
			  ":e" = "Engineering",
			  ":s" = "Security",
			  ":w" = "whisper",
			  ":b" = "binary",
			  ":a" = "alientalk",
			  ":t" = "Syndicate",
			  ":d" = "Mining",
			  ":q" = "Cargo",

			  //kinda localization -- rastaf0
			  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
			  ":�" = "right hand",
			  ":�" = "left hand",
			  ":�" = "intercom",
			  ":�" = "department",
			  ":�" = "Command",
			  ":�" = "Science",
			  ":�" = "Medical",
			  ":�" = "Engineering",
			  ":�" = "Security",
			  ":�" = "whisper",
			  ":�" = "binary",
			  ":�" = "alientalk",
			  ":�" = "Syndicate",
			  ":�" = "Mining",
			  ":�" = "Cargo",
		)

		message_mode = keys[channel_prefix]
	//	world << "channel_prefix=[channel_prefix]; message_mode=[message_mode]"
		if (message_mode)
			message = trim(copytext(message, 3))
			if (!ishuman(src) && (message_mode=="department" || (message_mode in radiochannels)))
				message_mode = null //only humans can use headsets

	if (!message)
		return

	// :downs:
	if (brainloss >= 60)
		message = dd_replacetext(message, " am ", " ")
		message = dd_replacetext(message, " is ", " ")
		message = dd_replacetext(message, " are ", " ")
		message = dd_replacetext(message, "you", "u")
		message = dd_replacetext(message, "help", "halp")
		message = dd_replacetext(message, "grief", "grife")
		message = dd_replacetext(message, "space", "spess")
		message = dd_replacetext(message, "carp", "crap")
		if(prob(50))
			message = uppertext(message)
			message += "[stutter(pick("!", "!!", "!!!"))]"
		if(!stuttering && prob(15))
			message = stutter(message)

	if (stuttering)
		message = stutter(message)

 //qw do not have beesease atm.
	if(viruses)
		for(var/datum/disease/Virus in viruses)
			if(Virus.name=="beesease" && Virus.stage>=2)
				if(prob(Virus.stage*10))
					var/bzz = length(message)
					message = "B"
					for(var/i=0,i<bzz,i++)
						message += "Z"

	var/list/obj/item/used_radios = new
	switch (message_mode)
		if ("headset")
			if (src:ears)
				src:ears.talk_into(src, message)
				used_radios += src:ears

			message_range = 1
			italics = 1

		if ("secure headset")
			if (src:ears)
				src:ears.talk_into(src, message, 1)
				used_radios += src:ears

			message_range = 1
			italics = 1

		if ("right hand")
			if (r_hand)
				r_hand.talk_into(src, message)
				used_radios += src:r_hand

			message_range = 1
			italics = 1

		if ("left hand")
			if (l_hand)
				l_hand.talk_into(src, message)
				used_radios += src:l_hand

			message_range = 1
			italics = 1

		if ("intercom")
			for (var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message)
				used_radios += I

			message_range = 1
			italics = 1

		//I see no reason to restrict such way of whispering
		if ("whisper")
			whisper(message)
			return

		if ("binary")
			if(robot_talk_understand || binarycheck())
			//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
				robot_talk(message)
			return

		if ("alientalk")
			if(alien_talk_understand || hivecheck())
			//message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN)) //seems redundant
				alien_talk(message)
			return

		if ("department")
			if (src:ears)
				src:ears.talk_into(src, message, message_mode)
				used_radios += src:ears
			message_range = 1
			italics = 1
		if ("pAI")
			if (src:radio)
				src:radio.talk_into(src, message)
				used_radios += src:radio
			message_range = 1
			italics = 1
/////SPECIAL HEADSETS START
		else
			//world << "SPECIAL HEADSETS"
			if (message_mode in radiochannels)
				if (src:ears)
					src:ears.talk_into(src, message, message_mode)
					used_radios += src:ears
				message_range = 1
				italics = 1
/////SPECIAL HEADSETS END

	var/list/listening
/*
	if(istype(loc, /obj/item/device/aicard)) // -- TLE
		var/obj/O = loc
		if(istype(O.loc, /mob))
			var/mob/M = O.loc
			listening = hearers(message_range, M)
		else
			listening = hearers(message_range, O)
	else
		listening = hearers(message_range, src)

	for (var/obj/O in view(message_range, src))
		for (var/mob/M in O)
			listening += M // maybe need to check if M can hear src
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	if (!(src in listening))
		listening += src

*/
	var/turf/T = get_turf(src)
	listening = hearers(message_range, T)
	var/list/V = view(message_range, T)
	//find mobs in lockers, cryo, intellicards, brains, MMIs, and so on.
	for (var/mob/M in mobz)
		if (!M.client)
			continue //skip monkeys and leavers
		if (istype(M, /mob/new_player))
			continue
		if (M.stat <2) //is alive
			if (isturf(M.loc))
				continue //if M can hear us it was already found by hearers()
			if (get_turf(M) in V) //this is slow, but I don't think we'd have a lot of wardrobewhores every round --rastaf0
				listening+=M
		else
			if (M.client && M.client.ghost_ears)
				listening|=M

	for (var/obj/O in ((V | contents)-used_radios)) //radio in pocket could work, radio in backpack wouldn't --rastaf0
		spawn (0)
			if (O)
				O.hear_talk(src, message)

	if(isbrain(src))//For brains to properly talk if they are in an MMI..or in a brain. Could be extended to other mobs I guess.
		for(var/obj/O in loc)//Kinda ugly but whatever.
			if(O)
				spawn(0)
					O.hear_talk(src, message)

	var/list/heard_a = list() // understood us
	var/list/heard_b = list() // didn't understand us

	for (var/mob/M in listening)
		if (M.say_understands(src))
			heard_a += M
			//chat bubbles
//			var/colour = ""
//			colour = "<font size=1><font color=#84B500><font face=system>"
//			colour += message
//			colour += "</font>"
//			spawn new /text_obj(colour, src, M, 124, 124, 70, 73)
		else
			heard_b += M

	var/rendered = null
	if (length(heard_a))
		var/message_a = say_quote(message)

		if (italics)
			message_a = "<i>[message_a]</i>"
		if (!istype(src, /mob/living/carbon/human))
			rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"
		else if(istype(wear_mask, /obj/item/clothing/mask/gas/voice))
			if(wear_mask:vchange)
				rendered = "<span class='game say'><span class='name'>[wear_mask:voice]</span> <span class='message'>[message_a]</span></span>"
			else
				rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message_a]</span></span>"
		else
			rendered = "<span class='game say'><span class='name'>[real_name]</span>[alt_name] <span class='message'>[message_a]</span></span>"

		for (var/mob/M in heard_a)
			M.show_message(rendered, 2)
/*
			for(var/obj/O in M) // This is terribly costly for such a unique circumstance, should probably do this a different way in the future -- TLE
				if(istype(O, /obj/item/device/aicard))
					for(var/mob/M2 in O)
						M2.show_message(rendered, 2)
						break
					break
*/
	if (length(heard_b))
		var/message_b

		if (voice_message)
			message_b = voice_message
		else
			message_b = stars(message)
			message_b = say_quote(message_b)

		if (italics)
			message_b = "<i>[message_b]</i>"

		rendered = "<span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span>"

		for (var/mob/M in heard_b)
			M.show_message(rendered, 2)

	log_say("[name]/[key] : [message]")

	//chat bubbles
	/*if(sd_BalloonTails && sd_BalloonTails.len)
		for(var/Tail in sd_BalloonTails)
			del(Tail)

	sd_ImprovedWordBalloon(message, src)*/
	//chat bubbles