from entities import Feeder, User, loadUsers, loadFeeders, syncFeeders
from time import sleep
import random

users = loadUsers()
feeders = loadFeeders()
syncFeeders(users, feeders)

eatValue = 2
userId = 3
feederId = 4

while True:
	for user in users:
		if (user.getUserId() == userId):
			user.getFeederById(feederId).eat(eatValue)
	
	
	
	#for user in users:
	#	for feeder in user.getAllUserFeeders():
	#		if random.random()>0.5:
	#			feeder.eat(eatValue)
	print("eat...\n")
	sleep(17)
