//Warden and regular officers add this result to their get_access()
/datum/job/proc/check_config_for_sec_maint()
	if(config.jobs_have_maint_access & SECURITY_HAS_MAINT_ACCESS)
		return list(access_maint_tunnels)
	return list()

/*
Head of Shitcurity
*/
/datum/job/hos
	title = "Head of Security"
	flag = HOS
	department_head = list("Captain")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	req_admin_notify = 1
	minimal_player_age = 14

	default_id = /obj/item/weapon/card/id/silver
	default_pda = /obj/item/device/pda/heads/hos
	default_headset = /obj/item/device/radio/headset/heads/hos
	default_backpack = /obj/item/weapon/storage/backpack/security
	default_satchel = /obj/item/weapon/storage/backpack/satchel_sec

	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_weapons,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_weapons,
			            access_forensics_lockers, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway)
	assistant_access = list(access_sec_doors, access_brig,access_weapons)
	assistant_title = "HoS' Assistant"

/datum/job/hos/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_security(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/hos(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/HoS(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(H), slot_s_store)

	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_l_store)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton(H), slot_in_backpack)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1

/*
Warden
*/
/datum/job/warden
	title = "Warden"
	flag = WARDEN
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	default_pda = /obj/item/device/pda/warden
	default_headset = /obj/item/device/radio/headset/headset_sec
	default_backpack = /obj/item/weapon/storage/backpack/security
	default_satchel = /obj/item/weapon/storage/backpack/satchel_sec

	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_maint_tunnels, access_morgue)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_armory, access_court, access_weapons) //See /datum/job/warden/get_access()
	assistant_access = list(access_sec_doors, access_brig,access_weapons)
	assistant_title = "Warden's Assistant"

/datum/job/warden/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/warden(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/warden(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/warden(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/device/flash(H), slot_l_store)

	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_l_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_in_backpack)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1

/datum/job/warden/get_access()
	var/list/L = list()
	L = ..() | check_config_for_sec_maint()
	return L

/*
Detective
*/
/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	selection_color = "#ffeeee"
	minimal_player_age = 7

	default_pda = /obj/item/device/pda/detective
	default_headset = /obj/item/device/radio/headset/headset_sec

	access = list(access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court, access_weapons)
	minimal_access = list(access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels, access_court, access_weapons)
	assistant_access = list(access_sec_doors, access_morgue,access_weapons)
	assistant_title = "Private Investigator"

/datum/job/detective/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/det(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(H), slot_glasses)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/det_suit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/lighter/zippo(H), slot_l_store)
	H.equip_to_slot_or_del(new /obj/item/device/detective_scanner(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/drinks/flask/detective(H), slot_s_store)


	var/obj/item/clothing/mask/cigarette/cig = new /obj/item/clothing/mask/cigarette(H)
	cig.light("")
	H.equip_to_slot_or_del(cig, slot_wear_mask)

	if(H.backbag == 1)//Gives him his telebaton.
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton(H), slot_l_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton(H), slot_in_backpack)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1

/*
Security Officer
*/
/datum/job/officer
	title = "Security Officer"
	flag = OFFICER
	department_head = list("Head of Security")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	selection_color = "#ffeeee"
	minimal_player_age = 7
	var/list/dep_access = null

	default_pda = /obj/item/device/pda/security
	default_headset = /obj/item/device/radio/headset/headset_sec
	default_backpack = /obj/item/weapon/storage/backpack/security
	default_satchel = /obj/item/weapon/storage/backpack/satchel_sec

	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue, access_weapons)
	minimal_access = list(access_security, access_sec_doors, access_brig, access_court, access_weapons) //But see /datum/job/warden/get_access()
	assistant_access = list(access_sec_doors,access_weapons)
	assistant_title = "Security Cadet"

/datum/job/officer/equip_items(var/mob/living/carbon/human/H)
	assign_sec_to_department(H)

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet(H), slot_head)
	H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_s_store)
	H.equip_to_slot_or_del(new /obj/item/device/flash(H), slot_l_store)

	if(H.backbag == 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_r_store)
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(H), slot_l_hand)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), slot_in_backpack)
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(H), slot_in_backpack)

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
	L.imp_in = H
	L.implanted = 1

/datum/job/officer/get_access()
	var/list/L = list()
	if(dep_access)
		L |= dep_access.Copy()
	L |= ..() | check_config_for_sec_maint()
	dep_access = null;
	return L

var/list/sec_departments = list("engineering", "supply", "medical", "science")

/datum/job/officer/proc/assign_sec_to_department(var/mob/living/carbon/human/H)
	if(!sec_departments.len)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security(H), slot_w_uniform)
	else
		var/department = pick(sec_departments)
		sec_departments -= department
		var/destination = null
		switch(department)
			if("supply")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/cargo(H), slot_w_uniform)
				default_headset = /obj/item/device/radio/headset/headset_sec/department/supply
				dep_access = list(access_mailsorting, access_mining)
				destination = /area/security/checkpoint/supply
			if("engineering")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/engine(H), slot_w_uniform)
				default_headset = /obj/item/device/radio/headset/headset_sec/department/engi
				dep_access = list(access_construction, access_engine)
				destination = /area/security/checkpoint/engineering
			if("medical")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/med(H), slot_w_uniform)
				default_headset = /obj/item/device/radio/headset/headset_sec/department/med
				dep_access = list(access_medical)
				destination = /area/security/checkpoint/medical
			if("science")
				H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/science(H), slot_w_uniform)
				default_headset = /obj/item/device/radio/headset/headset_sec/department/sci
				dep_access = list(access_research)
				destination = /area/security/checkpoint/science
		var/teleport = 0
		if(!config.sec_start_brig)
			if(destination)
				if(!ticker || ticker.current_state <= GAME_STATE_SETTING_UP)
					teleport = 1
		if(teleport)
			var/turf/T
			var/safety = 0
			while(safety < 25)
				T = safepick(get_area_turfs(destination))
				if(T && !H.Move(T))
					safety += 1
					continue
				else
					break
		H << "<b>You have been assigned to [department]!</b>"
		return

/obj/item/device/radio/headset/headset_sec/department/New()
	wires = new(src)
	secure_radio_connections = new

	if(radio_controller)
		initialize()
	recalculateChannels()

/obj/item/device/radio/headset/headset_sec/department/engi
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_sec/department/supply
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/headset_sec/department/med
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sec/department/sci
	keyslot1 = new /obj/item/device/encryptionkey/headset_sec
	keyslot2 = new /obj/item/device/encryptionkey/headset_sci

/obj/item/clothing/under/rank/security/cargo/New()
	attachTie(new /obj/item/clothing/tie/armband/cargo)

/obj/item/clothing/under/rank/security/engine/New()
	attachTie(new /obj/item/clothing/tie/armband/engine)

/obj/item/clothing/under/rank/security/science/New()
	attachTie(new /obj/item/clothing/tie/armband/science)

/obj/item/clothing/under/rank/security/med/New()
	attachTie(new /obj/item/clothing/tie/armband/medblue)