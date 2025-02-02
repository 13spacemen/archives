/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	icon = 'stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = 0
	var
		obj/item/weapon/circuitboard/circuit = null
		list/components = null
		list/req_components = null
		state = 1

/obj/machinery/constructable_frame/machine_frame
	attackby(obj/item/P as obj, mob/user as mob)
		if(P.crit_fail)
			user << "\red This part is faulty, you cannot add this to the machine!"
			return
		switch(state)
			if(1)
				if(istype(P, /obj/item/weapon/cable_coil))
					if(P:amount >= 5)
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						user << "\blue You start to add cables to the frame."
						if(do_after(user, 20))
							P:amount -= 5
							if(!P:amount) del(P)
							user << "\blue You add cables to the frame."
							state = 2
							icon_state = "box_1"
				if(istype(P, /obj/item/weapon/wrench))
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					user << "\blue You dismantle the frame"
					new /obj/item/stack/sheet/metal(src.loc, 5)
					del(src)
			if(2)
				if(istype(P, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/B = P
					if(B.board_type == "machine")
						playsound(src.loc, 'Deconstruct.ogg', 50, 1)
						user << "\blue You add the circuit board to the frame."
						circuit = P
						user.drop_item()
						P.loc = src
						icon_state = "box_2"
						state = 3
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						if(circuit.frame_desc) desc = circuit.frame_desc
					else
						user << "\red This frame does not accept circuit boards of this type!"
				if(istype(P, /obj/item/weapon/wirecutters))
					playsound(src.loc, 'Wirecutter.ogg', 50, 1)
					user << "\blue You remove the cables."
					state = 1
					icon_state = "box_0"
					var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( src.loc )
					A.amount = 5

			if(3)
				if(istype(P, /obj/item/weapon/crowbar))
					playsound(src.loc, 'Crowbar.ogg', 50, 1)
					state = 2
					circuit.loc = src.loc
					circuit = null
					if(components.len == 0)
						user << "\blue You remove the circuit board."
					else
						user << "\blue You remove the circuit board and other components."
						for(var/obj/item/weapon/W in components)
							W.loc = src.loc
					desc = initial(desc)
					req_components = null
					components = null
					icon_state = "box_1"

				if(istype(P, /obj/item/weapon/screwdriver))
					var/component_check = 1
					for(var/R in req_components)
						if(req_components[R] > 0)
							component_check = 0
							break
					if(component_check)
						playsound(src.loc, 'Screwdriver.ogg', 50, 1)
						var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
						for(var/obj/O in new_machine.component_parts)
							del(O)
						new_machine.component_parts = list()
						for(var/obj/O in src)
							O.loc = new_machine
							new_machine.component_parts += O
						circuit.loc = new_machine
						new_machine.RefreshParts()
						del(src)

				if(istype(P, /obj/item/weapon))
					for(var/I in req_components)
						if(istype(P, text2path(I)) && (req_components[I] > 0))
							if(istype(P, /obj/item/weapon/cable_coil))
								var/obj/item/weapon/cable_coil/CP = P
								if(CP.amount > 1)
									var/obj/item/weapon/cable_coil/CC = new /obj/item/weapon/cable_coil(src)
									CC.amount = 1
									components += CC
									req_components[I]--
									break
							user.drop_item()
							P.loc = src
							components += P
							req_components[I]--
							break
					if(P.loc != src && !istype(P, /obj/item/weapon/cable_coil))
						user << "\red You cannot add that component to the machine!"


//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/
/obj/item/weapon/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = "/obj/machinery/r_n_d/destructive_analyzer"
	board_type = "machine"
	origin_tech = "magnets=2;engineering=2;programming=2"
	frame_desc = "Requires 2 Scanning Modules, 1 Manipulator, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/obj/item/weapon/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	build_path = "/obj/machinery/autolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins, 1 Manipulator, and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	build_path = "/obj/machinery/r_n_d/protolathe"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 2 Matter Bins, 2 Manipulators, and 2 Beakers."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2)


/obj/item/weapon/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = "/obj/machinery/r_n_d/circuit_imprinter"
	board_type = "machine"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Matter Bin, 1 Manipulator, and 2 Beakers."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2)

/obj/item/weapon/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman"
	board_type = "machine"
	origin_tech = "programming=3:powerstorage=3;plasmatech=3;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Micro-Laser, 2 Pieces of Cable, and 1 Capacitor."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/super"
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/weapon/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"

obj/item/weapon/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = "/obj/machinery/r_n_d/server"
	board_type = "machine"
	origin_tech = "programming=3"
	frame_desc = "Requires 2 pieces of cable, and 1 Scanning Module."
	req_components = list(
							"/obj/item/weapon/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = "/obj/machinery/mecha_part_fabricator"
	board_type = "machine"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 2 Matter Bins, 1 Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = "/obj/machinery/clonepod"
	board_type = "machine"
	origin_tech = "programming=3;biotech=3"
	frame_desc = "Requires 1 Health Analyzer, 2 Manipulator, 1 Scanning Module and 1 Console Screen."
	req_components = list(
							"/obj/item/device/healthanalyzer" = 1,
							"/obj/item/weapon/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = "/obj/machinery/dna_scannernew"
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 1 Health Analyzer, 1 Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							"/obj/item/device/healthanalyzer" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/cable_coil" = 2,)