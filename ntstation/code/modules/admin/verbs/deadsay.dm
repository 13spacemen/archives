/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(!src.mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		src << "\red You cannot send DSAY messages (muted)."
		return

	if (src.handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("[key_name(src)] : [msg]")

	if (!msg)
		return
	var/nicknames = file2list("config/admin_nicknames.txt")

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>ADMIN([src.holder.fakekey ? pick(nicknames) : src.key])</span> [pick("moans","complains","cries","whines")], <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in player_list)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat == DEAD || (M.client && M.client.holder && (M.client.prefs.toggles & CHAT_DEAD))) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
			M.show_message(rendered, 2)

	feedback_add_details("admin_verb","D") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
