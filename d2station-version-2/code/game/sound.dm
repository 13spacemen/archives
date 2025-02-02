/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num)
	//Frequency stuff only works with 45kbps oggs.

	switch(soundin)
		if ("shatter") soundin = pick('Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg')
		if ("explosion") soundin = pick('Explosion1.ogg','Explosion2.ogg')
		if ("sparks") soundin = pick('sparks1.ogg','sparks2.ogg','sparks3.ogg','sparks4.ogg')
		if ("rustle") soundin = pick('rustle1.ogg','rustle2.ogg','rustle3.ogg','rustle4.ogg','rustle5.ogg')
		if ("punch") soundin = pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg')
		if ("clownstep") soundin = pick('clownstep1.ogg','clownstep2.ogg')
		if ("footstep") soundin = pick('footsteps.ogg','footsteps2.ogg')
		if ("swing_hit") soundin = pick('genhit1.ogg', 'genhit2.ogg', 'genhit3.ogg')
		if ("hiss") soundin = pick('hiss1.ogg','hiss2.ogg','hiss3.ogg','hiss4.ogg')
		if ("hungry") soundin = pick('hungry01.ogg','hungry02.ogg','hungry03.ogg','hungry04.ogg')
		if ("collision") soundin = pick('collision1.ogg', 'collision2.ogg', 'collision3.ogg', 'collision4.ogg', 'collision5.ogg', 'collision6.ogg', 'collision7.ogg', 'collision8.ogg')
		if ("destruction") soundin = pick('building_damage01.ogg', 'building_damage02.ogg', 'building_damage03.ogg', 'building_damage04.ogg', 'building_damage05.ogg', 'building_damage06.ogg', 'building_damage07.ogg', 'building_damage08.ogg', 'building_large_destroy01.ogg', 'building_large_destroy02.ogg', 'building_medium_destroy01.ogg', 'building_medium_destroy02.ogg', 'building_small_destroy01.ogg', 'building_small_destroy02.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	for (var/mob/M in range(world.view+extrarange, source))
		if (M.client)
			if(isturf(source))
				var/dx = source.x - M.x
				S.pan = max(-100, min(100, dx/8.0 * 100))
			M << S

/mob/proc/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num)
	if(!src.client)
		return
	switch(soundin)
		if ("shatter") soundin = pick('Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg')
		if ("explosion") soundin = pick('Explosion1.ogg','Explosion2.ogg')
		if ("sparks") soundin = pick('sparks1.ogg','sparks2.ogg','sparks3.ogg','sparks4.ogg')
		if ("rustle") soundin = pick('rustle1.ogg','rustle2.ogg','rustle3.ogg','rustle4.ogg','rustle5.ogg')
		if ("punch") soundin = pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg')
		if ("clownstep") soundin = pick('clownstep1.ogg','clownstep2.ogg')
		if ("footstep") soundin = pick('footsteps.ogg','footsteps2.ogg')
		if ("swing_hit") soundin = pick('genhit1.ogg', 'genhit2.ogg', 'genhit3.ogg')
		if ("hiss") soundin = pick('hiss1.ogg','hiss2.ogg','hiss3.ogg','hiss4.ogg')
		if ("hungry") soundin = pick('hungry01.ogg','hungry02.ogg','hungry03.ogg','hungry04.ogg')
		if ("collision") soundin = pick('collision1.ogg', 'collision2.ogg', 'collision3.ogg', 'collision4.ogg', 'collision5.ogg', 'collision6.ogg', 'collision7.ogg', 'collision8.ogg')
		if ("destruction") soundin = pick('building_damage01.ogg', 'building_damage02.ogg', 'building_damage03.ogg', 'building_damage04.ogg', 'building_damage05.ogg', 'building_damage06.ogg', 'building_damage07.ogg', 'building_damage08.ogg', 'building_large_destroy01.ogg', 'building_large_destroy02.ogg', 'building_medium_destroy01.ogg', 'building_medium_destroy02.ogg', 'building_small_destroy01.ogg', 'building_small_destroy02.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	if(isturf(source))
		var/dx = source.x - src.x
		S.pan = max(-100, min(100, dx/8.0 * 100))
	src << S

client/verb/Toggle_Soundscape()
	set name = "Toggle Ambience"
	set category = "OOC"
	usr:client:no_ambi = !usr:client:no_ambi
	if(usr:client:no_ambi)
		usr << sound('shipambience.ogg', repeat = 0, wait = 0, volume = 0, channel = 2)
	else
		usr << sound('shipambience.ogg', repeat = 1, wait = 0, volume = 45, channel = 2)
	usr << "Toggled ambience sound."
	return


/area/Entered(A)
	var/sound = null
	sound = 'ambigen1.ogg'

	if (ismob(A))

		if (istype(A, /mob/dead/observer)) return
		if (!A:client) return
		//if (A:ear_deaf) return

		if (A && A:client && !A:client:ambience_playing && !A:client:no_ambi) // Constant background noises
			A:client:ambience_playing = 1
			A << sound('shipambience.ogg', repeat = 1, wait = 0, volume = 45, channel = 2)

		switch(src.name)
			if ("Chapel") sound = pick('ambicha1.ogg','ambicha2.ogg','ambicha3.ogg','ambicha4.ogg')
			if ("Medbay") sound = pick('medibay01.ogg','medi_desk.ogg')
			if ("Morgue") sound = pick('ambimo1.ogg','ambimo2.ogg')
			if ("Engine Control") sound = pick('ambisin1.ogg','ambisin2.ogg','ambisin3.ogg','ambisin4.ogg')
			if ("Atmospherics") sound = pick('ambiatm1.ogg')
			else sound = pick('ambigen1.ogg','ambigen3.ogg','ambigen4.ogg','ambigen5.ogg','ambigen6.ogg','ambigen7.ogg','ambigen8.ogg','ambigen9.ogg','ambigen10.ogg','ambigen11.ogg','ambigen12.ogg','ambigen13.ogg','ambigen14.ogg')

		if (prob(35))
			if(A && A:client && !A:client:played)
				A << sound(sound, repeat = 0, wait = 0, volume = 15, channel = 1)
				A:client:played = 1
				spawn(600)
					if(A && A:client)
						A:client:played = 0

