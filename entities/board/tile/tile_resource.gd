class_name TileResource
extends Resource


var board: BoardResource
var piece: PieceResource
var pin_piece: PieceResource
var coord: Vector2i

var id: int
var current_state: FrameworkSettings.TileState = FrameworkSettings.TileState.NONE

var windrose_to_sequence: Dictionary


func _init(board_: BoardResource, coord_: Vector2i) -> void:
	board = board_
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
			is_sequence_end = !FrameworkSettings.check_is_tile_coord_is_valid(neighbour_coord)
			
			if !is_sequence_end:
				var next_tile = board.get_tile_based_on_coord(neighbour_coord)
				windrose_to_sequence[windrose_offset].append(next_tile)
	
func check_tile_on_same_axis(tile_: TileResource) -> bool:
	return coord.x == tile_.coord.x or coord.y == tile_.coord.y
	
func place_piece(piece_: PieceResource) -> void:
	if piece != null: return
	if piece_ == piece: return
	
	if piece_.tile != null:
		piece_.tile.piece = null
	
	piece = piece_
	piece.tile = self
	piece.unpin()
	
	if pin_piece != null:
		pin_piece.unpin()
	
func reset() -> void:
	piece = null
	pin_piece = null
	current_state = FrameworkSettings.TileState.NONE
