/obj/machinery/vending
	var/const
		WIRE_EXTEND = 1
		WIRE_SCANID = 2
		WIRE_SHOCK = 3
		WIRE_SHOOTINV = 4

/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/product_price = 0
	var/amount = 0
	var/display_color = "blue"

/obj/machinery/vending/New()
	..()
	spawn(4)
		src.inflation = src.getInflation()
		src.slogan_list = dd_text2List(src.product_slogans, ";")
		var/list/temp_paths = dd_text2List(src.product_paths, ";")
		var/list/temp_amounts = dd_text2List(src.product_amounts, ";")
		var/list/temp_hidden = dd_text2List(src.product_hidden, ";")
		var/list/temp_hideamt = dd_text2List(src.product_hideamt, ";")
		var/list/temp_prices = dd_text2List(src.product_prices, ";")
		//Little sanity check here
		if ((isnull(temp_paths)) || (isnull(temp_amounts)) || (isnull(temp_prices)) || (temp_paths.len != temp_amounts.len) || (temp_prices.len != temp_amounts.len) || (temp_hidden.len != temp_hideamt.len))
			stat |= BROKEN
			world.log <<  "HEY DEVS YOU FUCKED UP THE [src.name] VENDING MACHINES! THIS IS WHY THEY SPAWN BROKEN! YOU NEED TO SET THE EQUAL AMOUNT OF PATHS, AMOUNTS AND PRICES OR IT WILL BREAK"
			power_change()
			return

		src.build_inventory(temp_paths,temp_prices,temp_amounts)
		 //Add hidden inventory
		src.build_inventory(temp_hidden,temp_prices,temp_hideamt, 1)
		power_change()
		return

	return

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				spawn(0)
					src.malfunction()
					return
				return
		else
	return

/obj/machinery/vending/blob_act()
	if (prob(50))
		spawn(0)
			src.malfunction()
			del(src)
		return

	return

/obj/machinery/vending/proc/build_inventory(var/list/path_list,var/list/price_list,var/list/amt_list,hidden=0)

	for(var/p=1, p <= path_list.len ,p++)
		var/checkpath = text2path(path_list[p])
		if (!checkpath)
			continue
		var/obj/temp = new checkpath(src)

		var/datum/data/vending_product/R = new /datum/data/vending_product(  )
		R.product_name = capitalize(temp.name)
		R.product_path = path_list[p]
		if(!hidden)
			if(text2num(price_list[p]) != 0)
				R.product_price = text2num(price_list[p]) + text2num(src.inflation)
			else
				R.product_price = text2num(price_list[p])
		R.display_color = "green"
//		R.amount = text2num(amt_list[p])
//		src.product_records += R

		if(hidden)
			R.amount = text2num(amt_list[p])
			src.hidden_records += R
		else
			R.amount = text2num(amt_list[p])
			src.product_records += R

		del(temp)

		//world << "Added: [R.product_name] - [R.amount] - [R.product_path] - [R.product_price]"
		continue

	return

/obj/machinery/vending/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/emag))
		src.emagged = 1
		user << "You short out the product lock on [src]"
		return
	else if(istype(W, /obj/item/weapon/screwdriver))
		src.panel_open = !src.panel_open
		user << "You [src.panel_open ? "open" : "close"] the maintenance panel."
		src.overlays = null
		if(src.panel_open)
			src.overlays += image(src.icon, "[initial(icon_state)]-panel")
		src.updateUsrDialog()
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(src.panel_open)
			attack_hand(user)
		return
	else
		..()


/obj/machinery/vending/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return
	user.machine = src

	if(src.seconds_electrified != 0)
		if(src.shock(user, 100))
			return

	if(panel_open)
		var/list/vendwires = list(
			"Violet" = 1,
			"Orange" = 2,
			"Goldenrod" = 3,
			"Green" = 4,
		)
		var/pdat = "<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' /><B>Access Panel</B><br>"
		for(var/wiredesc in vendwires)
			var/is_uncut = src.wires & APCWireColorToFlag[vendwires[wiredesc]]
			pdat += "[wiredesc] wire: "
			if(!is_uncut)
				pdat += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Mend</a>"
			else
				pdat += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Cut</a> "
				pdat += "<a href='?src=\ref[src];pulsewire=[vendwires[wiredesc]]'>Pulse</a> "
			pdat += "<br>"

		pdat += "<br>"
		pdat += "The orange light is [(src.seconds_electrified == 0) ? "off" : "on"].<BR>"
		pdat += "The red light is [src.shoot_inventory ? "off" : "blinking"].<BR>"
		pdat += "The green light is [src.extended_inventory ? "on" : "off"].<BR>"
		pdat += "The [(src.wires & WIRE_SCANID) ? "purple" : "yellow"] light is on.<BR>"

		user << browse(pdat, "window=vendwires")
		onclose(user, "vendwires")

	var/dat = "<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' /><body style='margin: 0; padding: 0;'>"

	if (src.product_records.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		var/list/display_records = src.product_records
		if(src.extended_inventory)
			display_records = (src.product_records + src.hidden_records)

		for (var/datum/data/vending_product/R in display_records)
			dat += "<div style='border-bottom:1px solid #000;padding: 4px;'>"
			if (R.amount > 0)
				if (R.product_price != 0)
					dat += "<a href='byond://?src=\ref[src];vend=\ref[R]'><img src='http://somethingdickful.com/ficons/cart_go.png' style='margin: -3px 0;'></A> (�[R.product_price])"
				else
					dat += "<a href='byond://?src=\ref[src];vend=\ref[R]'><img src='http://somethingdickful.com/ficons/bullet_go.png' style='margin: -3px 0;'></A> (free)"
			else
				dat += "<img src='http://somethingdickful.com/ficons/cart_delete.png' style='margin: -3px 0;'> (<font color='red'>SOLD OUT</font>)"
			dat += " - <FONT color = '[R.display_color]'><B>[R.product_name]</B>: [R.amount] </font>"
			dat += "</div>"

		dat += "</body>"

	user << browse(dat, "window=vending")
	onclose(user, "vending")
	return

/obj/machinery/vending/Topic(href, href_list)
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src

	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.stat || usr.restrained())
		return

	/*if(istype(usr,/mob/living/silicon))
		usr << "\red The vending machine refuses to interface with you, as you are not in its target demographic!"
		return*/

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if ((href_list["vend"]) && (src.vend_ready))

			if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID)) //For SECURE VENDING MACHINES YEAH
				usr << "\red Access denied." //Unless emagged of course
				flick(src.icon_deny,src)
				return

			var/obj/item/I = usr.equipped()
			var/datum/data/vending_product/R = locate(href_list["vend"])
			if (R.product_price != 0)
				if(I)
					if (istype(I, /obj/item/weapon/card/id))
						var/pincode = input("Enter your PIN:", "PIN", null) as num
						if(pincode != getPin(I:originalckey))
							usr << "\blue <span class='game say'><span class='name'>[src]</span> beeps, \"PIN incorrect.\""
							return
						if(src.doTransaction(I:originalckey,"-[R.product_price]","Vending Machine: [src.name] (Item: [R.product_name])") == 1)
							usr << "\blue You swipe your ID card, the machine takes �[R.product_price]!"
							attack_hand(usr)
						else
							usr << "\blue <span class='game say'><span class='name'>[src]</span> beeps, \"You don't have enough money on your card or your bank account is inexistent.\""
							attack_hand(usr)
							return
					else if(istype(I, /obj/item/weapon/money))
						if (text2num(I:value) >= R.product_price)
							I:value -= text2num(R.product_price)
							I.name = "�[I:value]"
							if (text2num(I:value) <= 0)
								del(I)
							usr << "\blue You insert [I:currency][R.product_price] into the vending machine!"
							attack_hand(usr)
						else
							usr << "\blue <span class='game say'><span class='name'>[src]</span> beeps, \"You don't have enough money.\""
							attack_hand(usr)
							return
					else
						return
				else
					usr << "\blue <span class='game say'><span class='name'>[src]</span> beeps, \"You have not inserted any money.\""
					usr << "\blue Click the purchase icon with your ID or the right amount of money in your hand."
					return

			src.vend_ready = 0 //One thing at a time!!

			if (!R || !istype(R))
				src.vend_ready = 1
				return
			var/product_path = text2path(R.product_path)
			if (!product_path)
				src.vend_ready = 1
				return

			if (R.amount <= 0)
				src.vend_ready = 1
				return

			R.amount--

			if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
				spawn(0)
					src.speak(src.vend_reply)
					src.last_reply = world.time

			use_power(5)
			if (src.icon_vend) //Show the vending animation if needed
				flick(src.icon_vend,src)
			spawn(src.vend_delay)
				new product_path(get_turf(src))
				src.vend_ready = 1
				playsound(src.loc, 'vend.ogg', 60, 0)
				return

			src.updateUsrDialog()
			return

		else if ((href_list["cutwire"]) && (src.panel_open))
			var/twire = text2num(href_list["cutwire"])
			if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(twire))
				src.mend(twire)
			else
				src.cut(twire)

		else if ((href_list["pulsewire"]) && (src.panel_open))
			var/twire = text2num(href_list["pulsewire"])
			if (!istype(usr.equipped(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(twire))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(twire)

		src.add_fingerprint(usr)
		src.updateUsrDialog()
	else
		usr << browse(null, "window=vending")
		return
	return

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!src.active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(prob(5) && ((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if((prob(2)) && (src.shoot_inventory))
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if(stat & NOPOWER)
		return

	if (!message)
		return

	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = text2path(R.product_path)
		if (!dump_path)
			continue

		while(R.amount>0)
			new dump_path(src.loc)
			R.amount--
		break

	stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = text2path(R.product_path)
		if (!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(src.loc)
		break

	spawn(0)
		throw_item.throw_at(target, 16, 3)
	src.visible_message("\red <b>[src] launches [throw_item.name] at [target.name]!</b>")
	return 1

/obj/machinery/vending/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = 0
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1


/obj/machinery/vending/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
//		if(WIRE_SCANID)
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0

/obj/machinery/vending/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = !src.extended_inventory
//		if (WIRE_SCANID)
		if (WIRE_SHOCK)
			src.seconds_electrified = 30
		if (WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory


/obj/machinery/vending/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0

	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0
