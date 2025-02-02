var/list/uplink_items = list()

/proc/get_uplink_items()
	// If not already initialized..
	if(!uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.gamemodes.len && ticker && !(ticker.mode.type in I.gamemodes))
				continue
			if(I.excludefrom.len && ticker && (ticker.mode.type in I.excludefrom))
				continue
			if(I.last)
				last += I
				continue

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)

			if(!uplink_items[I.category])
				uplink_items[I.category] = list()

			uplink_items[I.category] += I

	return uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/list/gamemodes = list() // Empty list means it is in all the gamemodes. Otherwise place the gamemode name here.
	var/list/excludefrom = list()//Empty list does nothing. Place the name of gamemode you don't want this item to be available in here. This is so you dont have to list EVERY mode to exclude something.

/datum/uplink_item/proc/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)
	if(item)
		U.uses -= max(cost, 0)
		U.used_TC += cost
		feedback_add_details("traitor_uplink_items_bought", "[item]")
		return new item(loc)

/datum/uplink_item/proc/buy(var/obj/item/device/uplink/U, var/mob/user)

	..()
	if(!istype(U))
		return 0

	if (!user || user.stat || user.restrained())
		return 0

	if (!( istype(user, /mob/living/carbon/human)))
		return 0

	// If the uplink's holder is in the user's contents
	if ((U.loc in user.contents || (in_range(U.loc, user) && istype(U.loc.loc, /turf))))
		user.set_machine(U)
		if(cost > U.uses)
			return 0

		var/obj/I = spawn_item(get_turf(user), U)

		if(istype(I, /obj/item) && ishuman(user))
			var/mob/living/carbon/human/A = user
			A.put_in_any_hand_if_possible(I)

			if(istype(I,/obj/item/weapon/storage/box/) && I.contents.len>0)
				for(var/atom/o in I)
					U.purchase_log += "<BIG>\icon[o]</BIG>"
			else
				U.purchase_log += "<BIG>\icon[I]</BIG>"

		U.interact(user)
		return 1
	return 0

/*
//
//	UPLINK ITEMS
//
*/

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Conspicuous and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "Syndicate Revolver"
	desc = "The syndicate revolver is a traditional handgun that fires .357 Magnum cartridges and has 7 chambers."
	item = /obj/item/weapon/gun/projectile/revolver
	cost = 6

/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 8-round 10mm magazines and is compatible with silencers."
	item = /obj/item/weapon/gun/projectile/automatic/pistol
	cost = 5

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms-developed submachine gun that uses 20-round .45 ACP magazines and is compatible with silencers."
	item = /obj/item/weapon/gun/projectile/automatic/c20r
	cost = 7
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A traditionally constructed machine gun made by AA-2531. This deadly weapon has a massive 50-round magazine of 7.62x51mm ammunition."
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw
	cost = 20
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/crossbow
	name = "Miniature Energy Crossbow"
	desc = "A short bow mounted across a tiller in miniature. Small enough to fit into a pocket or slip into a bag unnoticed. It fires bolts tipped with toxins collected from a rare organism. \
	Its bolts also stun enemies for short periods, and replenish automatically."
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 5
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/weapon/melee/energy/sword
	cost = 4

/datum/uplink_item/dangerous/emp
	name = "EMP Kit"
	desc = "A box that contains two EMP grenades, an EMP implant and a short ranged recharging device disguised as a flashlight. Useful to disrupt communication and silicon lifeforms."
	item = /obj/item/weapon/storage/box/syndie_kit/emp
	cost = 3

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The Minibomb is a grenade with a five-second fuse."
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 3

/datum/uplink_item/dangerous/viscerators
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of razor-viscerators upon activation, which will chase down and shred any non-operatives in the area."
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks
	cost = 4
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/bioterror
	name = "Biohazardous Chemical Sprayer"
	desc = "A chemical sprayer that allows a wide dispersal of selected chemicals. Especially tailored by the Tiger Cooperative, the deadly blend it comes stocked with will disorient, damage, and disable your foes... \
	Use with extreme caution, to prevent exposure to yourself and your fellow operatives."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer/bioterror
	cost = 10
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/gygax
	name = "Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent for hit-and-run style attacks. \
	This model lacks a method of space propulsion, and therefore it is advised to repair the mothership's teleporter if you wish to make use of it."
	item = /obj/mecha/combat/gygax/dark/loaded
	cost = 45
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly Syndicate exosuit. Features long-range targetting, space thrusters, and mounted smoke-screen launchers."
	item = /obj/mecha/combat/marauder/mauler/loaded
	cost = 70
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/syndieborg
	name = "Syndicate Cyborg"
	desc = "A cyborg designed for extermination and slaved to syndicate agents. Delivered through a single-use bluespace hand teleporter and comes pre-equipped with a brain-loaded MMI."
	item = /obj/item/weapon/antag_spawner/borg_tele
	cost = 26 //can't buy two with 50tc
	gamemodes = list(/datum/game_mode/nuclear)
//for refunding the syndieborg teleporter
/datum/uplink_item/dangerous/syndieborg/spawn_item()
	var/obj/item/weapon/antag_spawner/borg_tele/T = ..()
	if(istype(T))
		T.TC_cost = cost

// AMMUNITION

/datum/uplink_item/ammo
	category = "Ammunition"

/datum/uplink_item/ammo/revolver
	name = "Ammo-357"
	desc = "A box that contains seven additional rounds for the revolver, made using an automatic lathe."
	item = /obj/item/ammo_box/a357
	cost = 2

/datum/uplink_item/ammo/smg
	name = "Ammo-.45 ACP"
	desc = "A 20-round .45 ACP magazine for use in the C-20r submachine gun. These rounds have a short stunning effect and medium impact damage."
	item = /obj/item/ammo_box/magazine/c20rm
	cost = 1
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/smgincendiary
	name = "Ammo-.45 Incendiary"
	desc = "A 10-round .45 incendiary magazine for use in the C-20r submachine gun. These rounds do not stun and are weaker on impact than typical ammo but are coated with incendiary."
	item = /obj/item/ammo_box/magazine/c20rm/incendiary
	cost = 1
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/pistol
	name = "Ammo-10mm"
	desc = "An additional 8-round 10mm magazine for use in the Stetchkin pistol."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1

/datum/uplink_item/ammo/bullstun
	name = "Ammo-12g Stun Slug"
	desc = "An additional 8-round stun slug magazine for use in the Bulldog shotgun. Accurate, reliable, powerful."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/bullbuck
	name = "Ammo-12g Buckshot"
	desc = "An alternative 8-round buckshot magazine for use in the Bulldog shotgun. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g/buckshot
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/bulldragon
	name = "Ammo-12g Dragon's Breath"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. I'm a fire starter, twisted fire starter!"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	cost = 3
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/ammo/machinegun
	name = "Ammo-7.62�51mm"
	desc = "A 50-round magazine of 7.62�51mm ammunition for use in the L6 SAW machinegun. By the time you need to use this, you'll already be on a pile of corpses."
	item = /obj/item/ammo_box/magazine/m762
	cost = 6
	gamemodes = list(/datum/game_mode/nuclear)

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"

/datum/uplink_item/stealthy_weapons/para_pen
	name = "Paralysis Pen"
	desc = "A syringe disguised as a functional pen, filled with a neuromuscular-blocking drug that renders a target immobile on injection and makes them seem dead to observers. \
	Side effects of the drug include noticeable drooling. The pen holds one dose of paralyzing agent, and cannot be refilled."
	item = /obj/item/weapon/pen/paralysis
	cost = 4
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/stealthy_weapons/chem_pen
	name = "Chem Pen"
	desc = "A multiuse air-needle injector disguised as a functional pen, filled with a strong sedative that will knock out targets after a few seconds. Comes with 3 uses and can be refilled with any other chemical of your choice."
	item = /obj/item/weapon/pen/chem
	cost = 5
	excludefrom = list(/datum/game_mode/nuclear) //is this really needed?

/datum/uplink_item/stealthy_weapons/poisonkit
	name = "Poison Kit"
	desc = "A box containing 3 bottles of a random poison. The first bottle contains a regular poison, the second bottle contains an utility based poison and the last bottle contains a very dangerous poison."
	item = /obj/item/weapon/storage/box/syndie_kit/poison
	cost = 3
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. You can also drop it underfoot to slip people."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five opportunities to detonate PDAs of crewmembers who have their message feature enabled. \
	The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer. It has a chance to detonate your PDA."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 3

/datum/uplink_item/stealthy_weapons/silencer
	name = "Syndicate Silencer"
	desc = "A universal small-arms silencer favored by stealth operatives, this will make shots quieter when equipped onto any low-caliber weapon."
	item = /obj/item/weapon/silencer
	cost = 2

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"

/datum/uplink_item/stealthy_tools/chameleon_jumpsuit
	name = "Chameleon Jumpsuit"
	desc = "A jumpsuit used to imitate the uniforms of Nanotrasen crewmembers."
	item = /obj/item/clothing/under/chameleon
	cost = 3

/datum/uplink_item/stealthy_tools/chameleon_stamp
	name = "Chameleon Stamp"
	desc = "A stamp that can be activated to imitate an official Nanotrasen Stamp�. The disguised stamp will work exactly like the real stamp and will allow you to forge false documents to gain access or equipment; \
	it can also be used in a washing machine to forge clothing."
	item = /obj/item/weapon/stamp/chameleon
	cost = 1

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Brown Shoes"
	desc = "These allow you to run on wet floors. They do not work on lubricated surfaces."
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 2

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access from other identification cards. The access is cumulative, so scanning one card does not erase the access gained from another."
	item = /obj/item/weapon/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	item = /obj/item/clothing/mask/gas/voice
	desc = "A conspicuous gas mask that mimics the voice named on your identification card. When no identification is worn, the mask will render your voice unrecognizable."
	cost = 4

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't move the projector from their hand. The disguised user cannot run and rojectiles pass over them."
	item = /obj/item/device/chameleon
	cost = 4

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to bug cameras to view them remotely. Adding particular items to it alters its functions."
	item = /obj/item/device/camera_bug
	cost = 2

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The emag is a small card that unlocks hidden functions in electronic devices, subverts intended functions and characteristically breaks security mechanisms."
	item = /obj/item/weapon/card/emag
	cost = 3

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "The syndicate toolbox is a suspicious black and red. Aside from tools, it comes with cable and a multitool. Insulated gloves are not included."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Medical Supply Kit"
	desc = "The syndicate medkit is a suspicious black and red. Included is a combat stimulant injector for rapid healing, a medical hud for quick identification of injured comrades, \
	and other medical supplies helpful for a medical field operative.."
	item = /obj/item/weapon/storage/firstaid/tactical
	cost = 5
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/space_suit
	name = "Syndicate Space Suit"
	desc = "The red and black syndicate space suit is less encumbering than Nanotrasen variants, fits inside bags, and has a weapon slot. Nanotrasen crewmembers are trained to report red space suit sightings."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These glasses are thermals disguised as engineers' optical meson scanners. \
	They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, emitted as heat and light by objects. \
	Hotter objects, such as warm bodies, cybernetic organisms and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 3

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key, that when inserted into a radio headset, allows you to listen to and talk with artificial intelligences and cybernetic organisms in binary. "
	item = /obj/item/device/encryptionkey/binary
	cost = 3

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it or its holder. Knowing when an artificial intelligence is watching you is useful for knowing when to maintain cover."
	item = /obj/item/device/multitool/ai_detect
	cost = 1

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. Be careful with their wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/weapon/aiModule/syndicate
	cost = 7

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, attach it to organisms to destroy them, or connect a signaler to its wiring to make it remotely detonable. \
	It has a modifiable timer with a minimum setting of 10 seconds."
	item = /obj/item/weapon/plastique
	cost = 2

/datum/uplink_item/device_tools/powersink
	name = "Power sink"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device places excessive load on the grid, causing a stationwide blackout. The sink cannot be carried because of its excessive size. \
	Ordering this sends you a small beacon that will teleport the power sink to your location on activation."
	item = /obj/item/device/powersink
	cost = 5

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "When screwed to wiring attached to an electric grid, then activated, this large device pulls the singularity towards it. \
	Does not work when the singularity is still in containment. A singularity beacon can cause catastrophic damage to a space station, \
	leading to an emergency evacuation. Because of its size, it cannot be carried. Ordering this sends you a small beacon that will teleport the larger beacon to your location on activation."
	item = /obj/item/device/sbeacondrop
	cost = 7

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate Bomb has an adjustable timer with a minimum setting of 60 seconds. Ordering the bomb sends you a small beacon, which will teleport the explosive to your location when you activate it. \
	You can wrench the bomb down to prevent removal. The crew may attempt to defuse the bomb."
	item = /obj/item/device/sbeacondrop/bomb
	cost = 5

/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate Detonator is a companion device to the Syndicate Bomb. Simply press the included button and an encrypted radio frequency will instruct all live syndicate bombs to detonate. \
	Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of the blast radius before using the detonator."
	item = /obj/item/device/syndicatedetonator
	cost = 1
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/teleporter
	name = "Teleporter Circuit Board"
	desc = "A printed circuit board that completes the teleporter onboard the shuttle. It is advised that you test fire the teleporter before entering it, as malfunctions can occur."
	item = /obj/item/weapon/circuitboard/teleporter
	cost = 20
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending against other attacks."
	item = /obj/item/weapon/shield/energy
	cost = 8
	gamemodes = list(/datum/game_mode/nuclear)

// STOLEN TECH

/datum/uplink_item/stolen
	category = "Stolen Tech"

/datum/uplink_item/stolen/pinpointer
	name = "Nuclear Authentication Disk Pinpointer"
	desc = "A stolen Nanotrasen pinpointer that, when activated, will pinpoint the approximate location of any nuclear authentication disks within 10km. Don't lose this."
	item = /obj/item/weapon/pinpointer
	cost = 3
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/stolen/magboots
	name = "Stolen Magboots"
	desc = "A pair of magnetic boots that assist with freer movement in space or on-station during gravitational generator failures. \
	These reverse-engineered knockoffs of Nanotrasen's 'Advanced Magboots' slow you down in simulated-gravity environments much like the standard issue variety."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 2
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/stolen/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fueled by highly flammable biotoxins stolen previously from Nanotrasen stations. Make a statement by roasting the filth in their own greed. \
	Caution: Recommended only to be used by agents familiar with plasma and its properties. \
	Full tank included with purchase!"
	item = /obj/item/weapon/flamethrower/full/tank
	cost = 6
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/stolen/plasmatank
	name = "Stolen Plasma Tank"
	desc = "A stolen tank full of a highly flammable gas known as 'plasma'. Our agents have recovered this tank for careful testing and analysis, and turning it back on Nanotrasen is the perfect 'trial by fire.'"
	item = /obj/item/weapon/tank/plasma/full
	cost = 3
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/stolen/rcd
	name = "Stolen Rapid-Construction Device"
	desc = "A stolen RCD that uses modified compressed matter cartridges to rapidly assemble or disassemble basic structures such as walls or airlocks."
	item = /obj/item/weapon/rcd
	cost = 6
	gamemodes = list(/datum/game_mode/nuclear)

/datum/uplink_item/stolen/mcmc
	name = "Modified Compressed Matter Cartridge"
	desc = "A stolen compressed matter cartridge that has been modified to completely fill an RCD to its limit. Is it safe? Not our problem!"
	item = /obj/item/weapon/rcd_ammo/syndie
	cost = 3 //RCD + full ammo mag costs 9tc
	gamemodes = list(/datum/game_mode/nuclear)

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated using a bodily gesture to attempt to slip restraints."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 3

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to open an uplink with 5 telecrystals. \
	The ability for an agent to open an uplink after their posessions have been stripped from them makes this implant excellent for escaping confinement."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 10

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated using a bodily gesture to inject a chemical cocktail, which has a mild healing effect along with removing all stuns and increasing his speed."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_adrenal
	cost = 4

/datum/uplink_item/implants/wire_kit_doors
	name = "Wire Knowledge: Doors"
	desc = "An implant granting you the knowledge of Non-secure Airlock and Door wire systems"
	item = /obj/item/weapon/storage/box/syndie_kit/imp_wire_door
	cost = 2 //2 because unlike the Emag, this needs tools

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Syndicate Bundles are specialised groups of items that arrive in a plain box. These items are collectively worth more than 10 telecrystals, but you do not know which specialisation you will receive."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 10
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a mono-molecular edge and metal reinforcement, making them slightly more robust than a normal deck of cards. \
	You can also play card games with them."
	item = /obj/item/toy/cards/deck/syndicate
	cost = 1
	excludefrom = list(/datum/game_mode/nuclear)

/datum/uplink_item/badass/balloon
	name = "For showing that you are The Boss"
	desc = "A useless red balloon with the syndicate logo on it, which can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 10

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Picking this choice will send you a random item from the list. Useful for when you cannot think of a strategy to finish your objectives with."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(var/turf/loc, var/obj/item/device/uplink/U)

	var/list/buyable_items = get_uplink_items()
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)
