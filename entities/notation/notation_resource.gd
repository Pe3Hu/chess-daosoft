class_name NotationResource
extends Resource


var game: GameResource
var moves: Array[MoveResource]


func _init(game_: GameResource) -> void:
	game = game_
	
func record_move(move_: MoveResource) -> void:
	moves.append(move_)
	
