/mob/living/silicon/ai/say(var/message)
	if(parent && istype(parent) && parent.stat != 2) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message)
		return
	..(message)

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//this proc assumes that the message originated from a radio. if the speaker is not a virtual speaker this will probably fuck up hard.
	var/mob/M = speaker.GetSource()
	var/obj/item/device/radio = speaker.GetRadio()
	if(M)
		var/faketrack = "byond://?src=\ref[radio];track2=\ref[src];track=\ref[M]"
		if(speaker.GetTrack())
			faketrack = "byond://?src=\ref[radio];track2=\ref[src];faketrack=\ref[M]"
		return "<a href='[faketrack]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return " [radio_freq ? "(" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/ai/IsVocal()
	return !config.silent_ai

/mob/living/silicon/ai/get_message_mode(message)
	if(copytext(message, 1, 3) in list(":h", ":H", ".h", ".H", "#h", "#H"))
		return MODE_HOLOPAD
	else
		return ..()

/mob/living/silicon/ai/handle_inherent_channels(message, message_mode)
	. = ..()
	if(.)
		return .

	if(message_mode == MODE_HOLOPAD)
		holopad_talk(message)
		return 1

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(var/message)
	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])//If there is a hologram and its master is the user.
		send_speech(message, 7, T, "R")
		src << "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> <span class='message'>\"[message]\"</span></span></i>"//The AI can "hear" its own message.
	else
		src << "No holopad connected."
	return


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX

var/announcing_vox = 0 // Stores the time of the last announcement
var/const/VOX_CHANNEL = 200
var/const/VOX_DELAY = 600

/mob/living/silicon/ai/verb/announcement_help()

	set name = "Announcement Help"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"


	var/dat = "Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR> \
	<UL><LI>You can also click on the word to preview it.</LI>\
	<LI>You can only say 30 words for every announcement.</LI>\
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI></UL>\
	<font class='bad'>WARNING:</font><BR>Misuse of the announcement system will get you job banned.<HR>"

	var/index = 0
	for(var/word in vox_sounds)
		index++
		dat += "<A href='?src=\ref[src];say_word=[word]'>[capitalize(word)]</A>"
		if(index != vox_sounds.len)
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()


/mob/living/silicon/ai/proc/announcement()
	if(announcing_vox > world.time)
		src << "<span class='notice'>Please wait [round((announcing_vox - world.time) / 10)] seconds.</span>"
		return

	var/message = input(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", src.last_announcement) as text

	last_announcement = message

	if(!message || announcing_vox > world.time)
		return

	if(stat != CONSCIOUS)
		return

	if(control_disabled)
		src << "<span class='notice'>Wireless interface disabled, unable to interact with announcement PA.</span>"
		return

	var/list/words = text2list(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!vox_sounds[word])
			incorrect_words += word

	if(incorrect_words.len)
		src << "<span class='notice'>These words are not available on the announcement system: [english_list(incorrect_words)].</span>"
		return

	announcing_vox = world.time + VOX_DELAY

	log_game("[key_name(src)] made a vocal announcement with the following message: [message].")
	message_admins("[key_name(src)] made a vocal announcement with the following message: [message].")

	for(var/word in words)
		play_vox_word(word, src.z, null)
/*
	for(var/mob/M in player_list)
		if(M.client)
			var/turf/T = get_turf(M)
			var/turf/our_turf = get_turf(src)
			if(T.z == our_turf.z)
				M << "<b><font size = 3><font color = red>AI announcement:</font color> [message]</font size></b>"
*/


/proc/play_vox_word(var/word, var/z_level, var/mob/only_listener)

	word = lowertext(word)

	if(vox_sounds[word])

		var/sound_file = vox_sounds[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = VOX_CHANNEL)
		voice.status = SOUND_STREAM

 		// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/M in player_list)
				if(M.client)
					var/turf/T = get_turf(M)
					if(T.z == z_level)
						M << voice
		else
			only_listener << voice
		return 1
	return 0

#endif
