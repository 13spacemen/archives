/obj/machinery/door
	name = "Door"
	icon = 'doorint.dmi'
	icon_state = "door1"
	opacity = 1
	density = 1
	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	anchored = 1
	var/autoclose = 0

/obj/machinery/door/firedoor
	name = "Firelock"
	icon = 'Doorfire.dmi'
	icon_state = "door0"
	var/blocked = null
	opacity = 0
	density = 0
	var/nextstate = null

/obj/machinery/door/firedoor/border_only
	name = "Firelock"
	icon = 'door_fire2.dmi'
	icon_state = "door0"

/obj/machinery/forcefield
	name = "Material Screening Field"
	icon = 'forcefield.dmi'
	icon_state = "canpass_field"
	anchored = 1
	var/id = 1.0
	var/list/incorrect_items = list(/obj/item/weapon/gun)

/obj/machinery/door/poddoor
	name = "Podlock"
	icon = 'rapid_pdoor.dmi'
	icon_state = "pdoor1"
	var/id = 1.0

/obj/machinery/door/poddoor/shuttles
	name = "Shuttle Podlock"
	icon = 'rapid_pdoorshuttle.dmi'
	icon_state = "pdoor1"

/obj/machinery/door/poddoor/shuttlesdark
	name = "Shuttle Podlock"
	icon = 'rapid_pdoorshuttle1.dmi'
	icon_state = "pdoor1"

/obj/machinery/door/window
	name = "interior door"
	icon = 'windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	visible = 0.0
	flags = ON_BORDER
	opacity = 0
	var/id = 1.0
	var/health = 50.0
	var/reinf = 1

/obj/machinery/door/window/brigdoor
	name = "Brig Door"
	icon = 'windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"



/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"


/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

