class_name Board
extends TileMapLayer


@export var tile_scene: PackedScene
@export var piece_scene: PackedScene

@export var game: Game
var resource: Resource:
	set(value_):
		resource = value_
		
		position = FrameworkSettings.TILE_SIZE * 0.5 + FrameworkSettings.AXIS_OFFSET
		init_tiles()
		init_pieces()

@onready var tiles: Node2D = $Tiles
@onready var pieces: Node2D = $Pieces

var resource_to_piece: Dictionary


func init_tiles() -> void:
	for tile_resource in resource.tiles:
		add_tile(tile_resource)
	
func add_tile(tile_resource_: TileResource) -> void:
	var tile = tile_scene.instantiate()
	tile.board = self
	tile.resource = tile_resource_
	tiles.add_child(tile)
	
func get_tile(tile_resource_: TileResource) -> Tile:
	return tiles.get_child(tile_resource_.id)
	
func init_pieces() -> void:
	while pieces.get_child_count() > 0:
		var piece = pieces.get_child(0)
		pieces.remove_child(piece)
		piece.queue_free()
	
	for piece_resource in resource.pieces:
		add_piece(piece_resource)
	
func add_piece(piece_resource_: PieceResource) -> void:
	var piece = piece_scene.instantiate()
	piece.board = self
	piece.resource = piece_resource_
	pieces.add_child(piece)
	resource_to_piece[piece_resource_] = piece
	
func get_piece(piece_resource_: PieceResource) -> Piece:
	return resource_to_piece[piece_resource_]
	
func hold_piece_on_tile(tile_: Tile) -> void:
	reset_focus_tile()
	resource.focus_tile = tile_.resource
	update_focus_tile()
	hold_piece()
	
func reset_focus_tile() -> void:
	var previous_active_tile_resources = []
	
	if resource.focus_tile != null:
		previous_active_tile_resources.append(resource.focus_tile)
		previous_active_tile_resources.append_array(resource.legal_tiles)
	
	for tile_resource in previous_active_tile_resources:
		var tile = tiles.get_child(tile_resource.id)
		tile.update_modulate(FrameworkSettings.TileState.NONE)
	
	update_tile_threat_state()
	
func update_focus_tile() -> void:
	var focust_tile = tiles.get_child(resource.focus_tile.id)
	focust_tile.update_state()
	
	for tile_resource in resource.legal_tiles:
		var tile = tiles.get_child(tile_resource.id)
		tile.update_state()
	
func hold_piece() -> void:
	var piece = resource_to_piece[resource.focus_tile.piece]
	piece.is_holden = true
	
func initial_tile_state_update() -> void:
	update_tile_threat_state()
	
func update_tile_threat_state() -> void:
	for move in resource.game.referee.active_player.opponent.capture_moves:
		var tile = tiles.get_child(move.end_tile.id)
		tile.update_modulate(FrameworkSettings.TileState.CAPTURE)
	
	for move in resource.game.referee.active_player.opponent.pin_moves:
		var tile = tiles.get_child(move.end_tile.id)
		tile.update_modulate(FrameworkSettings.TileState.PIN)
	
	for tile_resource in resource.game.referee.active_player.opponent.check_tiles:
		var tile = tiles.get_child(tile_resource.id)
		tile.update_modulate(FrameworkSettings.TileState.CHECK)
	
func reset_initiative_tile() -> void:
	for move in resource.game.referee.active_player.opponent.capture_moves:
		var tile = tiles.get_child(move.end_tile.id)
		tile.update_modulate(FrameworkSettings.TileState.NONE)
	
	for move in resource.game.referee.active_player.opponent.pin_moves:
		var tile = tiles.get_child(move.end_tile.id)
		tile.update_modulate(FrameworkSettings.TileState.NONE)
	
	for tile_resource in resource.game.referee.active_player.opponent.check_tiles:
		var tile = tiles.get_child(tile_resource.id)
		tile.update_modulate(FrameworkSettings.TileState.NONE)
	
func apply_move(move_resource_: MoveResource) -> void:
	if move_resource_.captured_piece != null:
		var captured_piece = get_piece(move_resource_.captured_piece)
		captured_piece.capture()
	
	var piece = get_piece(move_resource_.piece)
	var tile = get_tile(move_resource_.end_tile)
	piece.place_on_tile(tile)
	
func reset() -> void:
	resource.reset()
	
	for tile in tiles.get_children():
		tile.update_state()
	
	init_pieces()
	initial_tile_state_update()
	game.resource.before_first_move()
