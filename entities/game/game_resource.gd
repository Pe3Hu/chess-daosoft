class_name GameResource
extends Resource


var board: BoardResource = BoardResource.new(self)
var notation: NotationResource = NotationResource.new(self)
var referee: RefereeResource = RefereeResource.new(self)
var players: Array[PlayerResource]
