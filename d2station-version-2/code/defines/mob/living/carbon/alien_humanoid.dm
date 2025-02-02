/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

	var/icon/stand_icon = null
	var/icon/lying_icon = null

	var/last_b_state = 1.0

	var/image/face_standing = null
	var/image/face_lying = null

	var/list/body_standing = list(  )
	var/list/body_lying = list(  )

/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"

	health = 150
	toxloss = 100
	max_plasma = 150
	icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"

	health = 125
	toxloss = 100
	max_plasma = 250
	icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"

	health = 100
	icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"

	health = 250
	icon_state = "queen_s"

/mob/living/carbon/alien/humanoid/rpbody
	update_icon = 0

	voice_message = "says"
	say_message = "says"


/mob/living/carbon/human/mooninite/update_clothing()
	if(istype(src, /mob/living/carbon/human/mooninite/inigknot))
		icon = 'alien.dmi'
		if(src.buckled)
			if(istype(src.buckled, /obj/stool/bed))
				src.lying = 1
			else
				src.lying = 0

		if(src.update_icon) // Skie
			..()
			for(var/i in src.overlays)
				src.overlays -= i

			if (!( src.lying ))
				src.icon_state = "Inigknot_l"
			else
				src.icon_state = "Inigknot_s"
		return
	if(istype(src, /mob/living/carbon/human/mooninite/err))
		icon = 'alien.dmi'
		if(src.buckled)
			if(istype(src.buckled, /obj/stool/bed))
				src.lying = 1
			else
				src.lying = 0

		if(src.update_icon) // Skie
			..()
			for(var/i in src.overlays)
				src.overlays -= i

			if (!( src.lying ))
				src.icon_state = "Inigknot_l"
			else
				src.icon_state = "Inigknot_s"
		return


/mob/living/carbon/human/mooninite/inigknot
	name = "Inigknot"
	real_name = "Inigknot"
	icon = 'alien.dmi'
	voice_name = "Inigknot"
	voice_message = "says"
	say_message = "says"
	health = 150
	toxloss = 100
	icon_state = "Inigknot_s"
	update_icon = 0
	alien_talk_understand = 1

/mob/living/carbon/human/mooninite/err
	name = "Err"
	real_name = "Err"
	icon = 'alien.dmi'
	voice_name = "Err"
	voice_message = null
	say_message = null
	health = 150
	toxloss = 100
	icon_state = "Err_s"
	update_icon = 0
	alien_talk_understand = 1
