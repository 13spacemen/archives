//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials. All material amounts are set as the define MINERAL_MATERIAL_AMOUNT, which defaults to 2000
- $metal (/obj/item/stack/metal).
- $glass (/obj/item/stack/glass).
- $plasma (/obj/item/stack/plasma).
- $silver (/obj/item/stack/silver).
- $gold (/obj/item/stack/gold).
- $uranium (/obj/item/stack/uranium).
- $diamond (/obj/item/stack/diamond).
- $clown (/obj/item/stack/clown).
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- The reliability formula for all R&D built items is reliability (a fixed number) + total tech levels required to make it +
reliability_mod (starts at 0, gets improved through experimentation). Example: PACMAN generator. 79 base reliablity + 6 tech
(3 plasmatech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to


*/
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
#define MECHFAB		16 //Remember, objects utilising this flag should have construction_time and construction_cost vars.
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

datum/design						//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.			//Reliability modifier of the device at it's starting point.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/build_path = ""					//The file path of the object that gets created
	var/locked = 0						//If true it will spawn inside a lockbox with currently sec access
	var/category = null //Primarily used for Mech Fabricators, but can be used for anything


//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
datum/design/proc/CalcReliability(var/list/temp_techs)
	var/new_reliability
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = Clamp(new_reliability, reliability, 100)
	reliability = new_reliability
	return


///////////////////Computer Boards///////////////////////////////////

datum/design/seccamera
	name = "Computer Design (Security)"
	desc = "Allows for the construction of circuit boards used to build security camera computers."
	id = "seccamera"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/security

datum/design/aicore
	name = "AI Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore

datum/design/aiupload
	name = "Computer Design (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload

datum/design/borgupload
	name = "Computer Design (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload

datum/design/med_data
	name = "Computer Design (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data

datum/design/operating
	name = "Computer Design (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating

datum/design/pandemic
	name = "Computer Design (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pandemic

datum/design/scan_console
	name = "Computer Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

datum/design/comconsole
	name = "Computer Design (Communications)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications

datum/design/idcardconsole
	name = "Computer Design (ID Console)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card

datum/design/crewconsole
	name = "Computer Design (Crew monitoring computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew

datum/design/teleconsole
	name = "Computer Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter

datum/design/secdata
	name = "Computer Design (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data

datum/design/atmosalerts
	name = "Computer Design (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console.."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert

datum/design/air_management
	name = "Computer Design (Atmospheric Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management

datum/design/robocontrol
	name = "Computer Design (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics

datum/design/clonecontrol
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning

datum/design/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod

datum/design/clonescanner
	name = "Machine Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner

datum/design/arcadebattle
	name = "Computer Design (Battle Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new arcade machine."
	id = "arcademachine"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/battle

datum/design/orion_trail
	name = "Computer Design (Orion Trail Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new Orion Trail machine."
	id = "arcademachine"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade/orion_trail

datum/design/powermonitor
	name = "Computer Design (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor"
	id = "powermonitor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor

datum/design/solarcontrol
	name = "Computer Design (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console"
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control

datum/design/prisonmanage
	name = "Computer Design (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner

datum/design/mechacontrol
	name = "Computer Design (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control

datum/design/mechapower
	name = "Computer Design (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console

datum/design/rdconsole
	name = "Computer Design (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole

datum/design/ordercomp
	name = "Computer Design (Supply ordering console)"
	desc = "Allows for the construction of circuit boards used to build a Supply ordering console."
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ordercomp

datum/design/supplycomp
	name = "Computer Design (Supply shuttle console)"
	desc = "Allows for the construction of circuit boards used to build a Supply shuttle console."
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/supplycomp

datum/design/mining
	name = "Computer Design (Outpost Status Display)"
	desc = "Allows for the construction of circuit boards used to build an outpost status display console."
	id = "mining"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining

datum/design/comm_monitor
	name = "Computer Design (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor

datum/design/comm_server
	name = "Computer Design (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server

datum/design/message_monitor
	name = "Computer Design (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/message_monitor

datum/design/comm_traffic
	name = "Computer Design (Telecommunications Traffic Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications traffic control console."
	id = "comm_traffic"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_traffic

datum/design/telesci_console
	name = "Computer Design (Telepad Control Console Board)"
	desc = "Allows for the construction of circuit boards used to build a telescience console."
	id = "telesci_console"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_console

datum/design/aifixer
	name = "Computer Design (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aifixer

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
datum/design/safeguard_module
	name = "Module Design (Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	req_tech = list("programming" = 3, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/safeguard

datum/design/onehuman_module
	name = "Module Design (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/zeroth/oneHuman

datum/design/protectstation_module
	name = "Module Design (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/protectStation

/*datum/design/notele_module
	name = "Module Design (TeleporterOffline Module)"
	desc = "Allows for the construction of a TeleporterOffline AI Module."
	id = "notele_module"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/teleporterOffline"*/

datum/design/quarantine_module
	name = "Module Design (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/quarantine

datum/design/oxygen_module
	name = "Module Design (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/oxygen

datum/design/freeform_module
	name = "Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/supplied/freeform

datum/design/reset_module
	name = "Module Design (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$gold" = 100)
	build_path = /obj/item/weapon/aiModule/reset

datum/design/purge_module
	name = "Module Design (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/reset/purge

datum/design/freeformcore_module
	name = "Core Module Design (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/freeformcore

datum/design/asimov
	name = "Core Module Design (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/asimov

datum/design/paladin_module
	name = "Core Module Design (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/paladin

datum/design/tyrant_module
	name = "Core Module Design (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 4, "syndicate" = 2, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/tyrant

datum/design/corporate_module
	name = "Core Module Design (Corporate)"
	desc = "Allows for the construction of a Corporate AI Core Module."
	id = "corporate_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/corp

datum/design/custom_module
	name = "Core Module Design (Custom)"
	desc = "Allows for the construction of a Custom AI Core Module."
	id = "custom_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20, "$diamond" = 100)
	build_path = /obj/item/weapon/aiModule/core/full/custom


///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////
datum/design/subspace_receiver
	name = "Machine Design (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/receiver

datum/design/telecomms_bus
	name = "Machine Design (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/bus

datum/design/telecomms_hub
	name = "Machine Design (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/hub

datum/design/telecomms_relay
	name = "Machine Design (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/relay

datum/design/telecomms_processor
	name = "Machine Design (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/processor

datum/design/telecomms_server
	name = "Machine Design (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/server

datum/design/subspace_broadcaster
	name = "Machine Design (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/broadcaster

///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$glass" = 1000, "$gold" = 200)
	build_path = /obj/item/device/aicard

datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card"
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 500, "$metal" = 500)
	build_path = /obj/item/device/paicard

///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

datum/design/ripley_main
	name = "Exosuit Design (APLU \"Ripley\" Central Control module)"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/main

datum/design/ripley_peri
	name = "Exosuit Design (APLU \"Ripley\" Peripherals Control module)"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/peripherals

datum/design/odysseus_main
	name = "Exosuit Design (\"Odysseus\" Central Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	req_tech = list("programming" = 3,"biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/main

datum/design/odysseus_peri
	name = "Exosuit Design (\"Odysseus\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	req_tech = list("programming" = 3,"biotech" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/peripherals

datum/design/gygax_main
	name = "Exosuit Design (\"Gygax\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/main

datum/design/gygax_peri
	name = "Exosuit Design (\"Gygax\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/peripherals

datum/design/gygax_targ
	name = "Exosuit Design (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	req_tech = list("programming" = 4, "combat" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/targeting

datum/design/durand_main
	name = "Exosuit Design (\"Durand\" Central Control module)"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/main

datum/design/durand_peri
	name = "Exosuit Design (\"Durand\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/peripherals

datum/design/durand_targ
	name = "Exosuit Design (\"Durand\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	req_tech = list("programming" = 4, "combat" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/targeting

datum/design/honker_main
	name = "Exosuit Design (\"H.O.N.K\" Central Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Central Control module."
	id = "honker_main"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/honker/main

datum/design/honker_peri
	name = "Exosuit Design (\"H.O.N.K\" Peripherals Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Peripheral Control module."
	id = "honker_peri"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/honker/peripherals

datum/design/honker_targ
	name = "Exosuit Design (\"H.O.N.K\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Weapons & Targeting Control module."
	id = "honker_targ"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/honker/targeting

////////////////////////////////////////
/////////// Mecha Equpment /////////////
////////////////////////////////////////

datum/design/mech_scattershot
	name = "Exosuit Weapon Design (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	category = "Exosuit Equipment"

datum/design/mech_carbine
	name = "Exosuit Weapon Design (FNX-99 \"Hades\" Carbine)"
	desc = "Allows for the construction of FNX-99 \"Hades\" Carbine."
	id = "mech_carbine"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "materials" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	category = "Exosuit Equipment"

datum/design/mech_ion
	name = "Exosuit Weapon Design (MKIV Ion Heavy Cannon)"
	desc = "Allows for the construction of MKIV Ion Heavy Cannon."
	id = "mech_ion"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	category = "Exosuit Equipment"

datum/design/mech_laser
	name = "Exosuit Weapon Design (CH-PS \"Immolator\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "magnets" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	category = "Exosuit Equipment"

datum/design/mech_laser_heavy
	name = "Exosuit Weapon Design (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "magnets" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	category = "Exosuit Equipment"

datum/design/mech_grenade_launcher
	name = "Exosuit Weapon Design (SGL-6 Grenade Launcher)"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	category = "Exosuit Equipment"

datum/design/mech_missile_rack
	name = "Exosuit Weapon Design (SRM-8 Missile Rack)"
	desc = "Allows for the construction of SRM-8 Missile Rack."
	id = "mech_missile_rack"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "materials" = 6)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	category = "Exosuit Equipment"

datum/design/clusterbang_launcher
	name = "Exosuit Module Design (SOB-3 Clusterbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 3 rounds per minute"
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list("combat"= 5, "materials" = 5, "syndicate" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	category = "Exosuit Equipment"

datum/design/mech_wormhole_gen
	name = "Exosuit Module Design (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list("bluespace" = 3, "magnets" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	category = "Exosuit Equipment"

datum/design/mech_teleporter
	name = "Exosuit Module Design (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list("bluespace" = 10, "magnets" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	category = "Exosuit Equipment"

datum/design/mech_rcd
	name = "Exosuit Module Design (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "bluespace" = 3, "magnets" = 4, "powerstorage"=4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/rcd
	category = "Exosuit Equipment"

datum/design/mech_gravcatapult
	name = "Exosuit Module Design (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list("bluespace" = 2, "magnets" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	category = "Exosuit Equipment"

datum/design/mech_repair_droid
	name = "Exosuit Module Design (Repair Droid Module)"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	category = "Exosuit Equipment"

datum/design/mech_energy_relay
	name = "Exosuit Module Design (Tesla Energy Relay)"
	desc = "Tesla Energy Relay"
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list("magnets" = 4, "powerstorage" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	category = "Exosuit Equipment"

datum/design/mech_ccw_armor
	name = "Exosuit Module Design (Reactive Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	category = "Exosuit Equipment"

datum/design/mech_proj_armor
	name = "Exosuit Module Design (Reflective Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 5, "engineering"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	category = "Exosuit Equipment"

datum/design/mech_syringe_gun
	name = "Exosuit Module Design (Syringe Gun)"
	desc = "Exosuit-mounted syringe gun and chemical synthesizer."
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list("materials" = 3, "biotech"=4, "magnets"=4, "programming"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/syringe_gun
	category = "Exosuit Equipment"

datum/design/mech_diamond_drill
	name = "Exosuit Module Design (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill"
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 4, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
	category = "Exosuit Equipment"

datum/design/mech_generator_nuclear
	name = "Exosuit Module Design (ExoNuclear Reactor)"
	desc = "Compact nuclear reactor module"
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 3, "engineering" = 3, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	category = "Exosuit Equipment"

datum/design/mech_plasma_cutter
	name = "Exosuit Module Design (217-D Heavy Plasma Cutter)"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demloishing solid obstacles."
	id = "mech_plasma_cutter"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 3, "engineering" = 3, "materials" = 3, "combat" = 1, "plasma" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	category = "Exosuit Equipment"

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/design_disk

datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30, "$glass" = 10)
	build_path = /obj/item/weapon/disk/tech_disk

////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	id = "rped"
	req_tech = list("engineering" = 3,
					"materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 15000, "$glass" = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer

datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor

datum/design/basic_scanning
	name = "Basic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "basic_scanning"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 50, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module

datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	req_tech = list("materials" = 1, "programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator

datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 10, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser

datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin

datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv

datum/design/adv_scanning
	name = "Advanced Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "adv_scanning"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv

datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano

datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high

datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv

datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	build_type = PROTOLATHE
	reliability = 71
	materials = list("$metal" = 50, "$glass" = 50, "$gold" = 20)
	build_path = /obj/item/weapon/stock_parts/capacitor/super

datum/design/phasic_scanning
	name = "Phasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "phasic_scanning"
	req_tech = list("magnets" = 5, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 20, "$silver" = 10)
	reliability = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic

datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30)
	reliability = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/pico

datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$glass" = 20, "$uranium" = 10)
	reliability = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra

datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	req_tech = list("materials" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 80)
	reliability = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/super

datum/design/telesci_gps
	name = "GPS Device"
	desc = "Little thingie that can track its position at all times."
	id = "telesci_gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 500, "$glass" = 1000)
	build_path = /obj/item/device/gps

datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	id = "s-ansible"
	req_tech = list("programming" = 2, "magnets" = 2, "materials" = 2, "bluespace" = 1)
	build_type = PROTOLATHE
	materials = list("$metal" = 80, "$silver" = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/ansible

datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	id = "s-filter"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 40, "$silver" = 10)
	build_path = /obj/item/weapon/stock_parts/subspace/filter

datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	id = "s-amplifier"
	req_tech = list("programming" = 2, "magnets" = 2, "materials" = 2, "bluespace" = 1)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$gold" = 30, "$uranium" = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/amplifier

datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	id = "s-treatment"
	req_tech = list("programming" = 2, "magnets" = 1, "materials" = 2, "bluespace" = 1)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$silver" = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/treatment

datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "materials" = 2, "bluespace" = 1)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$gold" = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/analyzer

datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-crystal"
	req_tech = list("magnets" = 2, "materials" = 2, "bluespace" = 1)
	build_type = PROTOLATHE
	materials = list("$glass" = 1000, "$silver" = 20, "$gold" = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/crystal

datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	id = "s-transmitter"
	req_tech = list("magnets" = 3, "materials" = 3, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$glass" = 100, "$silver" = 10, "$uranium" = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/transmitter

////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1000 units of energy"
	id = "basic_cell"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE |MECHFAB
	materials = list("$metal" = 700, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/cell
	category = "Misc"

datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10000 units of energy"
	id = "high_cell"
	req_tech = list("powerstorage" = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list("$metal" = 700, "$glass" = 60)
	build_path = /obj/item/weapon/stock_parts/cell/high
	category = "Misc"

datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20000 units of energy"
	id = "super_cell"
	req_tech = list("powerstorage" = 3, "materials" = 2)
	reliability = 75
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 700, "$glass" = 70)
	build_path = /obj/item/weapon/stock_parts/cell/super
	category = "Misc"

datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30000 units of energy"
	id = "hyper_cell"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	reliability = 70
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 400, "$gold" = 150, "$silver" = 150, "$glass" = 70)
	build_path = /obj/item/weapon/stock_parts/cell/hyper
	category = "Misc"

datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$silver" = 150, "$glass" = 3000)
	build_path = /obj/item/device/lightreplacer

////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

datum/design/smes
	name = "Machine Design (SMES Board)"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "power" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes

datum/design/turbine_computer
	name = "Computer Design (Power Turbine Console Board)"
	desc = "The circuit board for a power turbine console."
	id = "power_turbine_console"
	req_tech = list("programming" = 4, "power" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/turbine_computer

datum/design/power_compressor
	name = "Machine Design (Power Compressor Board)"
	desc = "The circuit board for a power compressor."
	id = "power_compressor"
	req_tech = list("programming" = 4, "power" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_compressor

datum/design/power_turbine
	name = "Machine Design (Power Turbine Board)"
	desc = "The circuit board for a power turbine."
	id = "power_turbine"
	req_tech = list("programming" = 4, "power" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/power_turbine

datum/design/teleport_station
	name = "Machine Design (Teleportation Station Board)"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	req_tech = list("programming" = 4, "bluespace" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station

datum/design/teleport_hub
	name = "Machine Design (Teleportation Hub Board)"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub

datum/design/telepad
	name = "Machine Design (Telepad Board)"
	desc = "The circuit board for a telescience telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 4, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad

datum/design/sleeper
	name = "Machine Design (Sleeper Board)"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper

datum/design/cryotube
	name = "Machine Design (Cryotube Board)"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube

datum/design/thermomachine
	name = "Machine Design (Freezer/Heater Board)"
	desc = "The circuit board for a freezer/heater."
	id = "thermomachine"
	req_tech = list("programming" = 3, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/thermomachine

datum/design/biogenerator
	name = "Machine Design (Biogenerator Board)"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator

datum/design/hydroponics
	name = "Machine Design (Hydroponics Tray Board)"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	req_tech = list("programming" = 1, "biotech" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics

datum/design/microwave
	name = "Machine Design (Microwave Board)"
	desc = "The circuit board for a microwave."
	id = "microwave"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave

datum/design/chem_dispenser
	name = "Machine Design (Portable Chem Dispenser Board)"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4, "materials" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser

datum/design/destructive_analyzer
	name = "Machine Design (Destructive Analyzer Board)"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer

datum/design/protolathe
	name = "Machine Design (Protolathe Board)"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe

datum/design/circuit_imprinter
	name = "Machine Design (Circuit Imprinter Board)"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter

datum/design/autolathe
	name = "Machine Design (Autolathe Board)"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe

datum/design/rdservercontrol
	name = "Computer Design (R&D Server Control Console Board)"
	desc = "The circuit board for an R&D Server Control Console"
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol

datum/design/rdserver
	name = "Machine Design (R&D Server Board)"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver

datum/design/mechfab
	name = "Machine Design (Exosuit Fabricator Board)"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab


datum/design/cyborgrecharger
	name = "Machine Design (Cyborg Recharger Board)"
	desc = "The circuit board for a Cyborg Recharger"
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger

datum/design/mech_recharger
	name = "Machine Design (Mechbay Recharger Board)"
	desc = "The circuit board for a Mechbay Recharger."
	id = "mech_recharger"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger

datum/design/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor


/////////////////////////////////////////
////////////Power Stuff//////////////////
/////////////////////////////////////////

datum/design/pacman
	name = "Machine Design (PACMAN-type Generator Board)"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	req_tech = list("programming" = 3, "plasmatech" = 3, "powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	reliability = 79
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman

datum/design/superpacman
	name = "Machine Design (SUPERPACMAN-type Generator Board)"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	reliability = 76
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/super

datum/design/mrspacman
	name = "Machine Design (MRSPACMAN-type Generator Board)"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 5)
	build_type = IMPRINTER
	reliability = 74
	materials = list("$glass" = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/mrs


/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability = 76
	build_path = /obj/item/device/mass_spectrometer

datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability = 74
	build_path = /obj/item/device/mass_spectrometer/adv

datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 500, "$glass" = 250)
	reliability = 76
	build_path = /obj/item/device/mmi
	category = "Misc"

datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 600, "$glass" = 250)
	reliability = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = "Misc"

datum/design/drone_shell
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	id = "drone_shell"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = MECHFAB
	materials = list("$metal" = 800, "$glass" = 350)
	build_path = /obj/item/drone_shell
	category = "Misc"

datum/design/augment_l_arm
	name = "augmented left arm"
	desc = "a mechanical left arm"
	id = "l_arm_aug"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = MECHFAB
	materials = list("$metal" = 250)
	build_path = /obj/item/augment/l_arm
	category = "Misc"

datum/design/augment_r_arm
	name = "augmented right arm"
	desc = "a mechanical right arm"
	id = "r_arm_aug"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = MECHFAB
	materials = list("$metal" = 250)
	build_path = /obj/item/augment/r_arm
	category = "Misc"

datum/design/augment_l_leg
	name = "augmented left leg"
	desc = "a mechanical left leg"
	id = "l_leg_aug"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = MECHFAB
	materials = list("$metal" = 250)
	build_path = /obj/item/augment/l_leg
	category = "Misc"

datum/design/augment_r_leg
	name = "augmented right leg"
	desc = "a mechanical right leg"
	id = "right_leg_aug"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = MECHFAB
	materials = list("$metal" = 250)
	build_path = /obj/item/augment/r_leg
	category = "Misc"

datum/design/augment_chest
	name = "augmented chest"
	desc = "a mechanical chest"
	id = "chest_aug"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = MECHFAB
	materials = list("$metal" = 350)
	build_path = /obj/item/augment/chest
	category = "Misc"

datum/design/augment_head
	name = "augmented head"
	desc = "a mechanical head"
	id = "head_aug"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = MECHFAB
	materials = list("$metal" = 350)
	build_path = /obj/item/augment/head
	category = "Misc"

datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list("$metal" = 400, "$glass" = 400)
	reliability = 76
	build_path = /obj/item/device/flash/synthetic
	category = "Misc"

datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$metal" = 1000, "$glass" = 1000, "$plasma" = 10000, "$diamond" = 500)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = "Misc"

datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = "Misc"

/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 3, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$uranium" = 2000)
	reliability = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	locked = 1

datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver
	locked = 1

datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 10000, "$diamond" = 2000)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	locked = 1

datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 8, "materials" = 7, "biotech" = 5, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 5000,"$uranium" = 8000, "mutagen" = 40)
	build_path = /obj/item/weapon/gun/energy/decloner
	locked = 1
/*
datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000)
	reliability = 100
	build_path = /obj/item/weapon/chemsprayer"
*/
datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 6000, "$glass" = 2000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe

datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A reverse-engineered energy crossbow."
	id = "largecrossbow"
	req_tech = list("combat" = 4, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 8000, "$glass" = 4000, "$uranium" = 3750, "$silver" = 2000)
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
	locked = 1

datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that fires a concentrated temperature-altering projectile."//Change it if you want
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 1000, "$silver" = 3750)
	build_path = /obj/item/weapon/gun/energy/temperature
	locked = 1

datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1000, "$glass" = 250, "radium" = 20)
	build_path = /obj/item/weapon/gun/energy/floragun

datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 1800)
	reliability = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large

datum/design/m1911
	name = ".45 Handgun"
	desc = "A low-capacity ballistic handgun built on a classic design that uses medium ammunition."
	id = "m1911"
	req_tech = list("combat" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 6000, "$silver" = 3750, "$gold" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic/deagle/m1911
	locked = 1

datum/design/smg
	name = "9mm Submachine Gun"
	desc = "A prototype high-capacity ballistic submachine gun that uses light ammunition."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 9000, "$silver" = 5000, "$diamond" = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic
	locked = 1

datum/design/xray
	name = "Xray Laser Gun"
	desc = "Not quite as menacing as it sounds"
	id = "xray"
	req_tech = list("combat" = 6, "materials" = 5, "biotech" = 5, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list("$gold" = 8000,"$uranium" = 12000, "$metal" = 10000, "$glass" = 5000)
	build_path = /obj/item/weapon/gun/energy/xray
	locked = 1

datum/design/ionrifle
	name = "Ion Rifle"
	desc = "A man-portable anti-armor weapon designed to disable mechanical threats at range."
	id = "ionrifle"
	req_tech = list("combat" = 5, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$silver" = 20000, "$metal" = 10000, "$uranium" = 5000, "$glass" = 5000)
	build_path = /obj/item/weapon/gun/energy/ionrifle
	locked = 1

datum/design/mag_m1911
	name = "M1911 Magazine (.45)"
	desc = "An 8-rnd magazine of .45 ammunition for the M1911 handgun."
	id = "mag_m1911"
	req_tech = list("combat" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 3750)
	build_path = /obj/item/ammo_box/magazine/sm45

datum/design/mag_smg
	name = "Submachine Gun Magazine (9mm)"
	desc = "A 20-rnd magazine of 9mm ammunition for the prototype submachine gun."
	id = "mag_smg"
	req_tech = list("combat" = 4, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 3750)
	build_path = /obj/item/ammo_box/magazine/msmg9mm

datum/design/mag_smgincendiary
	name = "Submachine Gun Magazine (9mm incendiary)"
	desc = "A 10-rnd magazine of 9mm plasma-coated ammunition for the prototype submachine gun."
	id = "mag_smgincendiary"
	req_tech = list("combat" = 4, "materials" = 5, "syndicate" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 3750, "$plasma" = 1000)
	build_path = /obj/item/ammo_box/magazine/msmg9mm/incendiary

datum/design/stunslug
	name = "Stun Slug"
	desc = "A stunning, electrified slug for a shotgun."
	id = "stunslug"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1000)
	build_path = /obj/item/ammo_casing/shotgun/stunslug

datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell of rubber pellets for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500)
	build_path = /obj/item/ammo_casing/shotgun/stunshell

datum/design/dragonshell
	name = "Dragon's Breath Shell"
	desc = "A shell full of flammable pellets for a shotgun."
	id = "dragonshell"
	req_tech = list("combat" = 4, "materials" = 5, "syndicate" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$plasma" = 100)
	build_path = /obj/item/ammo_casing/shotgun/dragon


/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	id = "jackhammer"
	req_tech = list("materials" = 3, "powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 500, "$silver" = 500)
	build_path = /obj/item/weapon/pickaxe/jackhammer

datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 6000, "$glass" = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill

datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."
	id = "pick_diamond"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 2500, "$metal" = 2000)
	build_path = /obj/item/weapon/pickaxe/diamond

datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 10000, "$glass" = 8000, "$diamond" = 4500) //Yes, a whole diamond is needed.
	reliability = 79
	build_path = /obj/item/weapon/pickaxe/diamonddrill

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 2, "plasmatech" = 2, "engineering" = 2, "combat" = 1, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 1500, "$glass" = 500, "$plasma" = 200)
	reliability = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter_adv"
	req_tech = list("materials" = 4, "plasmatech" = 3, "engineering" = 3, "combat" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 1000, "$plasma" = 1000, "$silver" = 500, "$gold" = 100)
	reliability = 79
	build_path = /obj/item/weapon/gun/energy/plasmacutter/adv

/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list ("$metal" = 20, "$glass" = 10)
	build_path = /obj/item/device/radio/beacon

datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$gold" = 15000, "$diamond" = 7500, "$uranium" = 1000)
	reliability = 80
	build_path = /obj/item/weapon/storage/backpack/holding

datum/design/bag_holding/belt
	name = "Belt of Holding"
	desc = "A belt that opens into a localized pocket of Blue Space."
	id = "belt_holding"
	materials = list("$gold" = 7500, "$diamond" = 3750, "$uranium" = 500, "$silver" = 3750)
	build_path = /obj/item/weapon/storage/backpack/holding/belt

datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$diamond" = 5000, "$plasma" = 5000)
	reliability = 100
	build_path = /obj/item/bluespace_crystal/artificial

/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/health

datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$silver" = 250)
	build_path = /obj/item/clothing/glasses/hud/health/night

datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/security

datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$gold" = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night

datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$gold" = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	locked = 1

/////////////////////////////////////////
//////////////////Test///////////////////
/////////////////////////////////////////

	/*	test
			name = "Test Design"
			desc = "A design to test the new protolathe."
			id = "protolathe_test"
			build_type = PROTOLATHE
			req_tech = list("materials" = 1)
			materials = list("$gold" = 3000, "iron" = 15, "copper" = 10, "$silver" = 2500)
			build_path = /obj/item/weapon/banhammer" */

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	m_amt = 30
	g_amt = 10
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/New()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)


/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////
datum/design/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Allows for the construction of illegal upgrades for cyborgs"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "syndicate" = 3)
	build_path = /obj/item/borg/upgrade/syndicate
	category = "Cyborg Upgrade Modules"

/////////////////////////////////////////
//////////////////Misc///////////////////
/////////////////////////////////////////

datum/design/detective_scanner
	name = "forensic scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	id = "forensicscanner"
	req_tech = list("materials" = 3, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$glass" = 3000)
	build_path = /obj/item/device/detective_scanner
	locked = 1

datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 4000, "$glass" = 1000)
	build_path = /obj/item/clothing/mask/gas/welding

datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	id = "mesons"
	req_tech = list("materials" = 2, "magnets" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200)
	build_path = /obj/item/clothing/glasses/meson

datum/design/mesons_adv
	name = "Advanced Meson Scanners"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	id = "mesons_adv"
	req_tech = list("materials" = 3, "magnets" = 3, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$plasma" = 150)
	build_path = /obj/item/clothing/glasses/meson/adv

datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_visision_goggles"
	req_tech = list("magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 100, "$glass" = 100, "$uranium" = 5000)
	build_path = /obj/item/clothing/glasses/night

datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 4500, "$silver" = 1500, "$gold" = 2500)
	build_path = /obj/item/clothing/shoes/magboots
