class_name Board
extends PanelContainer


@export var tile_scene: PackedScene
@export var piece_scene: PackedScene

@export var game: Game
var resource: BoardResource:
	set(value_):
		resource = value_
		
		position = FrameworkSettings.TILE_SIZE * 0.5 + FrameworkSettings.AXIS_OFFSET
		init_tiles()
		init_pieces()

@onready var map_layer: TileMapLayer = %BoardMapLayer
@onready var tiles: Node2D = %Tiles
@onready var pieces: Node2D = %Pieces

var resource_to_piece: Dictionary


func _ready() -> void:
	map_layer.position = FrameworkSettings.TILE_SIZE * 0.5
	
func init_tiles() -> void:
	for tile_resource in resource.tiles:
		add_tile(tile_resource)
	
	if resource.altar_tile != null:
		var altar_tile = get_tile(resource.altar_tile)
		altar_tile.update_state()
	
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
	
func get_piece(piece_resource_: PieceResource) -> Variant:
	if resource_to_piece.has(piece_resource_): return resource_to_piece[piece_resource_]
	return null
	
func hold_piece_on_tile(tile_: Tile) -> void:
	reset_focus_tile()
	resource.focus_tile = tile_.resource
	update_focus_tile()
	hold_piece()
	
func reset_focus_tile() -> void:
	if game.resource.current_mod == FrameworkSettings.ModeType.FOX and game.on_pause: return
	var previous_active_tile_resources = []
	
	if resource.focus_tile != null:
		previous_active_tile_resources.append(resource.focus_tile)
		previous_active_tile_resources.append_array(resource.legal_tiles)
	
	for tile_resource in previous_active_tile_resources:
		var tile = tiles.get_child(tile_resource.id)
		tile.update_modulate(FrameworkSettings.TileState.NONE)
	
	update_tile_threat_state()
	
	match game.resource.current_mod:
		FrameworkSettings.ModeType.GAMBIT:
			var altar_tile = get_tile(resource.altar_tile)
			altar_tile.resource.current_state = FrameworkSettings.TileState.AlTAR
			altar_tile.update_state()
	
func update_focus_tile() -> void:
	if game.resource.current_mod == FrameworkSettings.ModeType.FOX and game.on_pause: return
	var focust_tile = tiles.get_child(resource.focus_tile.id)
	focust_tile.update_state()
	
	for tile_resource in resource.legal_tiles:
		var tile = tiles.get_child(tile_resource.id)
		tile.update_state()
	
func hold_piece() -> void:
	var piece = get_piece(resource.focus_tile.piece)
	piece.is_holden = true
	game.cursor.current_state = FrameworkSettings.CursorState.HOLD
	
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
	resource_to_piece = {}
	resource.reset()
	
	for tile in tiles.get_children():
		tile.update_state()
	
	init_pieces()
	initial_tile_state_update()
	game.resource.before_first_move()
	
func fox_mod_tile_state_update() -> void:
	if game.referee.resource.fox_swap_players.is_empty():
		game.fox_swap_pieces_finished.emit()
		return
	
	var player = game.referee.resource.fox_swap_players.front()
	
	if player.is_bot:
		fox_random_swap()
	else:
		for piece in player.fox_swap_pieces:
			var tile = get_tile(piece.tile)
			tile.update_state()
	
func fox_swap(piece_for_swap_: Piece) -> void:
	var focus_piece = get_piece(resource.focus_tile.piece)
	var focus_tile = get_tile(resource.focus_tile)
	var swap_tile = get_tile(piece_for_swap_.resource.tile)
	var temp_tile = get_free_tile()
	piece_for_swap_.place_on_tile(temp_tile)
	focus_piece.place_on_tile(swap_tile)
	piece_for_swap_.place_on_tile(focus_tile)
	
	reset_tile_state_after_swap()
	fox_mod_tile_state_update()
	piece_for_swap_.is_holden = false
	
func fox_random_swap() -> void:
	var player = game.referee.resource.fox_swap_players.front()
	player.fox_swap_pieces.shuffle()
	var random_focus_resource = player.fox_swap_pieces.pop_back()
	var random_swap_resource = player.fox_swap_pieces.pop_back()
	resource.focus_tile = random_focus_resource.tile
	var swap_piece = get_piece(random_swap_resource)
	fox_swap(swap_piece)
	
func reset_tile_state_after_swap() -> void:
	var player = game.referee.resource.fox_swap_players.pop_front()
	for piece in player.fox_swap_pieces:
		var tile = get_tile(piece.tile)
		tile.resource.current_state = FrameworkSettings.TileState.NONE
		tile.update_state()
	
func get_free_tile() -> Tile:
	var tile_index = 17
	var option_tile = tiles.get_child(tile_index)
	
	while option_tile.resource.piece != null:
		tile_index += 1
		option_tile = tiles.get_child(tile_index)
	
	return option_tile
	
func resize() -> void:
	custom_minimum_size = Vector2(FrameworkSettings.BOARD_SIZE) * FrameworkSettings.TILE_SIZE
	resource.resize()
	resource_to_piece = {}
	
	remove_tiles()
	remove_pieces()
	
	init_tiles()
	init_pieces()
	
func remove_tiles() -> void:
	while tiles.get_child_count() > 0:
		var tile = tiles.get_child(0)
		tiles.remove_child(tile)
		tile.queue_free()
	
func remove_pieces() -> void:
	while pieces.get_child_count() > 0:
		var piece = pieces.get_child(0)
		pieces.remove_child(piece)
		piece.queue_free()
	
func _on_mouse_entered() -> void:
	game.cursor.current_state = FrameworkSettings.CursorState.SELECT
	
func _on_mouse_exited() -> void:
	game.cursor.current_state = FrameworkSettings.CursorState.IDLE
