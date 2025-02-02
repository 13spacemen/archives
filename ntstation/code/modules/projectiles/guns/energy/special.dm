/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man-portable anti-armor weapon designed to disable mechanical threats at range."
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=2;magnets=4"
	w_class = 5
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	origin_tech = "combat=5;materials=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "obj/item/gun.dmi"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1

	attack_self(mob/living/user as mob)
		select_fire(user)
		update_icon()
		return

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = "/obj/item/weapon/stock_parts/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

	New()
		..()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()

	process()
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)

	update_icon()
		return


/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	w_class = 1


/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)

/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
	var/overheat = 0
	var/recent_reload = 1
	var/range_add = 0
	var/overheat_time = 20
	upgrades = list("diamond" = 0, "screwdriver" = 0, "plasma" = 0)


/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act()
	return // so it stops breaking from EMPs


/obj/item/weapon/gun/energy/kinetic_accelerator/newshot()
	..()
	if(chambered && chambered.BB)
		var/obj/item/projectile/kinetic/charge = chambered.BB
		charge.range += range_add


/obj/item/weapon/gun/energy/kinetic_accelerator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver) && upgrades["screwdriver"] < 3)
		upgrades["screwdriver"]++
		overheat_time -= 1
		user << "<span class='info'>You tweak [src]'s thermal exchanger.</span>"


	else if(istype(W, /obj/item/stack))
		var/obj/item/stack/S = W

		if(istype(S, /obj/item/stack/sheet/mineral/diamond) && upgrades["diamond"] < 3)
			upgrades["diamond"]++
			overheat_time -= 3
			user << "<span class='info'>You upgrade [src]'s thermal exchanger with diamonds.</span>"
			S.use(1)

		if(istype(S, /obj/item/stack/sheet/mineral/plasma) && upgrades["plasma"] < 3)
			upgrades["plasma"]++
			range_add++
			user << "<span class='info'>You upgrade [src]'s accelerating chamber with plasma.</span>"
			if(prob(5 * range_add * range_add) && power_supply)
				overheat = 1 // Will permanently break this gun.
			S.use(1)


/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	overheat = 1
	spawn(overheat_time)
		overheat = 0
		recent_reload = 0
	..()

/obj/item/weapon/gun/energy/kinetic_accelerator/attack_self(var/mob/living/user/L)
	if(overheat || recent_reload)
		return
	power_supply.give(500)
	playsound(src.loc, 'sound/weapons/shotgunpump.ogg', 60, 1)
	recent_reload = 1
	update_icon()
	return


/obj/item/weapon/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	force = 15
	modifystate = -1
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=2;engineering=1"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	flags = CONDUCT | OPENCONTAINER | SHARP
	attack_verb = list("attacked", "slashed", "cut", "sliced")
	can_charge = 0
	var/volume = 15

/obj/item/weapon/gun/energy/plasmacutter/New()
	..()
	create_reagents(volume)

/obj/item/weapon/gun/energy/plasmacutter/newshot()
	if (!ammo_type || !reagents)	return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]

	var/amount = shot.e_cost / 100

	if(!reagents.get_reagent_amount("plasma") >= amount)
		return

	reagents.remove_reagent("plasma", amount)
	chambered = shot
	chambered.newshot()
	return

/obj/item/weapon/gun/energy/plasmacutter/examine()
	..()
	usr << "Has [reagents.get_reagent_amount("plasma")] unit\s of plasma left."
	return

/obj/item/weapon/gun/energy/plasmacutter/attackby(var/obj/item/A, var/mob/user)
	if(reagents.maximum_volume > reagents.total_volume)
		if(istype(A, /obj/item/stack/sheet/mineral/plasma))
			var/obj/item/stack/sheet/S = A
			S.use(1)
			reagents.add_reagent("plasma", 20)
			user << "<span class='info'>You refill [src] with [S]. [reagents.get_reagent_amount("plasma")] units of plasma left.</span>"
		if(istype(A, /obj/item/weapon/ore/plasma))
			qdel(A)
			reagents.add_reagent("plasma", 10)
			user << "<span class='info'>You refill [src] with [A]. [reagents.get_reagent_amount("plasma")] units of plasma left.</span>"
		if(istype(A, /obj/item/weapon/storage/bag/ore))
			if(locate(/obj/item/weapon/ore/plasma) in A)
				attackby(locate(/obj/item/weapon/ore/plasma) in A, user)
	..()

/obj/item/weapon/gun/energy/plasmacutter/charged/New()
	..()
	reagents.add_reagent("plasma", volume)

/obj/item/weapon/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=3;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)
	volume = 25


/obj/item/weapon/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts targets, weakening them until they collapse. Typically used against hostile wildlife by exploration teams; though after proving ineffective against the common space carp, was issued to some of the less-fortunate NT security teams."
	icon_state = "disabler"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	cell_type = "/obj/item/weapon/stock_parts/cell"
