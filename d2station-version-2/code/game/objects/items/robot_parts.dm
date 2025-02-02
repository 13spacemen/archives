/obj/item/robot_parts
	name = "robot parts"
	icon = 'robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	icon_state = "l_arm"

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	icon_state = "r_arm"

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	icon_state = "l_leg"

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	icon_state = "r_leg"

/obj/item/robot_parts/chest
	name = "robot chest"
	icon_state = "chest"
	var/wires = 0.0
	var/obj/item/weapon/cell/cell = null

/obj/item/robot_parts/head
	name = "robot head"
	icon_state = "head"
	var/obj/item/device/flash/flash1 = null
	var/obj/item/device/flash/flash2 = null

/obj/item/robot_parts/robot_suit
	name = "robot suit"
	icon_state = "robo_suit"
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null
	var/obj/item/brain/brain = null
	var/created_name = "Cyborg"

/obj/item/robot_parts/robot_suit/New()
	..()
	src.updateicon()

/obj/item/robot_parts/robot_suit/proc/updateicon()
	src.overlays = null
	if(src.l_arm)
		src.overlays += "l_arm+o"
	if(src.r_arm)
		src.overlays += "r_arm+o"
	if(src.chest)
		src.overlays += "chest+o"
	if(src.l_leg)
		src.overlays += "l_leg+o"
	if(src.r_leg)
		src.overlays += "r_leg+o"
	if(src.head)
		src.overlays += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/sheet/metal))
//		var/obj/item/weapon/ed209_assembly/B = new /obj/item/weapon/ed209_assembly
//		B.loc = get_turf(src)
		user << "You armed the robot frame"
		W:use(1)
		if (user.get_inactive_hand()==src)
			user.before_take_item(src)
//			user.put_in_inactive_hand(B)
		del(src)
	if(istype(W, /obj/item/robot_parts/l_leg))
		user.drop_item()
		W.loc = src
		src.l_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_leg))
		user.drop_item()
		W.loc = src
		src.r_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/l_arm))
		user.drop_item()
		W.loc = src
		src.l_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_arm))
		user.drop_item()
		W.loc = src
		src.r_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/chest))

		if(W:wires && W:cell)
			user.drop_item()
			W.loc = src
			src.chest = W
			src.updateicon()
		else if(!W:wires)
			user << "\blue You need to attach wires to it first!"
		else
			user << "\blue You need to attach a cell to it first!"

	if(istype(W, /obj/item/robot_parts/head))
		if(W:flash2 && W:flash1)
			user.drop_item()
			W.loc = src
			src.head = W
			src.updateicon()
		else
			user << "\blue You need to attach a flash to it first!"

	if(istype(W, /obj/item/device/mmi))
		if(src.check_completion())
			if(!istype(src.loc,/turf))
				user << "\red You can't put the MMI in, the frame has to be standing on the ground to be perfectly precise."
				return
			if(!W:brain)
				user << "\red Sticking an empty MMI into the frame would sort of defeat the purpose."
				return
			if(W:brain.brainmob.stat == 2)
				user << "\red Sticking a dead brain into the frame would sort of defeat the purpose."
				return
			user.drop_item()
			W.loc = src
			src.brain = W
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(src.loc))
			//O.start = 1
			O.invisibility = 0
			O.name = src.created_name
			O.real_name = src.created_name

			if (W:brain.brainmob)
				W:brain.brainmob.mind.transfer_to(O)
			else
				for(var/mob/dead/observer/G in world)
					if(G.corpse == W:brain.brainmob && G.client)
						G.corpse.mind.transfer_to(O)
						del(G)
						break
			if(O.mind)
				if(O.mind.special_role) O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

			O.loc = src.loc
			O << "<B>You are playing a Robot. The Robot can interact with most electronic objects in its view point.</B>"
			O << "<B>You must follow the laws that the AI has. You are the AI's assistant to the station basically.</B>"
			O << "To use something, simply double-click it."
			O << {"Use say ":s to speak to fellow cyborgs and the AI through binary."}

			//SN src = null
			O.job = "Cyborg"

			O.cell = src.chest.cell
			O.cell.loc = O
			O.brain = W

			del(src)
		else
			user << "\blue The MMI must go in after everything else!"

	if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

	return

/obj/item/robot_parts/chest/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cell))
		if(src.cell)
			user << "\blue You have already inserted a cell!"
			return
		else
			user.drop_item()
			W.loc = src
			src.cell = W
			user << "\blue You insert the cell!"
	if(istype(W, /obj/item/weapon/cable_coil))
		if(src.wires)
			user << "\blue You have already inserted wire!"
			return
		else
			var/obj/item/weapon/cable_coil/coil = W
			coil.use(1)
			src.wires = 1.0
			user << "\blue You insert the wire!"
	return

/obj/item/robot_parts/head/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/device/flash))
		if(src.flash1 && src.flash2)
			user << "\blue You have already inserted the eyes!"
			return
		else if(src.flash1)
			user.drop_item()
			W.loc = src
			src.flash2 = W
			user << "\blue You insert the flash into the eye socket!"
		else
			user.drop_item()
			W.loc = src
			src.flash1 = W
			user << "\blue You insert the flash into the eye socket!"
	return

