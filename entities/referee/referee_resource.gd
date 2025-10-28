class_name RefereeResource
extends Resource


var game: GameResource

var players: Array[PlayerResource]
var active_player: PlayerResource


func _init(game_: GameResource) -> void:
	game = game_
	
	init_players()
	
func init_players() -> void:
	for piece_color in FrameworkSettings.PIECE_COLORS:
		add_player(piece_color)
	
	active_player = players.front()
	
func add_player(piece_color_: FrameworkSettings.PieceColor) -> void:
	var player = PlayerResource.new(self, piece_color_)
	players.append(player)
	
func pass_initiative() -> void:
	var player_index = players.find(active_player)
	player_index = (player_index + 1) % players.size()
	active_player = players[player_index]
