/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'atmos.dmi'
	icon_state = "yellow"
	density = 1
	var/health = 100.0
	flags = FPRINT | CONDUCT

	var/valve_open = 0
	var/release_pressure = ONE_ATMOSPHERE

	var/colour = "yellow"
	var/is_labeled = 0
	var/filled = 0.5
	pressure_resistance = 7*ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = 0
	var/release_log = ""

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	colour = "redws"
	is_labeled = 1
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	colour = "red"
	is_labeled = 1
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	colour = "blue"
	is_labeled = 1
/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Bio)\]"
	icon_state = "orange"
	colour = "orange"
	is_labeled = 1
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	colour = "black"
	is_labeled = 1
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	colour = "grey"
	is_labeled = 1

/obj/machinery/portable_atmospherics/canister/update_icon()
	src.overlays = 0

	if (src.destroyed)
		src.icon_state = text("[]-1", src.colour)

	else
		icon_state = "[colour]"
		if(holding)
			overlays += image('atmos.dmi', "can-oT")
			if((holding.icon_state == "oxygen") || (holding.icon_state == "jetpack1") || (holding.icon_state == "jetpack0") || (holding.icon_state == "emergency"))
				overlays += image('atmos.dmi', "can-open_ox")
			if(holding.icon_state == "plasma")
				overlays += image('atmos.dmi', "can-open_pl")
			if(holding.icon_state == "anesthetic")
				overlays += image('atmos.dmi', "can-open_an")

		var/tank_pressure = air_contents.return_pressure()

		if (tank_pressure < 10)
			overlays += image('atmos.dmi', "can-o0")
		else if (tank_pressure < ONE_ATMOSPHERE)
			overlays += image('atmos.dmi', "can-o1")
		else if (tank_pressure < 15*ONE_ATMOSPHERE)
			overlays += image('atmos.dmi', "can-o2")
		else
			overlays += image('atmos.dmi', "can-o3")
	return

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(src.loc, 'spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process()
	if (destroyed)
		return

	..()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
			src.update_icon()

	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/blob_act()
	src.health -= 1
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/meteorhit(var/obj/O as obj)
	src.health = 0
	healthcheck()
	return

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		for(var/mob/V in viewers(src, null))
			V.show_message(text("\red [user] hits the [src] with a [W]!"))
		src.health -= W.force
		healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user as mob)
	if (src.destroyed)
		return

	user.machine = src
	var/holding_text
	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B>[!is_labeled?" <A href='?src=\ref[src];relabel=1'><small>relabel</small></a>":""]<BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Release Valve: <A href='?src=\ref[src];toggle=1'>[valve_open?("Open"):("Closed")]</A><BR>
Release Pressure: <A href='?src=\ref[src];pressure_adj=-1000'>-</A> <A href='?src=\ref[src];pressure_adj=-100'>-</A> <A href='?src=\ref[src];pressure_adj=-10'>-</A> <A href='?src=\ref[src];pressure_adj=-1'>-</A> [release_pressure] <A href='?src=\ref[src];pressure_adj=1'>+</A> <A href='?src=\ref[src];pressure_adj=10'>+</A> <A href='?src=\ref[src];pressure_adj=100'>+</A> <A href='?src=\ref[src];pressure_adj=1000'>+</A><BR>
<HR>
<A href='?src=\ref[user];mach_close=canister'>Close</A><BR>
"}

	user << browse("<html><head><title>[src]</title></head><body>[output_text]</body></html>", "window=canister;size=600x300")
	onclose(user, "canister")
	return

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src

		if(href_list["toggle"])
			if (valve_open)
				if (holding)
					release_log += "Valve was <b>closed</b> by [usr], stopping the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>closed</b> by [usr], stopping the transfer into the <font colour='red'><b>air</b></font><br>"
			else
				if (holding)
					playsound(src.loc, 'oxygen_desk.ogg', 20, 1)
					release_log += "Valve was <b>opened</b> by [usr], starting the transfer into the [holding]<br>"
				else
					playsound(src.loc, 'oxygen_desk.ogg', 20, 1)
					release_log += "Valve was <b>opened</b> by [usr], starting the transfer into the <font colour='red'><b>air</b></font><br>"
			valve_open = !valve_open

		if (href_list["remove_tank"])
			if(holding)
				holding.loc = loc
				holding = null

		if (href_list["pressure_adj"])
			var/diff = text2num(href_list["pressure_adj"])
			if(diff > 0)
				release_pressure = min(10*ONE_ATMOSPHERE, release_pressure+diff)
			else
				release_pressure = max(ONE_ATMOSPHERE/10, release_pressure+diff)

		if (href_list["relabel"])
			if (!is_labeled)
				var/list/colours = list(\
					"\[N2O\]" = "redws", \
					"\[N2\]" = "red", \
					"\[O2\]" = "blue", \
					"\[Toxin (Bio)\]" = "orange", \
					"\[CO2\]" = "black", \
					"\[Air\]" = "grey", \
					"\[CAUTION\]" = "yellow", \
				)
				var/label = input("Choose canister label", "Gas canister") as null|anything in colours
				if (label)
					src.colour = colours[label]
					src.icon_state = colours[label]
					src.name = "Canister: [label]"
					is_labeled = 1
		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=canister")
		return
	return

/obj/machinery/portable_atmospherics/canister/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		src.health = 0
		spawn( 0 )
			healthcheck()
			return
	return

/obj/machinery/portable_atmospherics/canister/toxins/New()

	..()

	src.air_contents.toxins = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/oxygen/New()

	..()

	src.air_contents.oxygen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

/obj/machinery/portable_atmospherics/canister/sleeping_agent/New()

	..()

	var/datum/gas/sleeping_agent/trace_gas = new
	air_contents.trace_gases += trace_gas
	trace_gas.moles = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1

//Dirty way to fill room with gas. However it is a bit easier to do than creating some floor/engine/n2o -rastaf0
/obj/machinery/portable_atmospherics/canister/sleeping_agent/roomfiller/New()
	..()
	var/datum/gas/sleeping_agent/trace_gas = air_contents.trace_gases[1]
	trace_gas.moles = 9*4000
	spawn(10)
		var/turf/simulated/location = src.loc
		if (istype(src.loc))
			while (!location.air)
				sleep(10)
			location.assume_air(air_contents)
			air_contents = new
	return 1

/obj/machinery/portable_atmospherics/canister/nitrogen/New()

	..()

	src.air_contents.nitrogen = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/carbon_dioxide/New()

	..()
	src.air_contents.carbon_dioxide = (src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1


/obj/machinery/portable_atmospherics/canister/air/New()

	..()
	src.air_contents.oxygen = (O2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	src.air_contents.nitrogen = (N2STANDARD*src.maximum_pressure*filled)*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	src.update_icon()
	return 1
