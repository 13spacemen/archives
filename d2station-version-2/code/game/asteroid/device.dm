/obj/item/device/gps
	name = "GPS"
	icon = 'device.dmi'
	icon_state = "pinoff"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/obj/ship_landing_beacon/beacon = null
	var/active = 0

	attack_self()
		if(!active)
			active = 1
			work()
			usr << "\blue You activate the GPS"
		else
			active = 0
			icon_state = "pinoff"
			usr << "\blue You deactivate the GPS"

	proc/work()
		while(active)
			if(!beacon)
				for(var/obj/ship_landing_beacon/B in world)
					if(B.name == "Beacon - SS13")
						beacon = B
						break

				if(!beacon)
					usr << "\red Unable to detect beacon signal."
					active = 0
					icon_state = "pinonnull"
					return

			if(!istype(src.loc, /turf) && !istype(src.loc, /mob))
				usr << "\red Too much interference. Please hold the device in hand or place it on belt."
				active = 0
				icon_state = "pinonnull"
				return

			src.icon_state = "pinonfar"

			var/atom/cur_loc = src.loc

			if(cur_loc.z == beacon.z)
				src.dir = get_dir(cur_loc,beacon)
			else
				var/list/beacon_global_loc = beacon.get_global_map_pos()
				var/list/src_global_loc = cur_loc.get_global_map_pos()
				if(beacon_global_loc && src_global_loc)
					var/hor_dir = 0
					var/ver_dir = 0
					if(beacon_global_loc["x"]>src_global_loc["x"])
						hor_dir = EAST
					else if(beacon_global_loc["x"]<src_global_loc["x"])
						hor_dir = WEST

					if(beacon_global_loc["y"]>src_global_loc["y"])
						ver_dir = NORTH
					else if(beacon_global_loc["y"]<src_global_loc["y"])
						ver_dir = SOUTH

					src.dir = hor_dir|ver_dir
			sleep(5)


/obj/item/weapon/storage/explorers_box
	name = "SpaceFriend(tm)"
	icon_state = "box"
	desc = "Everything a dashing space explorer would want to have near in the grim darkness of... whatever."

/obj/item/weapon/storage/explorers_box/New()
	..()
	new /obj/item/device/radio/beacon(src)
	new /obj/item/device/gps(src)
	new /obj/item/device/flashlight(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/snacks/chips(src)
	new /obj/item/weapon/cigpacket(src)
	var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src)
	P.reagents.add_reagent("cyanide", 30)
	P.name = "Cyanide pill"
	return