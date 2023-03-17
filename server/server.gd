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
	await get_tree().create_timer(1).timeout
	populate_world(id)
	
func _client_disconnected(id):
	print('Client ' + str(id) + ' disconnected ')
	if players.has(id):
		players[id]["node"].queue_free()
		players.erase(id)
#		rpc("remove_player", id)
		rpc("playerCountChanged", players.size())

@rpc("any_peer") 
func populate_world(id):
	rpc_id(id, "setAnnouncement", announcement)
	setCollision(collisionActive)
	
var playerClass = preload("res://player.tscn")
	
@rpc("any_peer")
func registerClient(clientName):
	var id = multiplayer.get_remote_sender_id()
	var newClient = playerClass.instantiate()
	newClient.name = str(id)
	players[id] = {
		"name": clientName,
		"node": newClient,
	}
	get_node("/root/root/network").add_child(newClient)
	
@rpc("any_peer") 
func setAnnouncement(txt):
	announcement = txt
	for pid in players:
		rpc_id(pid, "setAnnouncement", announcement)
	
@rpc("any_peer", "call_local") 
func spawnBullet(pos, flip):
	for pid in players:
		rpc_id(pid, "spawnBullet", pos, flip)
	
@rpc("any_peer") 
func setCollision(active):
	collisionActive = active
	var id = multiplayer.get_remote_sender_id()
	for pid in players:
		if id != pid:
			rpc_id(pid, "setCollision", collisionActive)
			players[pid].node.setCollision(active)
	
@rpc("any_peer") 
func connected():
	pass

@rpc("any_peer") 
func playerCountChanged(playerCountChange):
	pass
	
@rpc("any_peer") 
func activeBaseCountChanged(activeOnBase):
	pass

func _on_points_active_base_count_changed(activeBaseCount):
	rpc("activeBaseCountChanged", activeBaseCount)

func _on_points_base_active_state_changed(_nr, _active):
	pass
