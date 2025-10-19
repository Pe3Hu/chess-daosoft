class_name ChessNotation
extends PanelContainer


@export var move_scene: PackedScene


@onready var moves: = $Moves



func add_move(move_resource_: ChessMoveResource) -> void:
	var move = move_scene.instantiate()
	move.resource = move_resource_
	moves.add_child(move)
