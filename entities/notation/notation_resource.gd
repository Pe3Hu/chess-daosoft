class_name NotationResource
extends Resource


var board: BoardResource
var moves: Array[MoveResource]


func record_move(move_: MoveResource) -> void:
	moves.append(move_)
	
