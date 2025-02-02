var/list/cluwnelist

#define CLUWNELISTFILE "data/cluwne.txt"
/proc/load_cluwnelist()
	var/text = file2text(CLUWNELISTFILE)
	if (!text)
		diary << "Failed to [CLUWNELISTFILE]\n"
	else
		cluwnelist = dd_text2list(text, "\n")

/proc/check_cluwnelist(mob/M /*, var/rank*/)
	if(!cluwnelist)
		return 0
	var/feresult = world.Export("http://api.d2k5.com/ss13/auth.php?ckey=[M.ckey]&isCluwne")
	if(!feresult)
		return 0
	if(!feresult["CONTENT"])
		return 0
	var/feresultcontent = file2text(feresult["CONTENT"])
	var/feresultcode = lowertext(feresultcontent)
	if(feresultcode == "cluwne")
		return 1
	else
		return ("[M.ckey]" in cluwnelist)

#undef CLUWNELISTFILE