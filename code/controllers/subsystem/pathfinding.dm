
SUBSYSTEM_DEF(xeno_pathfinding)
	name = "Xeno Pathfinding"
	priority = SS_PRIORITY_XENO_PATHFINDING
	flags = SS_NO_INIT|SS_TICKER
	wait = 1
	/// A list of mobs scheduled to process
	var/datum/xeno_pathinfo/current_run
	/// A list of paths to calculate
	var/list/paths_to_calculate = list()

	var/list/hash_path = list()
	var/current_position = 1

/datum/controller/subsystem/xeno_pathfinding/stat_entry(msg)
	msg = "P:[length(paths_to_calculate)]"
	return ..()

/datum/controller/subsystem/xeno_pathfinding/fire(resumed = FALSE)
	if(!length(paths_to_calculate))
		return
	if(current_position <= 0 || current_position > length(paths_to_calculate))
		current_position = 1
	current_run = paths_to_calculate[current_position]
	current_position++

	// A* Pathfinding. Uses priority queue
	var/turf/target = current_run.finish

	var/mob/living/carbon/Xenomorph/X = current_run.travelling_xeno

	var/list/visited_nodes = current_run.visited_nodes
	var/list/distances = current_run.distances
	var/list/f_distances = current_run.f_distances
	var/list/prev = current_run.prev

	while(length(visited_nodes))
		current_run.current_node = visited_nodes[visited_nodes.len]
		visited_nodes.len--
		if(current_run.current_node == target)
			break

		for(var/direction in cardinal)
			var/turf/neighbor = get_step(current_run.current_node, direction)
			var/distance_between = distances[current_run.current_node] * DISTANCE_PENALTY
			if(isnull(distances[neighbor]))
				continue

			if(direction != get_dir(prev[neighbor], neighbor))
				distance_between += DIRECTION_CHANGE_PENALTY

			if(!neighbor.weeds)
				distance_between += NO_WEED_PENALTY

			for(var/i in neighbor)
				var/atom/A = i
				distance_between += A.object_weight

			var/list/L = LinkBlocked(X, current_run.current_node, neighbor, list(X), TRUE)
			if(length(L))
				for(var/i in L)
					var/atom/A = i
					distance_between += A.xeno_ai_obstacle(X, direction)

			if(distance_between < distances[neighbor])
				distances[neighbor] = distance_between
				var/f_distance = distance_between + ASTAR_COST_FUNCTION(neighbor)
				f_distances[neighbor] = f_distance
				prev[neighbor] = current_run.current_node
				if(neighbor in visited_nodes)
					visited_nodes -= neighbor

				for(var/i in 0 to length(visited_nodes))
					var/index_to_check = length(visited_nodes) - i
					if(index_to_check == 0)
						visited_nodes.Insert(1, neighbor)
						break

					if(f_distance < f_distances[visited_nodes[index_to_check]])
						visited_nodes.Insert(index_to_check+1, neighbor)
						break

		if(TICK_CHECK)
			return

	if(!prev[target])
		current_run.to_return.Invoke()
		QDEL_NULL(current_run)
		return

	var/list/path = list()
	var/turf/current_node = target
	while(current_node)
		if(current_node == current_run.start)
			break
		path += current_node
		current_node = prev[current_node]

	current_run.to_return.Invoke(path)
	QDEL_NULL(current_run)

/datum/controller/subsystem/xeno_pathfinding/proc/calculate_path(var/atom/start, var/atom/finish, var/path_range, var/mob/living/carbon/Xenomorph/travelling_xeno, var/datum/callback/CB)
	var/datum/xeno_pathinfo/data = hash_path[travelling_xeno]
	if(current_run == data)
		current_run = null

	if(!data)
		data = new()
		data.RegisterSignal(travelling_xeno, COMSIG_PARENT_QDELETING, /datum/xeno_pathinfo.proc/qdel_wrapper)

		hash_path[travelling_xeno] = data
		paths_to_calculate += data

	data.current_node = get_turf(start)
	data.start = data.current_node

	var/turf/target = get_turf(finish)

	data.finish = target
	data.travelling_xeno = travelling_xeno
	data.to_return = CB
	data.path_range = path_range

	data.distances[data.current_node] = 0
	data.f_distances[data.current_node] = ASTAR_COST_FUNCTION(data.current_node)

	for(var/i in RANGE_TURFS(data.path_range, data.current_node))
		if(i != data.current_node)
			data.distances[i] = INFINITY
			data.f_distances[i] = INFINITY
			data.prev[i] = null

	data.visited_nodes += data.current_node

/datum/xeno_pathinfo
	var/turf/start
	var/turf/finish
	var/mob/living/carbon/Xenomorph/travelling_xeno
	var/datum/callback/to_return
	var/path_range

	var/turf/current_node
	var/list/visited_nodes
	var/list/distances
	var/list/f_distances
	var/list/prev

/datum/xeno_pathinfo/proc/qdel_wrapper()
	SIGNAL_HANDLER
	qdel(src)

/datum/xeno_pathinfo/New()
	. = ..()
	visited_nodes = list()
	distances = list()
	f_distances = list()
	prev = list()

/datum/xeno_pathinfo/Destroy(force)
	SSxeno_pathfinding.hash_path -= travelling_xeno
	SSxeno_pathfinding.paths_to_calculate -= src

	start = null
	finish = null
	travelling_xeno = null
	to_return = null
	return ..()
