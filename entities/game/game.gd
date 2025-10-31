class_name Game
extends PanelContainer


var resource: GameResource = GameResource.new()

@onready var board = %Board
@onready var referee = %Referee
@onready var notation = %Notation
@onready var menu = %Menu
@onready var checkmate_panel = %CheckmatePanel
@onready var checkmate_label = %CheckmateLabel

var on_pause: bool = true


func _ready() -> void:
	board.resource = resource.board
	referee.resource = resource.referee
	notation.resource = resource.notation
	
	board.initial_tile_state_update()
	menu.start_game()
	
func end() -> void:
	menu.mods.visible = true
	menu.start_game_button.visible = true
	referee.visible = false
	var notification_text = ""
	
	match referee.resource.winner_player.color:
		FrameworkSettings.PieceColor.BLACK:
			notification_text = "Black"
		FrameworkSettings.PieceColor.WHITE:
			notification_text = "White"
	
	notification_text += " is winner"
	checkmate_panel.visible = true
	checkmate_label.text = notification_text
	
	for clock in referee.clocks.get_children():
		clock.tick_timer.stop()
	
func reset() -> void:
	referee.reset()
	notation.reset()
	board.reset()
	
