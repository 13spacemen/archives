/obj/dummy/chameleon
	name = ""
	desc = ""
	density = 0
	anchored = 1
	var/can_move = 1
	var/obj/item/device/chameleon/master = null
	attackby()
		for(var/mob/M in src)
			M << "\red Your chameleon-projector deactivates."
		master.disrupt()
	attack_hand()
		for(var/mob/M in src)
			M << "\red Your chameleon-projector deactivates."
		master.disrupt()
	ex_act()
		for(var/mob/M in src)
			M << "\red Your chameleon-projector deactivates."
		master.disrupt()
	bullet_act()
		for(var/mob/M in src)
			M << "\red Your chameleon-projector deactivates."
		master.disrupt()
	relaymove(var/mob/user, direction)
		if(can_move)
			can_move = 0
			spawn(10) can_move = 1
			step(src,direction)
		return

/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags = FPRINT | TABLEPASS| CONDUCT | USEDELAY | ONBELT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var/can_use = 1
	var/obj/dummy/chameleon/active_dummy = null
	var/saved_item = "/obj/item/weapon/shard"
	origin_tech = "syndicate=2;magnets=3"

	dropped()
		disrupt()

	attack_self()
		toggle()

	afterattack(atom/target, mob/user , flag)
		if(istype(target,/obj/item))
			playsound(src, 'flash.ogg', 100, 1, 1)
			user << "\blue Scanned [target]."
			saved_item = target.type

	proc/toggle()
		if(!can_use || !saved_item) return
		if(active_dummy)
			playsound(src, 'pop.ogg', 100, 1, 1)
			for(var/atom/movable/A in active_dummy)
				A.loc = get_turf(active_dummy)
				if(ismob(A))
					if(A:client)
						A:client:eye = A
			del(active_dummy)
			active_dummy = null
			usr << "\blue You deactivate the [src]."
			var/obj/overlay/T = new/obj/overlay(get_turf(src))
			T.icon = 'effects.dmi'
			flick("emppulse",T)
			spawn(8) del(T)
		else
			playsound(src, 'pop.ogg', 100, 1, 1)
			var/obj/O = new saved_item (src)
			if(!O) return
			var/obj/dummy/chameleon/C = new/obj/dummy/chameleon(get_turf(src))
			C.name = O.name
			C.desc = O.desc
			C.icon = O.icon
			C.icon_state = O.icon_state
			C.dir = O.dir
			usr.loc = C
			C.master = src
			src.active_dummy = C
			del(O)
			usr << "\blue You activate the [src]."
			var/obj/overlay/T = new/obj/overlay(get_turf(src))
			T.icon = 'effects.dmi'
			flick("emppulse",T)
			spawn(8) del(T)

	proc/disrupt()
		if(active_dummy)
			var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread
			spark_system.set_up(5, 0, src)
			spark_system.attach(src)
			spark_system.start()
			for(var/atom/movable/A in active_dummy)
				A.loc = get_turf(active_dummy)
				if(ismob(A))
					if(A:client)
						A:client:eye = A
			del(active_dummy)
			active_dummy = null
			can_use = 0
			spawn(100) can_use = 1
