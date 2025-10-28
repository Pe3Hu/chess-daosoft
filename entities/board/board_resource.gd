class_name BoardResource
extends Resource


var game: GameResource
var tiles: Array[TileResource]
var legal_tiles: Array[TileResource]
var focus_tile: TileResource:
	set(value_):
		reset_tile_states()
		focus_tile = value_
		
		if focus_tile != null:
			update_tile_states()

var pieces: Array[PieceResource]
var captured_templates: Dictionary


var buttom_color: FrameworkSettings.PieceColor = FrameworkSettings.PieceColor.BLACK


func _init(game_: GameResource) -> void:
	game = game_
	init_tiles()
	#add_piece(FrameworkSettings.PieceColor.BLACK | FrameworkSettings.PieceType.BISHOP, 25)
	#focus_tile = tiles[25]
	load_position_from_fen(FrameworkSettings.START_FEN)
	
func init_tiles() -> void:
	for file in FrameworkSettings.BOARD_SIZE.y:
		for rank in FrameworkSettings.BOARD_SIZE.x:
			var coord = Vector2i(rank, file)
			add_tile(coord)
	
	for tile in tiles:
		tile.find_all_sequences()
	
func get_tile_based_on_coord(coord_: Vector2i) -> Variant:
	if FrameworkSettings.check_is_tile_coord_is_valid(coord_):
		var id = coord_.y * FrameworkSettings.BOARD_SIZE.x + coord_.x
		return tiles[id]
	
	return null
	
func add_tile(coord_: Vector2i) -> void:
	var tile = TileResource.new(self, coord_)
	tiles.append(tile)
	
func load_position_from_fen(fen_: String) -> void:
	var fen_board: String = fen_.split(' ')[0]
	var file: int = 0
	var rank: int = 7
	
	for symbol in fen_board:
		if symbol == "/":
			file = 0
			rank -= 1
		else:
			if symbol.is_valid_int():
				file += int(symbol)
			else:
				var piece_color = FrameworkSettings.PieceColor.BLACK
				var is_white = symbol.capitalize() == symbol
				if is_white:
					piece_color = FrameworkSettings.PieceColor.WHITE
				
				var piece_type =  FrameworkSettings.symbol_to_type[symbol.to_lower()]
				var tile_index = rank * FrameworkSettings.BOARD_SIZE.x + file
				var template_id = piece_type | piece_color
				add_piece(template_id, tile_index)
				file += 1
	
func add_piece(template_id_: int, tile_index_: int,) -> void:
	var template = load("res://entities/piece/templates/" + str(template_id_) + ".tres")
	var tile = tiles[tile_index_]
	var piece = PieceResource.new(self, template, tile)
	pieces.append(piece)
	
func update_tile_states() -> void:
	focus_tile.current_state = FrameworkSettings.TileState.CURRENT
	focus_tile.piece.geterate_legal_moves()
	
	for move in focus_tile.piece.moves:
		move.end_tile.current_state = FrameworkSettings.TileState.NEXT
		legal_tiles.append(move.end_tile)
	
func reset_tile_states() -> void:
	if focus_tile == null: return
	focus_tile.current_state = FrameworkSettings.TileState.NONE
	
	for legal_tile in legal_tiles:
		legal_tile.current_state = FrameworkSettings.TileState.NEXT
	
	legal_tiles.clear()
	
func capture_piece(piece_: PieceResource) -> void:
	if !captured_templates.has(piece_.template):
		captured_templates[piece_] = 0
	
	captured_templates[piece_] += 1
	piece_.tile.piece = null
	pieces.erase(piece_)
