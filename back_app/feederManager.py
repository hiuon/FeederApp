from entities import Feeder, User, loadUsers, loadFeeders, syncFeeders
from time import sleep
import utilities
from utilities import needToFeed

users = loadUsers()
feeders = loadFeeders()
syncFeeders(users, feeders)

feedValue = 5
k = 0

while True:
	for user in users:
		for feeder in user.getAllUserFeeders():
			if needToFeed(feeder.getTimeTable(), k):
				feeder.feed(feedValue)
	if k<7:
		k+=1
	else:
		k=0
	sleep(7.5)
