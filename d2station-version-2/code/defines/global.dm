var/global
	obj/datacore/data_core = null
	obj/overlay/plmaster = null
	obj/overlay/slmaster = null

	//obj/hud/main_hud1 = null

	list/machines = list()
	list/processing_items = list()
	list/active_diseases = list()
		//items that ask to be called every cycle

	defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

	powerreport = null //muskets 250810 these four are needed for the new engineering pda to work
	powerreportnodes = null //might be a better way to do it but w/e
	powerreportavail = null
	powerreportviewload = null

	list/global_map = null
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

var

	//////////////

	BLINDBLOCK = 0
	DEAFBLOCK = 0
	HULKBLOCK = 0
	TELEBLOCK = 0
	FIREBLOCK = 0
	XRAYBLOCK = 0
	CLUMSYBLOCK = 0
	FAKEBLOCK = 0
	BLOCKADD = 0
	DIFFMUT = 0

	skipupdate = 0
	///////////////
	eventchance = 1 //% per 2 mins
	event = 0
	hadevent = 0
	blobevent = 0
	meteorevent = 0
	///////////////

	diary = null
	station_name = null
	game_version = "D2Station v2 (devstation redux)"

	datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
	going = 1.0
	master_mode = "extended"

	datum/engine_eject/engine_eject_control = null
	host = null
	aliens_allowed = 1
	ooc_allowed = 1
	dooc_allowed = 1
	traitor_scaling = 1
	goonsay_allowed = 1
	dna_ident = 1
	abandon_allowed = 1
	enter_allowed = 1
	shuttle_frozen = 0
	shuttle_left = 0
	tinted_weldhelh = 1

	captainMax = 1
	engineerMax = 5
	barmanMax = 1
	scientistMax = 3
	chemistMax = 1
	geneticistMax = 2
	securityMax = 4
	hopMax = 1
	hosMax = 1
	directorMax = 1
	chiefMax = 1
	atmosMax = 4
	detectiveMax = 1
	chaplainMax = 2
	janitorMax = 2
	doctorMax = 4
	clownMax = 4
	chefMax = 1
	roboticsMax = 3
	cargoMax = 2
	cargotechMax = 2
	hydroponicsMax = 2
	librarianMax = 1
	lawyerMax = 0
	minerMax = 3
	viroMax = 1
	barberMax = 1
	wardenMax = 0
	cmoMax = 1
	mimeMax = 1
	sorterMax = 0
	borgMax = 3

	list/bombers = list(  )
	list/admin_log = list (  )
	list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
	list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
	list/admins = list(  )
	list/shuttles = list(  )
	list/reg_dna = list(  )
//	list/traitobj = list(  )


	CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
	CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

	shuttle_z = 2	//default
	airtunnel_start = 68 // default
	airtunnel_stop = 68 // default
	airtunnel_bottom = 72 // default
	list/monkeystart = list()
	list/wizardstart = list()
	list/newplayer_start = list()
	list/latejoin = list()
	list/prisonwarp = list()	//prisoners go to these
	list/mazewarp = list()
	list/tdome1 = list()
	list/tdome2 = list()
	list/tdomeobserve = list()
	list/tdomeadmin = list()
	list/puzzlechambersubject = list()
	list/puzzlechamberescape = list()
	list/prisonsecuritywarp = list()	//prison security goes to these
	list/prisonwarped = list()	//list of players already warped
	list/blobstart = list()
	list/blobs = list()
//	list/traitors = list()	//traitor list
	list/cardinal = list( NORTH, SOUTH, EAST, WEST )
	list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

	datum/station_state/start_state = null
	datum/configuration/config = null
	datum/vote/vote = null
	datum/sun/sun = null


	list/powernets = null

	Debug = 0	// global debug switch
	Debug2 = 0

	datum/debug/debugobj

	datum/moduletypes/mods = new()

	wavesecret = 0

	shuttlecoming = 0

	join_motd = null
	auth_motd = null
	rules = null
	no_auth_motd = null
	forceblob = 0

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
	list/airlockWireColorToFlag = RandomAirlockWires()
	list/airlockIndexToFlag
	list/airlockIndexToWireColor
	list/airlockWireColorToIndex
	list/APCWireColorToFlag = RandomAPCWires()
	list/APCIndexToFlag
	list/APCIndexToWireColor
	list/APCWireColorToIndex
	list/BorgWireColorToFlag = RandomBorgWires()
	list/BorgIndexToFlag
	list/BorgIndexToWireColor
	list/BorgWireColorToIndex

	const/SPEED_OF_LIGHT = 3e8 //not exact but hey!
	const/SPEED_OF_LIGHT_SQ = 9e+16
	const/FIRE_DAMAGE_MODIFIER = 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
	const/AIR_DAMAGE_MODIFIER = 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
	const/INFINITY = 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
	const/MAX_MESSAGE_LEN = 1024

	const/shuttle_time_in_station = 1800 // 3 minutes in the station
	const/shuttle_time_to_arrive = 6000 // 10 minutes to arrive



	// MySQL configuration

	sqladdress = "localhost"
	sqlport = "3306"
	sqldb = "tgstation"
	sqllogin = "root"
	sqlpass = ""

	sqllogging = 0 // Should we log deaths, population stats, etc?

