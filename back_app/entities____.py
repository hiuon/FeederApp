# class LoggerInterface:
# 	def log(self):
# 		pass
# 		#open db:
# 		#close db
import psycopg2
from psycopg2 import sql

lastFeederId=0
lastUserId=0

class Feeder:
	feederId = 0
	labels = []
	userId = 0
	feederType = ''
	timeTable = 'no'
	capacity = 0
	filledInternally = 0
	filledExternally = 0

	def __init__(self, feederId):
		global lastFeederId
		self.feederId = lastFeederId
		lastFeederId +=1

	def __init__(self, values):
		global lastFeederId
		self.feederId = lastFeederId
		lastFeederId +=1
		self.labels = values["labels"]
		self.userId = values["userId"]
		self.feederType = values["feederType"]
		self.timeTable = values["timeTable"]
		self.capacity = values["capacity"]
		self.filledInternally = values["filledInternally"]
		self.filledExternally = values["filledExternally"]


	FEEDER_FEEDING_OK = 'FEEDER_FEEDING_OK'
	FEEDER_FEEDING_FAIL = 'FEEDER_FEEDING_FAIL'
	FEEDER_PING_OK = 'FEEDER_PING_OK'
	FEEDER_PING_FAIL = 'FEEDER_PING_FAIL'
	FEEDER_EATING_OK = 'FEEDER_EATING_OK'
	FEEDER_EATING_FAIL = 'FEEDER_EATING_FAIL'

	# Feeder()
	def setUserId(self, userId):
		self.userId = int(userId)
		self.updateInDB()

	def getUserId(self):
		return self.userId

	def feed(self, amount):
		if (self.filledInternally-amount>=0):
			self.filledInternally -= amount
			self.updateInDB()	
			log(self, 'I', FEEDER_FEEDING_OK)
		else:
			log(self, 'E', FEEDER_FEEDING_FAIL)

	def log(self, type, case):
		#open db
		print()
		#close db

	# def getCurrentState():
	# 	if(pingFeeder):
	# 		log(self, 'I', FEEDER_PING_OK)
	# 	else:
	# 		log(self, 'E', FEEDER_PING_FAIL)

	# def setTimeTable(self, newTimeTable):
	# 	timeTable = newTimeTable
	# 	self.updateInDB()
	# 	log(self, 'I', FEEDER_TIMETABLE_SET)

	# def addLabel(self, newLabel):
	# 	log(self, 'I', FEEDER_LABEL_ADDED)
	# 	labels.add(newLabel)
	# 	self.updateInDB()

	# def dropLabel(self, dropLabel):
	# 	log(self, 'I', FEEDER_LABEL_DROPPED)
	# 	self.updateInDB()
	# 	labels.drop(dropLabel)

	def eat(self, amount):
		if (filledExternally-amount<0):
			log(self, 'E', FEEDER_EATING_FAIL)
		else:
			log(self, 'I', FEEDER_EATING_OK)
			filledExternally -= amount

	def currentStateToDict(self):
		feeder = {
			'feederId': self.feederId,
			'labels': self.labels,
			'userId': self.userId,
			'feederType': self.feederType,
			'timeTable': self.timeTable,
			# 'timeTable': self.timeTable.value(),
			'capacity': self.capacity,
			'filledInternally': self.filledInternally,
			'filledExternally': self.filledExternally
		}
		return feeder

	def delete(self):
		print("FEEDER deleting")
		self.deleteInDB()
		if (self.feederId==lastFeederId):
			lastFeederId-=1

	def getFeederId(self):
		return self.feederId

	def set(self, values): 
		self.labels = values["labels"]
		self.userId = int(values["userId"])
		self.feederType = values["feederType"]
		self.timeTable = values["timeTable"]
		self.capacity = int(values["capacity"])
		self.filledInternally = int(values["filledInternally"])
		self.filledExternally = int(values["filledExternally"])

	def saveToDB(self):
		conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')
		cursor = conn.cursor()
		conn.autocommit = True
		columns = "feederid, labels, userid, feedertype, timetable, capacity, filledinternally, filledexternally"
		values = str(self.feederId)+", '"+str(self.labels)+"', "+str(self.userId)+", '"+str(self.feederType)+"', '"+str(self.timeTable)+"', "+str(self.capacity)+', '+str(self.filledInternally)+', '+str(self.filledExternally)
		cursor.execute(sql.SQL(
			'INSERT INTO feeders VALUES('+values+');')) 
		cursor.close()
		conn.close()

	def updateInDB(self):
		conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')
		cursor = conn.cursor()
		conn.autocommit = True
		values = "labels='"+str(self.labels)+"', userid="+str(self.userId)+", feedertype='"+str(self.feederType)+"', timetable='"+str(self.timeTable)+"', capacity="+str(self.capacity)+', filledInternally='+str(self.filledInternally)+', filledExternally='+str(self.filledExternally)
		cursor.execute(sql.SQL(
			'UPDATE feeders SET '+values+'WHERE feeders.feederid='+str(self.feederId)+';')) 
		cursor.close()
		conn.close()

	def deleteInDB(self):
		conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')
		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute(sql.SQL(
			'DELETE FROM feeders WHERE feeders.feederid='+str(self.feederId)+';')) 
		cursor.close()
		conn.close()

class User:
	userId = 0
	feeders = []
	timeTables = []
	name = ''

	def __init__(self):
		global lastUserId
		self.userId = lastUserId
		lastUserId+=1
		self.feeders = []
		self.timeTables = []
		self.name = ''

	def __init__(self, name, userId=0):
		global lastUserId
		self.userId = lastUserId
		lastUserId+=1
		self.feeders = []
		self.timeTables = []
		self.name = name

	# def addTimeTable(self, timeTable):
	# 	self.timeTables.append(timeTable)

	# def removeTimeTableById(self, timeTableId):
	# 	for timeTable in timeTables:
	# 		if (timeTable.getTimeTableId()==timeTableId):
	# 			self.timeTables.remove(timeTable)
	# 			timeTable.delete()
		
	def addFeeder(self, feeder):
		feeder.setUserId(self.userId)
		self.feeders.append(feeder)

	def removeFeederById(self, feederId):
		for feeder in self.feeders:
			if (feeder.getFeederId()==feederId):
				self.feeders.remove(feeder)
				feeder.delete()

	def listingView(self):
		return {
			"id": self.userId,
			"name": self.name
		}

	def feedersCurrentStateToList(self):
		return [feeder.currentStateToDict() for feeder in self.feeders]

	def timeTablesToList(self):
		# return [t.value() for t in self.timeTables]
		return [t for t in self.timeTables]

	def currentStateToDict(self):
		return {
			"id": self.userId,
			"name": self.name,
			"feeders": self.feedersCurrentStateToList(),
			"timeTables": self.timeTables
		}
	def getUserId(self):
		return self.userId

	def setName(self, name):
		self.name = name
		self.updateInDB()

	def deleteFeeders(self):
		for feeder in self.feeders:
			feeder.delete()

	def deleteTimeTables(self):
		for timeTable in self.timeTables:
			timeTable.delete()

	def delete(self):
		"""delete feeders"""
		global lastUserId
		self.deleteFeeders()
		# self.deleteTimeTables()
		self.deleteInDB()
		if (self.userId==lastUserId):
			lastUserId-=1

	def getFeederById(self, feederId):
		for f in self.feeders:
			if (f.getFeederId()==feederId):
				return f

	# def getTimeTableById(self, timeTableId):
	# 	for t in self.timeTables:
	# 		if (t.getTimeTableId()==timeTableId):
	# 			return t
	
	def saveToDB(self):
		# print("SAVING USER TO DB")
		conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')

		cursor = conn.cursor()
		conn.autocommit = True
		# cursor.execute('SELECT * FROM test_table WHERE id < 10 OR id > 5000;')
		cursor.execute(sql.SQL(
			'INSERT INTO users VALUES('+str(self.userId)+", '"+self.name+"');")) 
		cursor.close()
		conn.close()

	def updateInDB(self):
		conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')

		cursor = conn.cursor()
		conn.autocommit = True
		# cursor.execute('SELECT * FROM test_table WHERE id < 10 OR id > 5000;')
		cursor.execute(sql.SQL(
			"UPDATE users SET username = '"+self.name+"' WHERE users.userid="+str(self.userId)+";")) 
		cursor.close()
		conn.close()

	def deleteInDB(self):
		conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')

		cursor = conn.cursor()
		conn.autocommit = True
		# cursor.execute('SELECT * FROM test_table WHERE id < 10 OR id > 5000;')
		cursor.execute(sql.SQL(
			"DELETE FROM users WHERE users.userid="+str(self.userId)+";")) 
		cursor.close()
		conn.close()

class Admin:
	users = []

	def addFeederToUser(self, feeder, user):
		user.addFeeder(feeder)

	def addUser(self, user):
		users.append(user)

	def monitorFeeder(self, feeder):
		feeder.getCurrentState()

	def monitorUser(self, user):
		for feeder in user.feeders:
			feeder.getCurrentState()

	def exportUserLog():
		print('export user log')

	def exportUserLog():
		print('export user log')

class TimeTable:
	feeding_intevals = ''

	def __init__(self):
		feeding_intevals = ''

	def __init__(self, value):
		self.feeding_intevals = value

	def changeTimeTable(self, value):
		self.feeding_intevals = value

	def value(self):
		return self.feeding_intevals

	def delete(self):
		print('timeTable deleting')



def loadUsers():
	conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')

	cursor = conn.cursor()
	conn.autocommit = True
	# cursor.execute('SELECT * FROM test_table WHERE id < 10 OR id > 5000;')
	cursor.execute('SELECT (userid, username) FROM users;')

	users = []
	global lastUserId
	for row in cursor:
	  row = str(row[0])
	  # print("id :" +row[1:row.find(',')])
	  # print("username :"+row[row.find(',')+1:-1])
	  lastUserId = int(row[1:row.find(',')])
	  username = row[row.find(',')+1:-1]
	  users.append(User(username, lastUserId))

	cursor.close()
	conn.close()

	return users

def loadFeeders():
	conn = psycopg2.connect(dbname='feeder_system', user='postgres', 
    password='admin', host='localhost')

	cursor = conn.cursor()
	conn.autocommit = True
	# cursor.execute('SELECT * FROM test_table WHERE id < 10 OR id > 5000;')
	cursor.execute('SELECT * FROM feeders;')

	feeders = []

	global lastFeederId

	for row in cursor:
	  fields = str(row)[1:-1].split(', ')
	  lastFeederId= int(fields[0])
	  values= {
		  'feederId': int(fields[0]),
		  'labels': str(fields[1])[1:-1],
		  'userId': int(fields[2]),
		  'feederType': str(fields[3])[1:-1],
		  'timeTable': str(fields[4])[1:-1],
		  'capacity': int(fields[5]),
		  'filledInternally': int(fields[6]),
		  'filledExternally': int(fields[7])
	  }
	  feeders.append(Feeder(values))
		# print("feeder id :" +row[2:row.find(',')])
		# print("label :"+row[row.find(',')+1:-1])
		# print("userid :")
		# lastFeederId = int(row[1:row.find(',')])
		# username = row[row.find(',')+1:-1]
		# users.append(User(username, lastUserId))

	cursor.close()
	conn.close()

	return feeders

def syncFeeders(users, feeders):
	for feeder in feeders:
		userId = feeder.getUserId()
		for user in users:
			if (user.getUserId()==userId):
				user.addFeeder(feeder)