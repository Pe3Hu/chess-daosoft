class_name ChessTileResource
extends Resource


var chess_board: ChessBoardResource
var chess_piece: ChessPieceResource
var coord: Vector2i

var id: int
var current_state: FrameworkSettings.TileState = FrameworkSettings.TileState.NONE

var windrose_to_sequence: Dictionary


func _init(chess_board_: ChessBoardResource, coord_: Vector2i) -> void:
	chess_board = chess_board_
	coord = coord_
	id = FrameworkSettings.BOARD_SIZE.x * coord_.y + coord_.x
	
func find_all_sequences() -> void:
	for _i in FrameworkSettings.WINDROSE_OFFSETS.size():
		var windrose_offset = FrameworkSettings.WINDROSE_OFFSETS[_i]
		var windrose_dirction = FrameworkSettings.WINDROSE_DIRECTIONS[_i]
		windrose_to_sequence[windrose_offset] = []
		var neighbour_coord = Vector2i(coord)
		var is_sequence_end = false
		
		while !is_sequence_end:
			neighbour_coord += windrose_dirction
			is_sequence_end = !FrameworkSettings.check_is_chess_tile_coord_is_valid(neighbour_coord)
			
			if !is_sequence_end:
				var next_chess_tile = chess_board.get_tile_based_on_coord(neighbour_coord)
				windrose_to_sequence[windrose_offset].append(next_chess_tile)
	
func check_chess_tile_on_same_axis(chess_tile_: ChessTileResource) -> bool:
	return coord.x == chess_tile_.coord.x or coord.y == chess_tile_.coord.y
	
func place_chess_piece(chess_piece_: ChessPieceResource) -> void:
	if chess_piece != null: return
	
	chess_piece = chess_piece_
	chess_piece.chess_tile = self
