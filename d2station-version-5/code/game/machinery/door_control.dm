/obj/machinery/door_control/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(5)
	icon_state = "doorctrl1"
	playsound(src, 'buttonclick.ogg', 30, 0)

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			if (M.density)
				spawn( 0 )
					M.open()
					return
			else
				spawn( 0 )
					M.close()
					return

	for(var/obj/machinery/blinds/M in machines)
		if (M.id == src.id)
			if (M.opacity)
				spawn( 0 )
					M.open()
					return
			else
				spawn( 0 )
					M.close()
					return

	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"
	src.add_fingerprint(usr)

/obj/machinery/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/driver_button/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user as mob)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user as mob)

	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(10)

	for(var/obj/machinery/mass_driver/M in machines)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0

	return