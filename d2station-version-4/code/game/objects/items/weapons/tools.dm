/*
CONTAINS:

WRENCH
SCREWDRIVER
WELDINGTOOOL
*/


// WRENCH
/obj/item/weapon/wrench/New()
	if (prob(75))
		src.pixel_x = rand(0, 16)
	return




// SCREWDRIVER
/obj/item/weapon/screwdriver/New()
	icon_state = pick("screwdriver","screwdriver2","screwdriver3","screwdriver4","screwdriver5","screwdriver6","screwdriver7")
	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if((user.mutations & CLOWN) && prob(50))
		M = user
	return eyestab(M,user)




// WELDING TOOL
/obj/item/weapon/weldingtool
	name = "Welding Tool"
	icon = 'items.dmi'
	icon_state = "welder"
	flags = FPRINT | TABLEPASS| CONDUCT | OPENCONTAINER
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	m_amt = 70
	g_amt = 30
	origin_tech = "engineering=1"
	var
		welding = 0
		status = 0
		max_fuel = 20


	New()
		var/random_fuel = min(rand(10,20),max_fuel)
		var/datum/reagents/R = new/datum/reagents(max_fuel)
		reagents = R
		R.my_atom = src
		R.add_reagent("fuel", random_fuel)
		return


	examine()
		set src in usr
		usr << text("\icon[] [] contains []/[] units of fuel!", src, src.name, get_fuel(),src.max_fuel )
		return


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/weapon/screwdriver))
			status = !status
			if (status)
				user << "\blue You resecure the welder."
			else
				user << "\blue The welder can now be attached and modified."
			src.add_fingerprint(user)
		else if (status == 1 && istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/R = W
			R.use(1)
			var/obj/item/assembly/weld_rod/F = new /obj/item/assembly/weld_rod( user )
			src.loc = F
			F.part1 = src
			if (user.client)
				user.client.screen -= src
			if (user.r_hand == src)
				user.u_equip(src)
				user.r_hand = F
			else
				user.u_equip(src)
				user.l_hand = F
			R.master = F
			src.master = F
			src.layer = initial(src.layer)
			user.u_equip(src)
			if (user.client)
				user.client.screen -= src
			src.loc = F
			F.part2 = W
			F.layer = 20
			R.layer = 20
			F.loc = user
			src.add_fingerprint(user)
		else
			..()


	process()
		switch(welding)
			if(0)
				processing_items.Remove(src)
				return
			if(1)
				if(prob(5))//Welders left on now use up fuel, but lets not have them run out quite that fast
					remove_fuel(1)
			if(2)
				if(prob(75))
					remove_fuel(1)
					//if you're actually actively welding, use fuel faster.

		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = get_turf(M)
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)


	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if (src.welding && M.frozen)
			meltfrozen(M, user)


	afterattack(obj/O as obj, mob/user as mob)
		if (istype(O, /obj/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && !src.welding)
			O.reagents.trans_to(src, max_fuel)
			user << "\blue Welder refueled"
			playsound(src.loc, 'refill.ogg', 50, 1, -6)
			return
		else if (istype(O, /obj/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.welding)
			message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			user << "\red That was stupid of you."
			user.achievement_give("Stupid", 74)
			explosion(O.loc,-1,0,2)
			if(O)
				del(O)
			return
		if (src.welding)
			remove_fuel(1)
			var/turf/location = get_turf(user)
			if (istype(location, /turf))
				location.hotspot_expose(700, 50, 1)
		return


	attack_self(mob/user as mob)
		toggle()
		return


	proc


///GET prop for fuel
		get_fuel()
			return reagents.get_reagent_amount("fuel")


///SET prop for fuel
///Will also turn it off if it is out of fuel
///The mob argument is not needed but if included will call eyecheck() on it if the welder is on.
		remove_fuel(var/amount = 1, var/mob/M = null)
			if(!welding || !check_status())
				return 0
			if(get_fuel() >= amount)
				reagents.remove_reagent("fuel", amount)
				check_status()
				if(M)
					eyecheck(M)//TODO:eyecheck should really be in mob not here
				return 1
			else
				if(M)
					M << "\blue You need more welding fuel to complete this task."
				return 0


///Quick check to see if we even have any fuel and should shut off
///This could use a better name
		check_status()
			if((get_fuel() <= 0) && welding)
				toggle(1)
				return 0
			return 1


//toggles the welder off and on
		toggle(var/message = 0)
			if(status > 1)	return
			src.welding = !( src.welding )
			if (src.welding)
				if (remove_fuel(1))
					usr << "\blue You switch the [src] on."
					src.force = 15
					src.damtype = "fire"
					src.icon_state = "welder1"
					processing_items.Add(src)
				else
					usr << "\blue Need more fuel!"
					src.welding = 0
					return
			else
				if(!message)
					usr << "\blue You switch the [src] off."
				else
					usr << "\blue The [src] shuts off!"
				src.force = 3
				src.damtype = "brute"
				src.icon_state = "welder"
				src.welding = 0


		eyecheck(mob/user as mob)//TODO:Move this over to /mob/ where it should be
			//check eye protection
			if(!ishuman(user) && !ismonkey(user))
				return 1
			var/safety = 0
			if (istype(user, /mob/living/carbon/human))
				if (istype(user:head, /obj/item/clothing/head/helmet/welding))
					if (!user:head:up)
						safety = 2
				else if (istype(user:head, /obj/item/clothing/head/helmet/space))
					safety = 2
				else if (istype(user:glasses, /obj/item/clothing/glasses/sunglasses))
					safety = 1

				else if (istype(user:glasses, /obj/item/clothing/glasses/thermal))
					safety = -1
				else
					safety = 0
			switch(safety)
				if(1)
					usr << "\red Your eyes sting a little."
					user.eye_stat += rand(1, 2)
					if(user.eye_stat > 12)
						user.eye_blurry += rand(3,6)
				if(0)
					usr << "\red Your eyes burn."
					user.eye_stat += rand(2, 4)
					if(user.eye_stat > 10)
						user.eye_blurry += rand(4,10)
				if(-1)
					usr << "\red Your thermals intensify the welder's glow. Your eyes itch and burn severely."
					user.eye_blurry += rand(12,20)
					user.eye_stat += rand(12, 16)
			if(user.eye_stat > 10 && safety < 2)
				user << "\red Your eyes are really starting to hurt. This can't be good for you!"
			if (prob(user.eye_stat - 25 + 1))
				user << "\red You go blind!"
				user.sdisabilities |= 1
			else if (prob(user.eye_stat - 15 + 1))
				user << "\red You go blind!"
				user.eye_blind = 5
				user.eye_blurry = 5
				user.disabilities |= 1
				spawn(100)
					user.disabilities &= ~1
			return



/obj/item/weapon/weldingtool/largetank
	name = "Industrial Welding Tool"
	max_fuel = 40
	m_amt = 70
	g_amt = 60
	origin_tech = "engineering=2"

/obj/item/weapon/weldingtool/hugetank
	name = "Upgraded Welding Tool"
	max_fuel = 80
	w_class = 3.0
	m_amt = 70
	g_amt = 120
	origin_tech = "engineering=3"

/obj/item/weapon/weldingtool/experimental
	name = "Experimental Welding Tool"
	max_fuel = 80
	w_class = 3.0
	m_amt = 70
	g_amt = 120
