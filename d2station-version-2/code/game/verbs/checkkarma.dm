mob/verb/check_karma()
	set name = "Check Karma"
	set category = "Special Verbs"
	set desc = "Reports how much karma you have accrued"

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[sqldb]:[sqladdress]:[sqlport]","[sqllogin]","[sqlpass]")
	if(!dbcon.IsConnected())
		usr << "\red Unable to connect to karma database. This error can occur if your host has failed to set up an SQL database or improperly configured its login credentials.<br>"
		return
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT karma FROM karmatotals WHERE byondkey='[src.key]'")
		query.Execute()

		var/currentkarma
		while(query.NextRow())
			currentkarma = query.item[1]
		if(currentkarma)
			usr << "<b>Your current karma is:</b> [currentkarma]<br>"
		else
			usr << "<b>Your current karma is:</b> 0<br>"
	dbcon.Disconnect()

mob/verb/view_achievements()
	set name = "View Achievements"
	set category = "Special Verbs"
	set desc = "Displays all your achievements."


	usr << "<a href=\"http://www.google.com>Click here to view your achievements!</a>"

