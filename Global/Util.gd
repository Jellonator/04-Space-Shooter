extends Node

func get_nearest_player(frompos: Vector2):
	var ret = null
	var dis = 0.0
	for player in get_tree().get_nodes_in_group("player"):
		var newdis = player.global_position.distance_to(frompos)
		if ret == null or newdis < dis:
			dis = newdis
			ret = player
	return ret
