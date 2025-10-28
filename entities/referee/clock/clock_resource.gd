class_name ClockResource
extends Resource


var player: PlayerResource

var minutes: int = 5:
	set(value_):
		minutes = value_
var seconds: int = 0:
	set(value_):
		seconds = value_
		
		if seconds > 60:
			var plus_minutes = floor(seconds / 60)
			minutes += plus_minutes
			seconds -= plus_minutes * 60
		if seconds < 0:
			seconds += 60
			minutes -= 1


func _init(player_: PlayerResource) -> void:
	player = player_
