/*
Research Director
*/
/datum/job/rd
	title = "Research Director"
	flag = RD
	department_head = list("Captain")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	req_admin_notify = 1
	minimal_player_age = 7

	default_id = /obj/item/weapon/card/id/silver
	default_pda = /obj/item/device/pda/heads/rd
	default_headset = /obj/item/device/radio/headset/heads/rd
	default_satchel = /obj/item/weapon/storage/backpack/satchel_tox

	access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_gateway, access_mineral_storeroom,
			            access_tech_storage, access_minisat)
	minimal_access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_gateway, access_mineral_storeroom,
			            access_tech_storage, access_minisat)
	assistant_access = list(access_tox, access_research)
	assistant_title = "RD's Assistant"

/datum/job/rd/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/research_director(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/weapon/clipboard(H), slot_l_hand)
	H.equip_to_slot_or_del(new /obj/item/device/laser_pointer(H), slot_l_store)

	if(H.backbag != 1)
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/telebaton(H), slot_in_backpack)

/*
Scientist
*/
/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"

	default_pda = /obj/item/device/pda/toxins
	default_headset = /obj/item/device/radio/headset/headset_sci
	default_satchel = /obj/item/weapon/storage/backpack/satchel_tox

	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology, access_mineral_storeroom)
	minimal_access = list(access_tox, access_tox_storage, access_research, access_xenobiology, access_mineral_storeroom)
	assistant_access = list(access_tox, access_research)
	assistant_title = "Research Apprentice"

/datum/job/scientist/equip_items(var/mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/scientist(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat/science(H), slot_wear_suit)

/*
Roboticist
*/
/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "research director"
	selection_color = "#ffeeff"

	default_pda = /obj/item/device/pda/roboticist
	default_headset = /obj/item/device/radio/headset/headset_sci
	default_satchel = /obj/item/weapon/storage/backpack/satchel_robo

	access = list(access_robotics, access_tech_storage, access_morgue, access_research, access_tox, access_mineral_storeroom)
	minimal_access = list(access_robotics, access_tech_storage, access_morgue, access_research, access_mineral_storeroom)
	assistant_access = list(access_robotics, access_research)
	assistant_title = "Robotics Apprentice"

/datum/job/roboticist/equip_items(var/mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/roboticist(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/labcoat(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/toolbox/mechanical(H), slot_l_hand)