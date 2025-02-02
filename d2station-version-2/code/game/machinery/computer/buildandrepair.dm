/obj/computerframe
	density = 1
	anchored = 0
	name = "Computer-frame"
	icon = 'stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = 2.0
	name = "Circuit board"
	icon = 'module.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	origin_tech = "programming=2"
	var
		id = null
		frequency = null
		build_path = null
		board_type = "computer"
		list/req_components = null
		powernet = null
		list/records = null

/obj/item/weapon/circuitboard/security
	name = "Circuit board (Security)"
	build_path = "/obj/machinery/computer/security"
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI core)"
	origin_tech = "programming=4;biotech=2"
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	build_path = "/obj/machinery/computer/aiupload"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	build_path = "/obj/machinery/computer/med_data"
/obj/item/weapon/circuitboard/pandemic
	name = "Circuit board (PanD.E.M.I.C. 2200)"
	build_path = "/obj/machinery/computer/pandemic"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = "/obj/machinery/scan_consolenew"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications)"
	build_path = "/obj/machinery/computer/communications"
	origin_tech = "programming=2;magnets=2"
/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	build_path = "/obj/machinery/computer/card"
/obj/item/weapon/circuitboard/shield
	name = "Circuit board (Shield Control)"
	build_path = "/obj/machinery/computer/stationshield"
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	build_path = "/obj/machinery/computer/teleporter"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	build_path = "/obj/machinery/computer/secure_data"
/obj/item/weapon/circuitboard/stationalert
	name = "Circuit board (Station Alerts)"
	build_path = "/obj/machinery/computer/station_alert"
/obj/item/weapon/circuitboard/atmospherealerts
	name = "Circuit board (Atmosphere alerts)"
	build_path = "/obj/machinery/computer/atmosphere/alerts"
/obj/item/weapon/circuitboard/atmospheresiphonswitch
	name = "Circuit board (Atmosphere siphon control)"
	build_path = "/obj/machinery/computer/atmosphere/siphonswitch"
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric monitor)"
	build_path = "/obj/machinery/computer/general_air_control"
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	build_path = "/obj/machinery/computer/general_air_control/fuel_injection"
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	build_path = "/obj/machinery/computer/atmos_alert"
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	build_path = "/obj/machinery/computer/pod"
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	build_path = "/obj/machinery/computer/robotics"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning)"
	build_path = "/obj/machinery/computer/cloning"
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/arcade
	name = "Circuit board (Arcade)"
	build_path = "/obj/machinery/computer/arcade"
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	build_path = "/obj/machinery/computer/turbine_computer"
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"  //name fixed 250810
	build_path = "/obj/machinery/power/solar_control"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"  //name fixed 250810
	build_path = "/obj/machinery/power/monitor"
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	build_path = "/obj/machinery/computer/pod/old"
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = "/obj/machinery/computer/pod/old/syndicate"
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	build_path = "/obj/machinery/computer/pod/old/swf"
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = "/obj/machinery/computer/prisoner"
/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (RD Console)"
	build_path = "/obj/machinery/computer/rdconsole"
/obj/item/weapon/circuitboard/rdservercontrol
	name = "Circuit Board (R&D Server Control)"
	build_path = "/obj/machinery/computer/rdservercontrol"
/obj/item/weapon/circuitboard/curer
	name = "Circuit Board (Cure Research Machine)"
	build_path = "/obj/machinery/computer/curer"
/obj/item/weapon/circuitboard/diseasesplicer
	name = "Circuit Board (Disease Splicer)"
	build_path = "/obj/machinery/computer/diseasesplicer"
/obj/item/weapon/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = "/obj/machinery/computer/mecha"


/obj/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					src.anchored = 1
					src.state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				playsound(src.loc, 'Welder.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You deconstruct the frame."
					new /obj/item/stack/sheet/metal( src.loc, 5 )
					del(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					src.anchored = 0
					src.state = 0
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "computer")
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					user << "\blue You place the circuit board inside the frame."
					src.icon_state = "1"
					src.circuit = P
					user.drop_item()
					P.loc = src
				else
					user << "\red This frame does not accept circuit boards of this type!"
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You screw the circuit board into place."
				src.state = 2
				src.icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the circuit board."
				src.state = 1
				src.icon_state = "0"
				circuit.loc = src.loc
				src.circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the circuit board."
				src.state = 1
				src.icon_state = "1"
			if(istype(P, /obj/item/weapon/cable_coil))
				if(P:amount >= 5)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						if(P)
							P:amount -= 5
							if(!P:amount) del(P)
							user << "\blue You add cables to the frame."
							src.state = 3
							src.icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'wirecutter.ogg', 50, 1)
				user << "\blue You remove the cables."
				src.state = 2
				src.icon_state = "2"
				var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
				A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass))
				if(P:amount >= 2)
					playsound(src.loc, 'Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						if(P)
							P:use(2)
							user << "\blue You put in the glass panel."
							src.state = 4
							src.icon_state = "4"
		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass( src.loc, 2 )
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				user << "\blue You connect the monitor."
				var/B = new src.circuit.build_path ( src.loc )
				if(circuit.powernet) B:powernet = circuit.powernet
				if(circuit.id) B:id = circuit.id
				if(circuit.records) B:records = circuit.records
				if(circuit.frequency) B:frequency = circuit.frequency
				del(src)
