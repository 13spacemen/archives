obj/machinery/recharger
	anchored = 1.0
	icon = 'stationobjs.dmi'
	icon_state = "recharger0"
	name = "recharger"
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 250

	var
		obj/item/weapon/gun/energy/charging = null
		obj/item/weapon/baton/charging2 = null

/obj/machinery/recharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if (src.charging || src.charging2)
		return
	if ((istype(G, /obj/item/weapon/gun/energy)) || (istype(G, /obj/item/weapon/gun/magnetrifle)))
		if (istype(G, /obj/item/weapon/gun/energy/general/atomic))
			user << "\blue This is incompatible!"
			return
		user.drop_item()
		G.loc = src
		src.charging = G
		use_power = 2
	if (istype(G, /obj/item/weapon/baton))
		user.drop_item()
		G.loc = src
		src.charging2 = G
		use_power = 2

/obj/machinery/recharger/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	if (src.charging)
		src.charging.update_icon()
		src.charging.loc = src.loc
		src.charging = null
		use_power = 1
	if(src.charging2)
		src.charging2.update_icon()
		src.charging2.loc = src.loc
		src.charging2 = null
		use_power = 1


/obj/machinery/recharger/attack_paw(mob/user as mob)
	if ((ticker && ticker.mode.name == "monkey"))
		return src.attack_hand(user)

/obj/machinery/recharger/process()
	if ((src.charging) && ! (stat & NOPOWER) )
		if (src.charging.charges < src.charging.maximum_charges)
			src.charging.charges++
			src.icon_state = "recharger1"
			use_power(250)
		else
			src.icon_state = "recharger2"
	if ((src.charging2) && ! (stat & NOPOWER) )
		if (src.charging2.charges < src.charging2.maximum_charges)
			src.charging2.charges++
			src.icon_state = "recharger1"
			use_power(250)
		else
			src.icon_state = "recharger2"
	else if (!(src.charging || src.charging2))
		src.icon_state = "recharger0"
