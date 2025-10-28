class_name Clock
extends PanelContainer


signal switch

var resource: ClockResource:
	set(value_):
		resource = value_
		
		if resource.player.color == FrameworkSettings.PieceColor.WHITE:
			%ColorRect.color = Color.GHOST_WHITE
		else:
			%ColorRect.color = Color.BLACK


func _on_tick_timer_timeout() -> void:
	resource.seconds -= 1
	var minutes = str(resource.minutes)
	var seconds = str(resource.seconds)
	
	if resource.seconds < 10:
		seconds = "0" + seconds
	
	%Time.text = minutes + ":" + seconds


func _on_switch() -> void:
	if %TickTimer.is_stopped():
		%TickTimer.start()
	else:
		%TickTimer.stop()
