class_name Game
extends PanelContainer


var resource: GameResource = GameResource.new()

@onready var board = %Board
@onready var referee = %Referee
@onready var notation = %Notation


func _ready() -> void:
	board.resource = resource.board
	referee.resource = resource.referee
	notation.resource = resource.notation
	
