/*
README:

The global_iterator datum is supposed to provide a simple and robust way to
create some constantly "looping" processes with ability to stop and restart them at will.
Generally, the only thing you want to play with (meaning, redefine) is the process() proc.
It must contain all the things you want done.

Control functions:
	new - used to create datum. First argument (optional) - var list(to use in process() proc),
	second (optional) - autostart control.
	If autostart == TRUE, the loop will be started immediately after datum creation.

	start(list/arguments) - starts the loop. Takes arguments(optional) as a list, which is then used
	by process() proc. Returns null if datum already active, 1 if loop started succesfully and 0 if there's
	an error in supplied arguments (not list or empty list).

	stop() - stops the loop. Returns null if datum is already inactive and 1 on success.

	set_delay(new_delay) - sets the delay between iterations. Pretty selfexplanatory.
	Returns 0 on error(new_delay is not numerical), 1 otherwise.

	set_process_args(list/arguments) - passes the supplied arguments to the process() proc.

	active() - Returns 1 if datum is active, 0 otherwise.

Misc functions:

	get_last_exec_time() - Returns the time of last iteration.

	get_last_exec_time_as_text() - Returns the time of last iteration as text


Control vars:

	delay - 	delay between iterations

	check_for_null - if equals TRUE, on each iteration the supplied arguments will be checked for nulls.
	If some varible equals null, the loop is stopped.
	Usefull, if some var unexpectedly becomes null - due to object deletion, for example.
	Of course, you can check the variables inside process() proc to prevent runtime errors.

Data storage vars:

	result - stores the value returned by process() proc

*/

/datum/global_iterator
	var/control_switch = 0
	var/delay = 10
	var/list/arg_list = new
	var/last_exec = null
	var/check_for_null = 1
	var/forbid_garbage = 0
	var/result

	New(list/arguments=null,autostart=1)
		if(forbid_garbage) //prevents garbage collection with tag != null
			tag = "\ref[src]"
		set_process_args(arguments)
		if(autostart)
			start()
		return

	proc/main()
		while(src && control_switch)
			last_exec = world.timeofday
			if(check_for_null && has_null_args())
				return src.stop()
			result = src.process(arglist(arg_list))
			sleep(delay)
		return

	proc/start(list/arguments=null)
		if(src.active())
			return
		if(arguments)
			if(!set_process_args(arguments))
				return 0
		control_switch = 1
		spawn()
			src.main()
		return 1

	proc/stop()
		if(!src.active())
			return
		control_switch = 0
		return 1

	proc/process()
		return

	proc/active()
		return control_switch

	proc/has_null_args()
		if(null in arg_list) //Hope no "" or 0 errors here.
			return 1
/*
			for(var/V in arg_list)
				if(isnull(V))
					return 1
*/
		return 0


	proc/set_delay(new_delay)
		if(isnum(new_delay))
			delay = new_delay
			return 1
		else
			return 0

	proc/get_last_exec_time()
		return (last_exec||0)

	proc/get_last_exec_time_as_text()
		return (time2text(last_exec)||"Wasn't executed yet")

	proc/set_process_args(list/arguments)
		if(arguments && istype(arguments, /list) && arguments.len)
			arg_list = arguments
			return 1
		else
//			world << "\red Invalid arguments supplied for [src.type], ref = \ref[src]"
			return 0

	proc/toggle_null_checks()
		src.check_for_null = !src.check_for_null
		return

	proc/toggle()
		if(!src.stop())
			src.start()
		return

