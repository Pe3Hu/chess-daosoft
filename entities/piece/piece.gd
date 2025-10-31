class_name Piece
extends Sprite2D


var board: Board
var resource: PieceResource:
	set(value_):
		resource = value_
		
		update_sprite()
		position = Vector2(resource.tile.coord) * FrameworkSettings.TILE_SIZE

@export_enum("pawn", "king", "queen", "rook", "bishop", "knight") var type = "pawn":
	set(value_):
		type = value_
		
		if color != null:
			texture = load("res://entities/piece/images/" + color + "_" + type + ".png")
@export_enum("black", "white") var color = "white":
	set(value_):
		color = value_
		
		if type != null:
			texture = load("res://entities/piece/images/" + color + "_" + type + ".png")

var is_holden: bool:
	set(value_):
		is_holden = value_
		
		if is_holden:
			z_index = 1
		else:
			z_index = 0


func update_sprite() -> void:
	type = resource.get_type()
	color = resource.get_color()
	
func _process(_delta: float) -> void:
	if is_holden:
		global_position = get_global_mouse_position()
	
func place_on_tile(tile_: Tile) -> void:
	if resource.tile != null:
		resource.tile.piece = null
	
	var move_resource = resource.get_move(tile_.resource)
	var is_passing_initiative = move_resource != null
	
	if move_resource != null:
		if resource.is_inactive:
			resource.is_inactive = false
		
		#ignoring rook move after king castling
		is_passing_initiative = board.game.resource.notation.record_move(move_resource)
		
		match move_resource.type:
			FrameworkSettings.MoveType.CAPTURE:
				var piece = board.resource_to_piece[move_resource.captured_piece] 
				piece.capture()
			FrameworkSettings.MoveType.PASSANT:
				var piece = board.resource_to_piece[move_resource.captured_piece] 
				piece.capture()
			FrameworkSettings.MoveType.PROMOTION:
				move_resource.pawn_promotion()
				promotion()
			FrameworkSettings.MoveType.CASTLING:
				complement_castling_move()
	
	is_holden = false
	global_position = tile_.global_position
	tile_.resource.place_piece(resource)
	
	#recalculation of moves after castling is completed
	#if !is_not_castling_move:
	#	resource.player.opponent.generate_legal_moves()
	
	board.reset_focus_tile()
	board.resource.focus_tile = null
	
	if is_passing_initiative:
		board.game.notation.add_move(move_resource)
		board.game.referee.pass_initiative()
	
func capture() -> void:
	board.resource.capture_piece(resource)
	board.pieces.remove_child(self)
	queue_free()
	
func promotion() -> void:
	update_sprite()
	
func complement_castling_move() -> void:
	var move_resource = board.game.resource.notation.moves.back()
	var rook_piece = board.resource_to_piece[move_resource.castling_rook]
	var rook_direction = Vector2(rook_piece.resource.tile.coord - resource.tile.coord).normalized()
	var next_root_tile_coord = resource.tile.coord + Vector2i(rook_direction)
	var next_root_tile_id = FrameworkSettings.BOARD_SIZE.x * next_root_tile_coord.y + next_root_tile_coord.x
	var next_root_tile_resource = board.resource.tiles[next_root_tile_id]
	var next_root_tile = board.get_tile(next_root_tile_resource)
	rook_piece.place_on_tile(next_root_tile)
