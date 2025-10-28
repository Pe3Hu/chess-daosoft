class_name PlayerResource
extends Resource


var color: FrameworkSettings.PieceColor
var referee: RefereeResource
var clock: ClockResource = ClockResource.new(self)


func _init(referee_: RefereeResource, color_: FrameworkSettings.PieceColor) -> void:
	referee = referee_
	color = color_ 
