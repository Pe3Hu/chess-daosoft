class_name Clock
extends PanelContainer


signal switch

@export var referee: Referee

var resource: ClockResource:
	set(value_):
		resource = value_
		
		if resource.player.color == FrameworkSettings.PieceColor.WHITE:
			%ColorRect.color = Color.GHOST_WHITE
		else:
			%ColorRect.color = Color.BLACK

@onready var tick_timer: Timer = %TickTimer


func _on_tick_timer_timeout() -> void:
	resource.seconds -= 1
	update_label()
	
func update_label() -> void:
	var minutes = str(resource.minutes)
	var seconds = str(resource.seconds)
	
	if resource.seconds < 10:
		seconds = "0" + seconds
	
	%Time.text = minutes + ":" + seconds
	
	if resource.minutes == 0 and resource.seconds == 0:
		referee.resource.winner_player = resource.player.opponent
		referee.check_gameover()
	
func _on_switch() -> void:
	if tick_timer.is_stopped():
		tick_timer.start()
	else:
		tick_timer.stop()
