class_name RefereeResource
extends Resource


var game: GameResource

var players: Array[PlayerResource]
var fox_swap_players: Array[PlayerResource]
var color_to_player: Dictionary

var active_player: PlayerResource
var winner_player: PlayerResource = null

var is_spy_action: bool = false


func _init(game_: GameResource) -> void:
	game = game_
	
	init_players()
	
func init_players() -> void:
	for piece_color in FrameworkSettings.PIECE_COLORS:
		add_player(piece_color)
	
	active_player = players.front()
	
	for _i in players.size():
		var _j = (_i + 1) % players.size()
		players[_i].opponent = players[_j]
	
func add_player(piece_color_: FrameworkSettings.PieceColor) -> void:
	var player = PlayerResource.new(self, piece_color_)
	players.append(player)
	color_to_player[piece_color_] = player
	
func pass_initiative() -> void:
	if active_player.hellhorse_bonus_move: return
	if active_player.spy_bonus_move: return
	#if is_spy_action: return
	for player in players:
		player.unfresh_all_pieces()
	
	active_player.find_threat_moves()
	var player_index = players.find(active_player)
	player_index = (player_index + 1) % players.size()
	active_player = players[player_index]
	active_player.generate_legal_moves()
	
func reset() -> void:
	for player in players:
		player.reset()
	
	active_player = players.front()
	winner_player = null

func get_tile_after_slide() -> TileResource:
	var end_of_slide_tile = active_player.opponent.spy_move.end_tile
	if !FrameworkSettings.SLIDE_PIECES.has(active_player.opponent.spy_move.piece.template.type): return end_of_slide_tile

	var slide_direction = active_player.opponent.spy_move.end_tile.coord - active_player.opponent.spy_move.start_tile.coord
	slide_direction = Vector2i(Vector2(slide_direction).normalized())
	var windrose_offset = FrameworkSettings.get_windrose_offset(slide_direction)
	
	end_of_slide_tile =  active_player.opponent.spy_move.start_tile
	
	while active_player.opponent.spy_move.end_tile != end_of_slide_tile:
		end_of_slide_tile = end_of_slide_tile.windrose_to_sequence[windrose_offset].front()
		if end_of_slide_tile.piece != null:
			return end_of_slide_tile
	
	return end_of_slide_tile
