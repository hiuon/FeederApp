from entities import Feeder, User, loadUsers, loadFeeders, syncFeeders

users = loadUsers()
feeders = loadFeeders()
syncFeeders(users, feeders)

def syncWithDB():
	global users
	global feeders
	users = loadUsers()
	feeders = loadFeeders()
	syncFeeders(users, feeders)
