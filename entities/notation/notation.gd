class_name Notation
extends PanelContainer


@export var move_scene: PackedScene

@export var game: Game

var resource: NotationResource

@onready var moves: = %Moves


func add_move(move_resource_: MoveResource) -> void:
	var move = move_scene.instantiate()
	move.resource = move_resource_
	moves.add_child(move)
