/obj/spell/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	recharge = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1 //can affect only the user by default, but with var editing can be an invis other spell
	var/jaunt_duration = 50 //in deciseconds

/obj/spell/ethereal_jaunt/Click()
	..()

	if(!cast_check())
		return

	var/mob/M

	if(range>=0)
		M = input("Choose whom to jaunt", "ABRAKADABRA") as mob in view(usr,range)
	else
		M = usr

	invocation()

	spawn(0)
		var/mobloc = get_turf(M.loc)
		var/obj/dummy/spell_jaunt/holder = new /obj/dummy/spell_jaunt( mobloc )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		flick("liquify",animation)
		M.loc = holder
		M.client.eye = holder
		var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread()
		steam.set_up(10, 0, mobloc)
		steam.start()
		sleep(jaunt_duration)
		mobloc = get_turf(M.loc)
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		M.canmove = 0
		sleep(20)
		flick("reappear",animation)
		sleep(5)
		M.loc = mobloc
		M.canmove = 1
		M.client.eye = M
		del(animation)
		del(holder)

/obj/dummy/spell_jaunt
	name = "water"
	icon = 'effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/dummy/spell_jaunt/relaymove(var/mob/user, direction)
	if (!src.canmove) return
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/dummy/spell_jaunt/ex_act(blah)
	return
/obj/dummy/spell_jaunt/bullet_act(blah,blah)
	return