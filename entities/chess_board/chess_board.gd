class_name ChessBoard
extends TileMapLayer


@export var chess_tile_scene: PackedScene
@export var chess_piece_scene: PackedScene
@export var resource: ChessBoardResource = ChessBoardResource.new()

@onready var chess_tiles: Node2D = $ChessTiles
@onready var chess_pieces: Node2D = $ChessPieces

var resource_to_chess_piece: Dictionary


func _ready() -> void:
	position = -Vector2(FrameworkSettings.BOARD_SIZE) * FrameworkSettings.TILE_SIZE / 2
	init_chess_tiles()
	init_pieces()
	
func init_chess_tiles() -> void:
	chess_tiles.position = FrameworkSettings.TILE_SIZE * 0.5
	
	#for file in FrameworkSettings.BOARD_SIZE.y:
		#for rank in FrameworkSettings.BOARD_SIZE.x:
			#var coord = Vector2i(rank, file)
			#add_chess_tile(coord)
	
	for chess_tile_resource in resource.chess_tiles:
		add_chess_tile(chess_tile_resource)
	
#func add_chess_tile(coord_: Vector2i) -> void:
func add_chess_tile(chess_tile_resource_: ChessTileResource) -> void:
	var chess_tile = chess_tile_scene.instantiate()
	chess_tile.chess_board = self
	chess_tile.resource = chess_tile_resource_
	chess_tiles.add_child(chess_tile)
	
func get_chess_tile(chess_tile_resource_: ChessTileResource) -> ChessTile:
	return chess_tiles.get_child(chess_tile_resource_.id)
	
func init_pieces() -> void:
	chess_pieces.position = FrameworkSettings.TILE_SIZE * 0.5
	
	for coord in resource.coord_to_chess_piece:
		var chess_piecepiece_resource = resource.coord_to_chess_piece[coord]
		add_piece(chess_piecepiece_resource)
	
func add_piece(chess_piece_resource_: ChessPieceResource) -> void:
	var chess_piece = chess_piece_scene.instantiate()
	chess_piece.chess_board = self
	chess_piece.resource = chess_piece_resource_
	chess_pieces.add_child(chess_piece)
	resource_to_chess_piece[chess_piece_resource_] = chess_piece
	
func get_piece(chess_piece_resource_: ChessPieceResource) -> ChessPiece:
	return resource_to_chess_piece[chess_piece_resource_]
	
func hold_piece_on_chess_tile(chess_tile_: ChessTile) -> void:
	reset_focus_chess_tile()
	resource.focus_chess_tile = chess_tile_.resource
	update_focus_chess_tile()
	hold_piece()
	
func reset_focus_chess_tile() -> void:
	var previous_active_chess_tile_resources = []
	
	if resource.focus_chess_tile != null:
		previous_active_chess_tile_resources.append(resource.focus_chess_tile)
		previous_active_chess_tile_resources.append_array(resource.legal_chess_tiles)
	
	for chess_tile_resource in previous_active_chess_tile_resources:
		var chess_tile = chess_tiles.get_child(chess_tile_resource.id)
		chess_tile.update_modulate(FrameworkSettings.TileState.NONE)
	
func update_focus_chess_tile() -> void:
	var focust_chess_tile = chess_tiles.get_child(resource.focus_chess_tile.id)
	focust_chess_tile.update_state()
	
	for chess_tile_resource in resource.legal_chess_tiles:
		var chess_tile = chess_tiles.get_child(chess_tile_resource.id)
		chess_tile.update_state()
	
func hold_piece() -> void:
	var chess_piece = resource_to_chess_piece[resource.focus_chess_tile.chess_piece]
	chess_piece.is_holden = true
