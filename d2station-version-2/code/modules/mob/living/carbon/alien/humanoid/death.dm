/mob/living/carbon/alien/humanoid/death(gibbed)
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health6"
	src.stat = 2

	if (!gibbed)
//		emote("deathgasp") // Dead -- Skie // Doesn't work due to stat == 2 -- Urist
		playsound(src.loc, 'hiss6.ogg', 80, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw...", 1)
		src.canmove = 0
		if(src.client)
			src.blind.layer = 0
		src.lying = 1
		var/h = src.hand
		src.hand = 0
		drop_item()
		src.hand = 1
		drop_item()
		src.hand = h
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))
			var/obj/item/clothing/suit/armor/a_i_a_ptank/A = src.wear_suit
			bombers += "[src.key] has detonated a suicide bomb. Temp = [A.part4.air_contents.temperature-T0C]."
	//		world << "Detected that [src.key] is wearing a bomb" debug stuff
			if(A.status && prob(90))
	//			world << "Bomb has ignited?"
				A.part4.ignite()

		if (src.client)
			spawn(10)
				if(src.client && src.stat == 2)
					src.verbs += /mob/proc/ghostize

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	if (mind) mind.store_memory("Time of death: [tod]", 0)
	else src << "We seem to have misplaced your mind datum, so we can't add this to your memory, but you died at [tod]"

	var/cancel
	for (var/mob/M in world)
		if (M.client && !M.stat)
			cancel = 1
			break

	if (!cancel && !abandon_allowed)
		spawn (50)
			cancel = 0
			for (var/mob/M in world)
				if (M.client && !M.stat)
					cancel = 1
					break

			if (!cancel && !abandon_allowed)
				world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"

				spawn (300)
					log_game("Rebooting because of no live players")
					world.Reboot()

	return ..(gibbed)
