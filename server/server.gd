extends Node

var players = {}
var announcement = "idkfa"
var collisionActive = true
var server = WebSocketMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var port = int(OS.get_environment("PORT"))
	var max_players = int(OS.get_environment("MAX_PLAYERS"))
	if port == 0:
		port = 5000
	if max_players == 0:
		max_players = 10
		
	print('starting server on port...', port, 'with max players: ', max_players)
	server.create_server(port)
	multiplayer.multiplayer_peer = server
	
	server.peer_connected.connect(Callable(self,"_client_connected"))
	server.peer_disconnected.connect(Callable(self,"_client_disconnected"))


func _client_connected(id):
	print('Client ' + str(id) + ' connected to Server')
	populate_world(id)
	
func _client_disconnected(id):
	print('Client ' + str(id) + ' disconnected ')
	if players.has(id):
		players[id]["node"].queue_free()
		players.erase(id)
		rpc("remove_player", id)
		rpc("playerCountChanged", players.size())

@rpc("any_peer") 
func populate_world(id):
	# Spawn all current players on new client
	rpc_id(id, "setAnnouncement", announcement)
	for pid in players:
		rpc_id(id, "spawn_player", pid, players[pid].name)
	setCollision(collisionActive)
	
@rpc("any_peer")
func registerClient(clientName):
	var id = get_tree().get_remote_sender_id()
	var newClient = preload("res://player.tscn").instantiate()
	newClient.set_name(str(id))     # spawn players with their respective names
	players[id] = {
		"name": clientName,
		"node": newClient,
	}
	get_tree().get_root().add_child(newClient)
	rpc_id(id, "connected")
	rpc_id(id, "setCollision", collisionActive)
	rpc("playerCountChanged", players.size())
	rpc("spawn_player", id, clientName)
	
	
@rpc("any_peer") 
func setAnnouncement(txt):
	announcement = txt
	for pid in players:
		rpc_id(pid, "setAnnouncement", announcement)
	
@rpc("any_peer") 
func spawnBullet(pos, flip):
	for pid in players:
		rpc_id(pid, "spawn_bullet", pos, flip)
	
@rpc("any_peer") 
func setCollision(active):
	collisionActive = active
	var id = multiplayer.get_remote_sender_id()
	for pid in players:
		if id != pid:
			rpc_id(pid, "setCollision", collisionActive)
			players[pid].node.setCollision(active)
	
#func _process(delta):
#	if server.is_listening(): # is_listening is true when the server is active and listening
#		server.poll()


func _on_points_active_base_count_changed(activeBaseCount):
	rpc("activeBaseCountChanged", activeBaseCount)


func _on_points_base_active_state_changed(_nr, _active):
	pass
