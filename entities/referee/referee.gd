class_name Referee
extends PanelContainer


@export var game: Game

var resource: RefereeResource:
	set(value_):
		resource = value_
		init_clocks()
		start_game()

@onready var clocks = %Clocks


func init_clocks() -> void:
	for player_resource in resource.players:
		match player_resource.color:
			FrameworkSettings.PieceColor.WHITE:
				%WhiteClock.resource = player_resource.clock
			FrameworkSettings.PieceColor.BLACK:
				%BlackClock.resource = player_resource.clock
	
func start_game() -> void:
	%WhiteClock._on_switch()
	
func pass_initiative() -> void:
	resource.pass_initiative()
	
	for clock in clocks.get_children():
		clock._on_switch()
