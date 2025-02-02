// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'stationobjs.dmi'
	icon_state = "mflash1"
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 8
	anchored = 0
	base_state = "pflash"
	density = 1

/obj/machinery/flasher/New()
	sleep(4)
	src.sd_SetLuminosity(2)

/obj/machinery/flasher/power_change()
	if ( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"
		src.sd_SetLuminosity(0)

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("\red [user] has disconnected the [src]'s flashbulb!", "\red You disconnect the [src]'s flashbulb!")
		if (!src.disable)
			user.visible_message("\red [user] has connected the [src]'s flashbulb!", "\red You connect the [src]'s flashbulb!")

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai()
	if (src.anchored)
		return src.flash()
	else
		return

/obj/machinery/flasher/proc/flash()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	playsound(src.loc, 'flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	src.last_flash = world.time
	use_power(1000)

	for (var/mob/O in viewers(src, null))
		if (get_dist(src, O) > src.range)
			continue
		if ((istype(O, /mob/living/carbon/human) && (istype(O:glasses, /obj/item/clothing/glasses/sunglasses))))
			continue
		if (istype(O, /mob/living/carbon/alien))//So aliens don't get flashed (they have no external eyes)/N
			continue

		O.weakened = src.strength
		if ((O.eye_stat > 15 && prob(O.eye_stat + 50)))
			flick("e_flash", O:flash)
			O.eye_stat += rand(1, 2)
		else
			flick("flash", O:flash)
			O.eye_stat += rand(0, 2)


/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if ((src.disable) || (src.last_flash && world.time < src.last_flash + 150))
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if ((M.m_intent != "walk") && (src.anchored))
			src.flash()

/obj/machinery/flasher/portable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		add_fingerprint(user)
		src.anchored = !src.anchored

		if (!src.anchored)
			user.show_message(text("\red [src] can now be moved."))
			src.overlays = null

		else if (src.anchored)
			user.show_message(text("\red [src] is now secured."))
			src.overlays += "[base_state]-s"