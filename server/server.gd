extends Node

var players = {}
var announcement = "asdf"
var collisionActive = true
var server = WebSocketServer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var port = int(OS.get_environment("PORT"))
	var max_players = int(OS.get_environment("MAX_PLAYERS"))
	if port == 0:
		port = 5000
	if max_players == 0:
		max_players = 10
		
	print('starting server on port...', port, 'with max players: ', max_players)
	server.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(server)
	get_tree().connect("network_peer_connected",    self, "_client_connected"   )
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")


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

remote func populate_world(id):
	# Spawn all current players on new client
	rpc_id(id, "setAnnouncement", announcement)
	for pid in players:
		rpc_id(id, "spawn_player", pid, players[pid].name)
	setCollision(collisionActive)
	
remote func registerClient(name):
	var id = get_tree().get_rpc_sender_id()
	var newClient = preload("res://player.tscn").instance()
	newClient.set_name(str(id))     # spawn players with their respective names
	players[id] = {
		"name": name,
		"node": newClient,
	}
	get_tree().get_root().add_child(newClient)
	rpc_id(id, "connected")
	rpc_id(id, "setCollision", collisionActive)
	rpc("playerCountChanged", players.size())
	rpc("spawn_player", id, name)
	
	
remote func setAnnouncement(txt):
	announcement = txt
	for pid in players:
		rpc_unreliable_id(pid, "setAnnouncement", announcement)
	
remote func setCollision(active):
	collisionActive = active
	var id = get_tree().get_rpc_sender_id()
	for pid in players:
		if id != pid:
			rpc_id(pid, "setCollision", collisionActive)
			players[pid].node.setCollision(active)
	
func _process(delta):
	if server.is_listening(): # is_listening is true when the server is active and listening
		server.poll()


func _on_points_active_base_count_changed(activeBaseCount):
	rpc("activeBaseCountChanged", activeBaseCount)


func _on_points_base_active_state_changed(nr, active):
	pass
