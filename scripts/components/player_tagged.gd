class_name PlayerTagged
extends Node

var tagged_player_name: String = "":
	set(value):
		tagged_player_name = value

func is_player_tagged() -> bool:
	return tagged_player_name != ""
