/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

/obj/machinery/mecha_part_fabricator
	icon = 'stationobjs.dmi'
	icon_state = "mechfab1"
	name = "Exosuit Fabricator"
	desc = "Nothing is being built."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	var/time_coeff = 2 //can be upgraded with research
	var/resource_coeff = 1.5 //can be upgraded with research
	var/list/resources = list(
										"metal"=0,
										"glass"=0,
										"gold"=0,
										"silver"=0,
										"diamond"=0,
										"plasma"=0,
										"uranium"=0,
										"bananium"=0
										)
	var/res_max_amount = 200000
	var/datum/research/files
	var/id
	var/sync = 0
	var/part_set
	var/obj/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = "main"
	var/temp
	var/list/part_sets = list( //set names must be unique
	"Ripley"=list(
						/obj/item/mecha_parts/chassis/ripley,
						/obj/item/mecha_parts/part/ripley_torso,
						/obj/item/mecha_parts/part/ripley_left_arm,
						/obj/item/mecha_parts/part/ripley_right_arm,
						/obj/item/mecha_parts/part/ripley_left_leg,
						/obj/item/mecha_parts/part/ripley_right_leg
					),
	"Gygax"=list(
						/obj/item/mecha_parts/chassis/gygax,
						/obj/item/mecha_parts/part/gygax_torso,
						/obj/item/mecha_parts/part/gygax_head,
						/obj/item/mecha_parts/part/gygax_left_arm,
						/obj/item/mecha_parts/part/gygax_right_arm,
						/obj/item/mecha_parts/part/gygax_left_leg,
						/obj/item/mecha_parts/part/gygax_right_leg,
						/obj/item/mecha_parts/part/gygax_armour
					),
	"Durand"=list(
						/obj/item/mecha_parts/chassis/durand,
						/obj/item/mecha_parts/part/durand_torso,
						/obj/item/mecha_parts/part/durand_head,
						/obj/item/mecha_parts/part/durand_left_arm,
						/obj/item/mecha_parts/part/durand_right_arm,
						/obj/item/mecha_parts/part/durand_left_leg,
						/obj/item/mecha_parts/part/durand_right_leg,
						/obj/item/mecha_parts/part/durand_armour
					),
	"H.O.N.K"=list(
						/obj/item/mecha_parts/chassis/honker,
						/obj/item/mecha_parts/part/honker_torso,
						/obj/item/mecha_parts/part/honker_head,
						/obj/item/mecha_parts/part/honker_left_arm,
						/obj/item/mecha_parts/part/honker_right_arm,
						/obj/item/mecha_parts/part/honker_left_leg,
						/obj/item/mecha_parts/part/honker_right_leg
						),
	"Exosuit Equipment"=list(
									/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
									/obj/item/mecha_parts/mecha_equipment/tool/drill,
									/obj/item/mecha_parts/mecha_equipment/tool/extinguisher,
									/obj/item/mecha_parts/mecha_equipment/tool/rcd,
									/obj/item/mecha_parts/mecha_equipment/weapon/laser,
									/obj/item/mecha_parts/mecha_equipment/weapon/taser,
									/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
									/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
									/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
									/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar,
									/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar,
									/obj/item/mecha_parts/mecha_equipment/weapon/honker),

	"Misc"=list(/obj/item/mecha_tracking)

	)

	New()
		..()
		for(var/part_set in part_sets)
			convert_part_set(part_set)
		files = new /datum/research(src) //Setup the research data holder.
		if(!id)
			for(var/obj/machinery/r_n_d/server/centcom/S in world)
				S.initialize()
				break
		return

	Del()
		for(var/atom/A in src)
			del A
		..()
		return

	proc/convert_part_set(set_name as text)
		var/list/parts = part_sets[set_name]
		if(istype(parts, /list))
			for(var/i=1;i<=parts.len;i++)
				var/path = parts[i]
				parts[i] = new path(src)
		return


	proc/add_part_set(set_name as text,parts=null)
		if(set_name in part_sets)//attempt to create duplicate set
			return 0
		if(isnull(parts))
			part_sets[set_name] = list()
		else
			part_sets[set_name] = parts
		convert_part_set(set_name)
		return 1

	proc/add_part_to_set(set_name as text,part)
		if(!part) return 0
		src.add_part_set(set_name)//if no "set_name" set exists, create
		var/list/part_set = part_sets[set_name]
		var/atom/apart
		if(ispath(part))
			apart = new part(src)
		else
			apart = part
		if(!istype(apart)) return 0
		for(var/obj/O in part_set)
			if(O.type == apart.type)
				del apart
				return 0
		part_set[++part_set.len] = apart
		return 1

	proc/remove_part_set(set_name as text)
		for(var/i=1,i<=part_sets.len,i++)
			if(part_sets[i]==set_name)
				part_sets.Cut(i,++i)
		return
/*
	proc/sanity_check()
		for(var/p in resources)
			var/index = resources.Find(p)
			index = resources.Find(p, ++index)
			if(index) //duplicate resource
				world << "Duplicate resource definition for [src](\ref[src])"
				return 0
		for(var/set_name in part_sets)
			var/index = part_sets.Find(set_name)
			index = part_sets.Find(set_name, ++index)
			if(index) //duplicate part set
				world << "Duplicate part set definition for [src](\ref[src])"
				return 0
		return 1
*/
/*
	New()
		..()
		src.add_part_to_set("Test",list("result"="/obj/item/mecha_parts/part/gygax_armour","time"=600,"metal"=75000,"diamond"=10000))
		src.add_part_to_set("Test",list("result"="/obj/item/mecha_parts/part/ripley_left_arm","time"=200,"metal"=25000))
		src.remove_part_set("Gygax")
		return
*/

	proc/output_parts_list(set_name as text)
		var/output = ""
		if(set_name in part_sets)
			var/list/part_set = part_sets[set_name]
			for(var/atom/part in part_set)
				var/resources_available = check_resources(part)
				output += "<div class='part'>[output_part_info(part)]<br>\[[resources_available?"<a href='?src=\ref[src];part=\ref[part]'>Build</a> | ":null]<a href='?src=\ref[src];add_to_queue=\ref[part]'>Add to queue</a>\]</div>"
		return output

	proc/output_part_info(var/obj/item/mecha_parts/part)
		var/output = "[part.name] (Cost: [output_part_cost(part)]) [get_construction_time_w_coeff(part,0.1)/10]sec"
		return output

	proc/output_part_cost(var/obj/item/mecha_parts/part)
		var/i = 0
		var/output
		for(var/p in part.construction_cost)
			if(p in resources)
				output += "[i?" | ":null][get_resource_cost_w_coeff(part,p,1)] [p]"
				i++
		return output

	proc/output_available_resources()
		var/output
		for(var/resource in resources)
			output += "<span class=\"res_name\">[resource]: </span>[min(res_max_amount, resources[resource])] cm&sup3;<br>"
		return output

	proc/remove_resources(var/obj/item/mecha_parts/part as obj)
		for(var/resource in part.construction_cost)
			if(resource in src.resources)
				src.resources[resource] -= get_resource_cost_w_coeff(part,resource,1)
		return

	proc/check_resources(var/obj/item/mecha_parts/part as obj)
		for(var/resource in part.construction_cost)
			if(resource in src.resources)
				if(src.resources[resource] < get_resource_cost_w_coeff(part,resource,1))
					return 0
		return 1

	proc/build_part(var/obj/item/mecha_parts/part as obj)
		if(!part) return
		src.being_built = new part.type(src)
		src.desc = "It's building [src.being_built]."
		src.remove_resources(part)
		src.icon_state = "mechfab3" //looks better than 'flick'
		src.use_power = 2
		src.updateUsrDialog()
		sleep(round(part.construction_time*time_coeff,0.1))
		if(!src) return
		src.use_power = 1
		src.being_built.Move(get_step(src,EAST))
		src.icon_state = initial(src.icon_state)
		src.visible_message("<b>[src]</b> beeps, \"The [src.being_built] is complete\".")
		src.icon_state = initial(src.icon_state)
		src.being_built = null
		src.desc = initial(src.desc)
		src.updateUsrDialog()
		return 1

	proc/add_part_set_to_queue(set_name as text)
		if(set_name in part_sets)
			var/list/part_set = part_sets[set_name]
			for(var/part in part_set)
				add_to_queue(part)
		return

	proc/add_to_queue(part as obj)
		if(!istype(queue, /list))
			queue = list()
		queue[++queue.len] = part
		return queue.len

	proc/remove_from_queue(index as num)
		if(!istype(queue, /list) || !queue[index])
			return 0
		queue.Cut(index,++index)
		return 1

	proc/process_queue()
		while(istype(queue, /list) && queue.len)
			if(stat&(NOPOWER|BROKEN))
				return 0
			var/part = queue[1]
			if(!check_resources(part))
				src.visible_message("<b>[src]</b> beeps, \"Not enough resources. Queue processing stopped\".")
				temp = {"<font color='red'>Not enough resources to build next part.</font><br>
							<a href='?src=\ref[src];process_queue=1'>Try again</a> | <a href='?src=\ref[src];clear_temp=1'>Return</a><a>"}
				return 0
			remove_from_queue(1)
			build_part(part)
		src.visible_message("<b>[src]</b> beeps, \"Queue processing finished successfully\".")
		return 1

	proc/list_queue()
		var/output = "<b>Queue contains:</b>"
		if(!istype(queue, /list) || !queue.len)
			output += "<br>Nothing"
		else
			output += "<ol>"
			for(var/i=1;i<=queue.len;i++)
				var/atom/part = queue[i]
				output += "<li[!check_resources(part)?" style='color: #f00;'":null]>[part.name] - [i>1?"<a href='?src=\ref[src];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=\ref[src];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=\ref[src];remove_from_queue=[i]'>Remove</a></li>"
			output += "</ol>"
			output += "\[<a href='?src=\ref[src];process_queue=1'>Process queue</a> | <a href='?src=\ref[src];clear_queue=1'>Clear queue</a>\]"
		return output

	proc/convert_designs()
		if(!files) return
		var/i = 0
		for(var/datum/design/D in files.known_designs)
			if(D.build_type&16)
				if(add_part_to_set("Exosuit Equipment", text2path(D.build_path)))
					i++
		return i

	proc/update_tech()
		if(!files) return
		var/output
		for(var/datum/tech/T in files.known_tech)
			if(T && T.level > 1)
				var/diff
				switch(T.id) //bad, bad formulas
					if("materials")
						diff = round(initial(resource_coeff) - (initial(resource_coeff)*T.level)/25,0.01)
						if(resource_coeff!=diff)
							resource_coeff = round(initial(resource_coeff) - (initial(resource_coeff)*T.level)/25,0.01)
							output+="Production efficiency increased.<br>"
					if("programming")
						diff = round(initial(time_coeff) - (initial(time_coeff)*T.level)/25,0.01)
						if(time_coeff!=diff)
							time_coeff = round(initial(time_coeff) - (initial(time_coeff)*T.level)/25,0.1)
							output+="Production routines updated.<br>"
		return output


	proc/sync(silent=null)
		if(!silent)
			temp = "Updating local R&D database..."
		spawn(30)
			if(!src) return
			for(var/obj/machinery/computer/rdconsole/RDC in get_area(src))
				if(!RDC.sync)
					continue
				for(var/datum/tech/T in RDC.files.known_tech)
					files.AddTech2Known(T)
				for(var/datum/design/D in RDC.files.known_designs)
					files.AddDesign2Known(D)
				files.RefreshResearch()
				var/i = src.convert_designs()
				var/tech_output = update_tech()
				if(!silent)
					temp = "Processed [i] equipment designs.<br>"
					temp += tech_output
					temp += "<a href='?src=\ref[src];clear_temp=1'>Return</a>"
					src.updateUsrDialog()
		return

	proc/get_resource_cost_w_coeff(var/obj/item/mecha_parts/part as obj,var/resource as text, var/roundto=null)
		roundto = roundto || 0.01
		return round(part.construction_cost[resource]*resource_coeff, roundto)

	proc/get_construction_time_w_coeff(var/obj/item/mecha_parts/part as obj, var/roundto=null)
		roundto = roundto || 0.01
		return round(part.construction_time*time_coeff, roundto)

	attack_hand(mob/user as mob)
		var/dat, left_part
		if (..())
			return
		user.machine = src
		if(temp)
			left_part = temp
		else if(src.being_built)
			left_part = {"<TT>Building [src.being_built.name].<BR>
								Please wait until completion...</TT>"}
		else
			switch(screen)
				if("main")
					left_part = output_available_resources()+"<hr>"
					left_part += "<a href='?src=\ref[src];sync=1'>Sync with R&D servers</a> | <a href='?src=\ref[src];auto_sync=1'>[sync?"Dis":"En"]able auto sync</a><hr>"
					for(var/part_set in part_sets)
						left_part += "<a href='?src=\ref[src];part_set=[part_set]'>[part_set]</a> - \[<a href='?src=\ref[src];partset_to_queue=[part_set]'>Add all parts to queue\]<br>"
				if("parts")
					left_part += output_parts_list(part_set)
					left_part += "<hr><a href='?src=\ref[src];screen=main'>Return</a>"
		dat = {"<html>
				  <head>
				  <title>[src.name]</title>
					<style>
					.res_name {font-weight: bold; text-transform: capitalize;}
					.red {color: #f00;}
					.part {margin-bottom: 10px;}
					.arrow {text-decoration: none; font-size: 10px;}
					body, table {height: 100%;}
					td {vertical-align: top; padding: 5px;}
					html, body {padding: 0px; margin: 0px;}
					</style>
					</head><body>
					<body>
					<table style='width: 100%;'>
					<tr>
					<td style='width: 70%; padding-right: 10px;'>
					[left_part]
					</td>
					<td style='width: 30%; background: #ccc;'>
					[list_queue()]
					</td>
					<tr>
					</table>
					</body>
					</html>"}
		user << browse(dat, "window=mecha_fabricator;size=1000x400")
		onclose(user, "mecha_fabricator")
		return


	Topic(href, href_list)
		..()
		if(href_list["part_set"])
			if(href_list["part_set"]=="clear")
				src.part_set = null
			else
				src.part_set = href_list["part_set"]
				screen = "parts"
		if(href_list["part"])
			var/list/part = locate(href_list["part"])
			if(!processing_queue)
				build_part(part)
			else
				add_to_queue(part)
		if(href_list["add_to_queue"])
			var/part = locate(href_list["add_to_queue"])
			add_to_queue(part)
		if(href_list["remove_from_queue"])
			var/index = text2num(href_list["remove_from_queue"])
			if(isnum(index))
				remove_from_queue(index)
		if(href_list["partset_to_queue"])
			var/part_set = href_list["partset_to_queue"]
			add_part_set_to_queue(part_set)
		if(href_list["process_queue"])
			temp = null
			processing_queue = 1
			process_queue()
			processing_queue = 0
		if(href_list["list_queue"])
			list_queue()
		if(href_list["clear_temp"])
			temp = null
		if(href_list["screen"])
			src.screen = href_list["screen"]
		if(href_list["queue_move"] && href_list["index"])
			var/index = text2num(href_list["index"])
			var/new_index = index + text2num(href_list["queue_move"])
			if(isnum(index) && isnum(new_index))
				if(new_index>0&&new_index<=queue.len)
					queue.Swap(index,new_index)
		if(href_list["clear_queue"])
			queue = list()
		if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
			src.sync()
		if(href_list["auto_sync"])
			src.sync = !src.sync
			//pr_auto_sync.toggle()
		src.updateUsrDialog()
		return

	process()
		if (stat & (NOPOWER|BROKEN))
			return
		if(sync)
			src.sync(1)
		return

	attackby(obj/item/stack/sheet/W as obj, mob/user as mob)
		var/material
		if(istype(W, /obj/item/stack/sheet/gold))
			material = "gold"
		else if(istype(W, /obj/item/stack/sheet/silver))
			material = "silver"
		else if(istype(W, /obj/item/stack/sheet/diamond))
			material = "diamond"
		else if(istype(W, /obj/item/stack/sheet/plasma))
			material = "plasma"
		else if(istype(W, /obj/item/stack/sheet/metal))
			material = "metal"
		else if(istype(W, /obj/item/stack/sheet/glass))
			material = "glass"
		else if(istype(W, /obj/item/stack/sheet/clown))
			material = "bananium"
		else if(istype(W, /obj/item/stack/sheet/uranium))
			material = "uranium"
		else
			return ..()

		if(src.being_built)
			user << "The fabricator is currently processing. Please wait until completion."
			return

		var/name = "[W.name]"
		var/amnt = W.perunit
		if(src.resources[material] < res_max_amount)
			var/count = 0
			spawn(10)
				if(W && W.amount)
					while(src.resources[material] < res_max_amount && W)
						src.resources[material] += amnt
						W.use(1)
						count++
					flick("mechfab2", src)
					user << "You insert [count] [name] into the fabricator."
					src.updateUsrDialog()
		else
			user << "The fabricator cannot hold more [name]."
		return

