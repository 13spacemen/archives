/*
Chief Medical Officer
*/
/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO
	department_head = list("Captain")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddf0"
	req_admin_notify = 1
	minimal_player_age = 7

	default_id = /obj/item/weapon/card/id/silver
	default_pda = /obj/item/device/pda/heads/cmo
	default_headset = /obj/item/device/radio/headset/heads/cmo
	default_backpack = /obj/item/weapon/storage/backpack/medic
	default_satchel = /obj/item/weapon/storage/backpack/satchel_med

	access = list(access_medical, access_morgue, access_genetics, access_heads, access_mineral_storeroom,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_heads, access_mineral_storeroom,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors)
	assistant_access = list(access_medical)
	assistant_title = "CMO's Assistant"

/datum/job/cmo/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_medical_officer(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat/cmo(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)

	if(H.backbag != 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton(H), slot_in_backpack)

/*
Medical Doctor
*/
/datum/job/doctor
	title = "Medical Doctor"
	flag = DOCTOR
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	default_pda = /obj/item/device/pda/medical
	default_headset = /obj/item/device/radio/headset/headset_med
	default_backpack = /obj/item/weapon/storage/backpack/medic
	default_satchel = /obj/item/weapon/storage/backpack/satchel_med

	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics)
	minimal_access = list(access_medical, access_morgue, access_surgery)
	assistant_access = list(access_medical)
	assistant_title = "Nurse"

/datum/job/doctor/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)

	if(H.backbag != 1)
		H.equip_to_slot_or_del(new /obj/item/bodybag(H), slot_in_backpack)

/*
Chemist
*/
/datum/job/chemist
	title = "Chemist"
	flag = CHEMIST
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	default_pda = /obj/item/device/pda/chemist
	default_headset = /obj/item/device/radio/headset/headset_med
	default_backpack = /obj/item/weapon/storage/backpack/medic
	default_satchel = /obj/item/weapon/storage/backpack/satchel_chem

	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)
	minimal_access = list(access_medical, access_chemistry, access_mineral_storeroom)
	assistant_access = list(access_medical)
	assistant_title = "Chemistry Apprentice"

/datum/job/chemist/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chemist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat/chemist(H), slot_wear_suit)

/*
Geneticist
*/
/datum/job/geneticist
	title = "Geneticist"
	flag = GENETICIST
	department_head = list("Chief Medical Officer", "Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the chief medical officer and research director"
	selection_color = "#ffeef0"

	default_pda = /obj/item/device/pda/geneticist
	default_headset = /obj/item/device/radio/headset/headset_medsci
	default_backpack = /obj/item/weapon/storage/backpack/medic
	default_satchel = /obj/item/weapon/storage/backpack/satchel_gen

	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_research)
	minimal_access = list(access_medical, access_morgue, access_genetics, access_research)
	assistant_access = list(access_medical)
	assistant_title = "Genetics Apprentice"

/datum/job/geneticist/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/geneticist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat/genetics(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)

/*
Virologist
*/
/datum/job/virologist
	title = "Virologist"
	flag = VIROLOGIST
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"

	default_pda = /obj/item/device/pda/viro
	default_headset = /obj/item/device/radio/headset/headset_med
	default_backpack = /obj/item/weapon/storage/backpack/medic
	default_satchel = /obj/item/weapon/storage/backpack/satchel_vir

	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)
	minimal_access = list(access_medical, access_virology, access_mineral_storeroom)
	assistant_access = list(access_medical)
	assistant_title = "Virology Apprentice"

/datum/job/virologist/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/virologist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat/virologist(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)

