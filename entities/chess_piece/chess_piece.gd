class_name ChessPiece
extends Sprite2D


var chess_board: ChessBoard
var resource: ChessPieceResource:
	set(value_):
		resource = value_
		type = resource.get_type()
		color = resource.get_color()
		position = Vector2(resource.chess_tile.coord) * FrameworkSettings.TILE_SIZE
@export_enum("pawn", "king", "queen", "rook", "bishop", "knight") var type = "pawn":
	set(value_):
		type = value_
		
		if color != null:
			texture = load("res://entities/chess_piece/images/" + color + "_" + type + ".png")
@export_enum("black", "white") var color = "white":
	set(value_):
		color = value_
		
		if type != null:
			texture = load("res://entities/chess_piece/images/" + color + "_" + type + ".png")

var is_holden: bool:
	set(value_):
		is_holden = value_
		
		if is_holden:
			z_index = 1
		else:
			z_index = 0


func _process(_delta: float) -> void:
	if is_holden:
		global_position = get_global_mouse_position()
	
func place_on_chess_tile(chess_tile_: ChessTile) -> void:
	if resource.chess_tile != null:
		resource.chess_tile.chess_piece = null
	
	var chess_move_resource = resource.get_chess_move(chess_tile_.resource)
	
	if chess_move_resource != null:
		chess_board.resource.chess_notation.record_chess_move(chess_move_resource)
		chess_board.notation.add_move(chess_move_resource)
	
	is_holden = false
	global_position = chess_tile_.global_position
	chess_tile_.resource.place_chess_piece(resource)
	
	chess_board.reset_focus_chess_tile()
	chess_board.resource.focus_chess_tile = null
	
func capture() -> void:
	chess_board.resource.capture_chess_piece(resource)
	#visible = false
	chess_board.chess_pieces.remove_child(self)
	queue_free()
