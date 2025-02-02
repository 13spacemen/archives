/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Box"
	desc = "Part of a Particle Accelerator."
	icon = 'particle_accelerator.dmi'
	icon_state = "control_box"
	anchored = 0
	density = 1
	use_power = 0
	idle_power_usage = 500
	active_power_usage = 10000
	construction_state = 0
	active = 0
	var
		list/obj/particle_accelerator/connected_parts
		assembled = 0
		strength = 0


	New()
		connected_parts = list()
		..()


	attack_hand(mob/user as mob)
		if(construction_state >= 3)
			interact(user)


	update_state()
		if(construction_state < 3)
			use_power = 0
			assembled = 0
			active = 0
			connected_parts = list()
			return
		if(!part_scan())
			assembled = 0
		return


	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=pacontrol")
			usr.machine = null
			return
		if(href_list["togglep"])
			src.toggle_power()
		if(href_list["scan"])
			src.part_scan()
		if(href_list["strengthup"])
			src.strength++
			if(src.strength > 2)
				src.strength = 2
		if(href_list["strengthdown"])
			src.strength--
			if(src.strength < 0)
				src.strength = 0
		src.updateDialog()


	process()
		if(src.active)
			for(var/obj/particle_accelerator/particle_emitter/PE in connected_parts)
				if(PE)
					PE.emit_particle(src.strength)
//			for(var/obj/particle_accelerator/fuel_chamber/PF in connected_parts)
//				PF.doshit()
//			for(var/obj/particle_accelerator/power_box/PB in connected_parts)
//				PB.doshit()
			//finish up putting the fuel run and power use things in here
		return


	proc
		part_scan()
			connected_parts = list()
			var/tally = 0
			var/ldir = 0
			var/rdir = 0
			var/odir = 0
			switch(src.dir)
				if(1)
					ldir = 4
					rdir = 8
					odir = 2
				if(2)
					ldir = 8
					rdir = 4
					odir = 1
				if(4)
					ldir = 1
					rdir = 2
					odir = 8
				if(8)
					ldir = 2
					rdir = 1
					odir = 4
			var/turf/T = src.loc
			T = get_step(T,rdir)
			if(check_part(T,/obj/particle_accelerator/fuel_chamber))
				tally++
			T = get_step(T,odir)
			if(check_part(T,/obj/particle_accelerator/end_cap))
				tally++
			T = get_step(T,dir)
			T = get_step(T,dir)
			if(check_part(T,/obj/particle_accelerator/power_box))
				tally++
			T = get_step(T,dir)
			if(check_part(T,/obj/particle_accelerator/particle_emitter/center))
				tally++
			T = get_step(T,ldir)
			if(check_part(T,/obj/particle_accelerator/particle_emitter/left))
				tally++
			T = get_step(T,rdir)
			T = get_step(T,rdir)
			if(check_part(T,/obj/particle_accelerator/particle_emitter/right))
				tally++
			if(tally >= 6)
				assembled = 1
				return 1
			else
				assembled = 0
				return 0


		check_part(var/turf/T, var/type)
			if(!(T)||!(type))
				return 0
			var/obj/particle_accelerator/PA = locate(/obj/particle_accelerator) in T
			if(istype(PA, type))
				if(PA.connect_master(src))
					if(PA.report_ready(src))
						src.connected_parts.Add(PA)
						return 1
			return 0


		toggle_power()
			src.active = !src.active
			if(src.active)
				src.use_power = 2
			else
				src.use_power = 1
			return 1


		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=pacontrol")
					return
			user.machine = src

			var/dat = ""
			dat += "<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' />Particle Accelerator Control Panel<BR>"
			dat += "<A href='?src=\ref[src];close=1'>Close</A><BR><BR>"
			dat += "Status:<BR>"
			if(!assembled)
				dat += "Unable to detect all parts!<BR>"
				dat += "<A href='?src=\ref[src];scan=1'>Run Scan</A><BR><BR>"
			else
				dat += "All parts in place.<BR><BR>"
				dat += "Power:"
				if(active)
					dat += "On<BR>"
				else
					dat += "Off <BR>"
				dat += "<A href='?src=\ref[src];togglep=1'>Toggle Power</A><BR><BR>"
				dat += "Particle Strength: [src.strength] "
				dat += "<A href='?src=\ref[src];strengthdown=1'>--</A>|<A href='?src=\ref[src];strengthup=1'>++</A><BR><BR>"

			user << browse(dat, "window=pacontrol;size=420x500")
			onclose(user, "pacontrol")
