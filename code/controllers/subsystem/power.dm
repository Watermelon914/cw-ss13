var/datum/subsystem/power/SSpower

var/list/power_machines = list()

/datum/subsystem/power
	name          = "Power"
	init_order    = SS_INIT_POWER
	display_order = SS_DISPLAY_POWER
	priority      = SS_PRIORITY_POWER
	wait          = 2 SECONDS

	var/list/currentrun_cables
	var/list/currentrun_powerents
	var/list/currentrun_power_machines


/datum/subsystem/power/New()
	NEW_SS_GLOBAL(SSpower)


/datum/subsystem/power/stat_entry()
	..("C:[cable_list.len]|PN:[powernets.len]|PM:[power_machines.len]")


/datum/subsystem/power/Initialize(timeofday)
	makepowernets()
	..()


/datum/subsystem/power/fire(resumed = FALSE)
	if (!resumed)
		currentrun_cables         = global.cable_list.Copy()
		currentrun_powerents      = global.powernets.Copy()
		currentrun_power_machines = global.power_machines.Copy()

	// First we reset the powernets.
	// This is done first because we want the power machinery to have acted last on the powernet between intervals.
	while (currentrun_cables.len)
		var/obj/structure/cable/PC = currentrun_cables[currentrun_cables]
		currentrun_cables.len--
		if (!PC || PC.gcDestroyed || PC.disposed)
			continue

		// Does a powernet need rebuild? Lets do it!
		//if (PC.build_status && PC.rebuild_from() && MC_TICK_CHECK)
		if(MC_TICK_CHECK)
			return

	while (currentrun_powerents.len)
		var/datum/powernet/powerNetwork = currentrun_powerents[currentrun_powerents.len]
		currentrun_powerents.len--
		if (!powerNetwork || powerNetwork.disposed)
			continue

		//powerNetwork.reset()
		if (MC_TICK_CHECK)
			return

	// Next we let the power machines operate, this way until the next tick it will be as if they have all done their work.
	while (currentrun_power_machines.len)
		var/datum/X = currentrun_power_machines[currentrun_power_machines.len]
		currentrun_power_machines.len--
		if (!X || X.gcDestroyed || X.disposed)
			continue

		if (istype(X, /obj/machinery))
			var/obj/machinery/M = X
			if (M.timestopped)
				continue

			//M.check_rebuild() //Checks to make sure the powernet doesn't need to be rebuilt, rebuilds it if it does

			if (M.process() == PROCESS_KILL)
				//M.inMachineList = FALSE
				power_machines.Remove(M)
				continue

			if (M.use_power)
				M.auto_use_power()

		if (MC_TICK_CHECK)
			return