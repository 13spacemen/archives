/obj/item/device/transfer_valve
	icon = 'assemblies.dmi'
	name = "Tank transfer valve" // because that's what it is exadv1 and don't you dare change it
	icon_state = "valve_1"
	desc = "Regulates the transfer of air between two tanks"
	var/obj/item/weapon/tank/tank_one
	var/obj/item/weapon/tank/tank_two
	var/obj/item/device/attached_device
	var/device_type = 0
	var/mob/attacher = "Unknown"
	var/valve_open = 0
	var/toggle = 1


	attackby(obj/item/item, mob/user)
		if(istype(item, /obj/item/weapon/tank))
			if(tank_one && tank_two)
				user << "\red There are already two tanks attached, remove one first!"
				return

			if(!tank_one)
				tank_one = item
				user.drop_item()
				item.loc = src
				user << "\blue You attach the tank to the transfer valve"
			else if(!tank_two)
				tank_two = item
				user.drop_item()
				item.loc = src
				user << "\blue You attach the tank to the transfer valve!"

			update_icon()

		else if(istype(item, /obj/item/device/radio/signaler) || istype(item, /obj/item/device/timer) || istype(item, /obj/item/device/infra) || istype(item, /obj/item/device/prox_sensor))
			if(attached_device)
				user << "\red There is already an device attached to the valve, remove it first!"
				return

			attached_device = item
			user.drop_item()
			item.loc = src
			user << "\blue You attach the [item] to the valve controls!"
			item.master = src

			bombers += "[key_name(user)] attached a [item] to a transfer valve."
			message_admins("[key_name_admin(user)] attached a [item] to a transfer valve.")
			attacher = key_name(user)
		if(istype(item, /obj/item/device/radio/signaler))
			src.device_type = 1
		else if(istype(item, /obj/item/device/timer))
			src.device_type = 2
//		else if(istype(item, /obj/item/device/infra))
//			src.device_type = 3
		else if(istype(item, /obj/item/device/prox_sensor))
			src.device_type = 4
		update_icon()
		return


	attack_self(mob/user as mob)
		user.machine = src
		var/dat = {"<B> Valve properties: </B>
		<BR> <B> Attachment one:</B> [tank_one] [tank_one ? "<A href='?src=\ref[src];tankone=1'>Remove</A>" : ""]
		<BR> <B> Attachment two:</B> [tank_two] [tank_two ? "<A href='?src=\ref[src];tanktwo=1'>Remove</A>" : ""]
		<BR> <B> Valve attachment:</B> [attached_device ? "<A href='?src=\ref[src];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='?src=\ref[src];rem_device=1'>Remove</A>" : ""]
		<BR> <B> Valve status: </B> [ valve_open ? "<A href='?src=\ref[src];open=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];open=1'>Open</A>"]"}

		user << browse(dat, "window=trans_valve;size=600x300")
		onclose(user, "trans_valve")
		return


	Topic(href, href_list)
		..()
		if (usr.stat|| usr.restrained())
			return
		if (src.loc == usr)
			if(href_list["tankone"])
				split_gases()
				valve_open = 0
				tank_one.loc = get_turf(src)
				tank_one = null
				update_icon()
			if(href_list["tanktwo"])
				split_gases()
				valve_open = 0
				tank_two.loc = get_turf(src)
				tank_two = null
				update_icon()
			if(href_list["open"])
				toggle_valve()
			if(href_list["rem_device"])
				if(attached_device)
					attached_device.loc = get_turf(src)
					attached_device.master = null
					attached_device = null
					device_type = 0
				update_icon()
			if(href_list["device"])
				attached_device.attack_self(usr)

			src.attack_self(usr)

			src.add_fingerprint(usr)
			return

	receive_signal(signal)
		if(toggle)
			toggle = 0
			toggle_valve()
			spawn(50) // To stop a signal being spammed from a proxy sensor constantly going off or whatever
				toggle = 1

	process()

	update_icon()
		src.overlays = new/list()
		src.underlays = new/list()
		if(!tank_one && !tank_two && !attached_device)
			icon_state = "valve_1"
			return
		if(!tank_one && !tank_two && attached_device)
			if(device_type == 1)
				icon_state = "valve_1_radio"
			if(device_type == 2)
				icon_state = "valve_1_timer"
//			if(device_type == 3)
//				icon_state = "valve_1_radio"
			if(device_type == 4)
				icon_state = "valve_1_prox"
		icon_state = "valve"
		var/tank_one_icon = ""
		var/tank_two_icon = ""
		if(tank_one)
			tank_one_icon = tank_one.icon_state
		if(tank_two)
			tank_two_icon = tank_two.icon_state
		if(tank_one)
			var/icon/I = new(src.icon, icon_state = "[tank_one_icon]")
			//var/obj/overlay/tank_one_overlay = new
			//tank_one_overlay.icon = src.icon
			//tank_one_overlay.icon_state = tank_one_icon
			src.underlays += I
		if(tank_two)
			var/icon/J = new(src.icon, icon_state = "[tank_two_icon]")
			//I.Flip(EAST) this breaks the perspective!
			J.Shift(WEST, 13)
			//var/obj/underlay/tank_two_overlay = new
			//tank_two_overlay.icon = I
			src.underlays += J
		if(attached_device)
			var/icon/K = new(src.icon, icon_state = "device")
			//var/obj/overlay/device_overlay = new
			//device_overlay.icon = src.icon
			//device_overlay.icon_state = device_icon
			src.overlays += K
	proc
		merge_gases()
			tank_two.air_contents.volume += tank_one.air_contents.volume
			var/datum/gas_mixture/temp
			temp = tank_one.air_contents.remove_ratio(1)
			tank_two.air_contents.merge(temp)

		split_gases()
			if (!valve_open || !tank_one || !tank_two)
				return
			var/ratio1 = tank_one.air_contents.volume/tank_two.air_contents.volume
			var/datum/gas_mixture/temp
			temp = tank_two.air_contents.remove_ratio(ratio1)
			tank_one.air_contents.merge(temp)
			tank_two.air_contents.volume -=  tank_one.air_contents.volume

		/*
		Exadv1: I know this isn't how it's going to work, but this was just to check
		it explodes properly when it gets a signal (and it does).
		*/

		toggle_valve()
			if(valve_open==0 && (tank_one && tank_two))
				valve_open = 1
				var/turf/bombturf = get_turf(src)
				var/bombarea = bombturf.loc.name

				bombers += "Bomb valve opened in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]"
				message_admins("Bomb valve opened in [bombarea] with device attacher: [attacher]. Last touched by: [src.fingerprintslast]")

				merge_gases()
				spawn(20) // In case one tank bursts
					for (var/i=0,i<5,i++)
						src.update_icon()
						sleep(10)
					src.update_icon()

			else if(valve_open==1 && (tank_one && tank_two))
				split_gases()
				valve_open = 0
				src.update_icon()

		// this doesn't do anything but the timer etc. expects it to be here
		// eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
		c_state()
			return



/obj/falsewall/
	attack_hand(mob/user as mob)
		if(density)
			// Open wall
			icon_state = "fwall_open"
			flick("fwall_opening", src)
			sleep(15)
			src.density = 0
			src.sd_SetOpacity(0)
			var/turf/T = src.loc
			T.sd_LumReset()

		else
			icon_state = "wall"
			flick("fwall_closing", src)
			sleep(15)
			src.density = 1
			src.sd_SetOpacity(1)
			var/turf/T = src.loc
			//T.sd_LumUpdate()
			src.relativewall()
			T.sd_LumReset()


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/screwdriver))
			var/turf/T = get_turf(src)
			user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
			T.ReplaceWithWall()
			del(src)
			//

	/*

		var/turf/T = get_turf(user)
		user << "\blue Now adding plating..."
		sleep(40)
		if (get_turf(user) == T)
			user << "\blue You added the plating!"
			var/turf/Tsrc = get_turf(src)
			Tsrc.ReplaceWithWall()

	*/

/obj/falserwall/
	attack_hand(mob/user as mob)
		if(density)
			// Open wall
			icon_state = "frwall_open"
			flick("frwall_opening", src)
			sleep(15)
			src.density = 0
			src.sd_SetOpacity(0)
			var/turf/T = src.loc
			T.sd_LumReset()

		else
			icon_state = "r_wall"
			flick("frwall_closing", src)
			sleep(15)
			src.density = 1
			src.sd_SetOpacity(1)
			var/turf/T = src.loc
			//T.sd_LumUpdate()
			src.relativewall()
			T.sd_LumReset()


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/screwdriver))
			var/turf/T = get_turf(src)
			user.visible_message("[user] tightens some bolts on the r wall.", "You tighten the bolts on the r wall.")
			T.ReplaceWithWall() //Intentionally makes a regular wall instead of an r-wall (no cheap r-walls for you).
			del(src)