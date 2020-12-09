import psycopg2
from psycopg2 import sql

lastFeederId=0
lastUserId=0

db_name = 'feeder_system'
db_user = 'postgres'
db_password = 'admin'
db_host = 'localhost'

class Feeder:
	feederId = 0
	labels = ''
	#labelsState = ''
	userId = 0
	feederType = ''
	timeTable = ''
	capacity = 0
	filledInternally = 0
	filledExternally = 0

	def __init__(self, feederId):
		global lastFeederId
		self.feederId = int(lastFeederId)
		lastFeederId +=1

	def __init__(self, values):
		global lastFeederId
		self.feederId = lastFeederId
		lastFeederId +=1
		self.labels = str(values["labels"])
		#self.labelsState = str(values["labelsState"])
		self.userId = int(values["userId"])
		self.feederType = str(values["feederType"])
		self.timeTable = str(values["timeTable"])
		self.capacity = int(values["capacity"])
		self.filledInternally = int(values["filledInternally"])
		self.filledExternally = int(values["filledExternally"])


	FEEDER_FEEDING_OK = 'FEEDER_FEEDING_OK'
	FEEDER_FEEDING_FAIL = 'FEEDER_FEEDING_FAIL'
	FEEDER_PING_OK = 'FEEDER_PING_OK'
	FEEDER_PING_FAIL = 'FEEDER_PING_FAIL'
	FEEDER_EATING_OK = 'FEEDER_EATING_OK'
	FEEDER_EATING_FAIL = 'FEEDER_EATING_FAIL'

	def setUserId(self, userId):
		self.userId = int(userId)
		self.updateInDB()

	def getUserId(self):
		return int(self.userId)

	def feed(self, amount):
		amount = int(amount)
		if (self.filledInternally-amount>=0):
			self.filledInternally -= amount
			self.filledExternally += amount
			self.updateInDB()		

	def eat(self, amount):
		amount = int(amount)
		if (filledExternally-amount<0):
			log(self, 'E', FEEDER_EATING_FAIL)
		else:
			log(self, 'I', FEEDER_EATING_OK)
			self.filledExternally -= amount
			self.updateInDB()

	def currentStateToDict(self):
		feeder = {
			'feederId': int(self.feederId),
			'labels': str(self.labels),
			#'labelsState':str(self.labelsState),
			'userId': int(self.userId),
			'feederType': str(self.feederType),
			'timeTable': str(self.timeTable),
			'capacity': int(self.capacity),
			'filledInternally': int(self.filledInternally),
			'filledExternally': int(self.filledExternally)
		}
		return feeder

	def delete(self):
		print("FEEDER deleting")
		global lastFeederId
		self.deleteInDB()
		if (self.feederId==lastFeederId):
			lastFeederId-=1

	def getFeederId(self):
		return int(self.feederId)

	def set(self, values): 
		self.labels = str(values["labels"])
		#self.labelsState = str(values["labelsState"])
		self.userId = int(values["userId"])
		self.feederType = str(values["feederType"])
		self.timeTable = str(values["timeTable"])
		self.capacity = int(values["capacity"])
		self.filledInternally = int(values["filledInternally"])
		self.filledExternally = int(values["filledExternally"])

	def saveToDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
		cursor = conn.cursor()
		conn.autocommit = True
		columns = "feederid, labels, userid, feedertype, timetable, capacity, filledinternally, filledexternally" #labelsState
		values = str(self.feederId)+", '"+str(self.labels)+"', "+str(self.userId)+", '"+str(self.feederType)+"', '"+str(self.timeTable)+"', "+str(self.capacity)+', '+str(self.filledInternally)+', '+str(self.filledExternally) #+", '"+str(self.labelsState)
		cursor.execute(sql.SQL(
			'INSERT INTO feeders VALUES('+values+');')) 
		cursor.close()
		conn.close()

	def updateInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
		cursor = conn.cursor()
		conn.autocommit = True
		values = "labels='"+str(self.labels)+"', userid="+str(self.userId)+", feedertype='"+str(self.feederType)+"', timetable='"+str(self.timeTable)+"', capacity="+str(self.capacity)+', filledInternally='+str(self.filledInternally)+', filledExternally='+str(self.filledExternally) #+', labelsState='+str(self.labelsState)
		cursor.execute(sql.SQL(
			'UPDATE feeders SET '+values+'WHERE feeders.feederid='+str(self.feederId)+';')) 
		cursor.close()
		conn.close()

	def deleteInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
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
		
	def addFeeder(self, feeder):
		feeder.setUserId(self.userId)
		self.feeders.append(feeder)

	def removeFeederById(self, feederId):
		feederid = int(feederId)
		for feeder in self.feeders:
			if (feeder.getFeederId()==feederId):
				self.feeders.remove(feeder)
				feeder.delete()

	def listingView(self):
		return {
			"id": int(self.userId),
			"name": self.name
		}

	def feedersCurrentStateToList(self):
		return [feeder.currentStateToDict() for feeder in self.feeders]

	def timeTablesToList(self):
		return [t for t in self.timeTables]

	def currentStateToDict(self):
		return {
			"id": int(self.userId),
			"name": self.name,
			"feeders": self.feedersCurrentStateToList(),
			"timeTables": self.timeTables
		}
	def getUserId(self):
		return int(self.userId)

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
			if (f.getFeederId()==int(feederId)):
				return f
	
	def saveToDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute(sql.SQL(
			'INSERT INTO users VALUES('+str(self.userId)+", '"+self.name+"');")) 
		cursor.close()
		conn.close()

	def updateInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute(sql.SQL(
			"UPDATE users SET username = '"+self.name+"' WHERE users.userid="+str(self.userId)+";")) 
		cursor.close()
		conn.close()

	def deleteInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
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
	conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

	cursor = conn.cursor()
	conn.autocommit = True
	cursor.execute('SELECT (userid, username) FROM users;')

	users = []
	global lastUserId
	for row in cursor:
	  row = str(row[0])
	  lastUserId = int(row[1:row.find(',')])
	  username = row[row.find(',')+1:-1]
	  users.append(User(username, lastUserId))

	cursor.close()
	conn.close()

	return users

def loadFeeders():
	conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

	cursor = conn.cursor()
	conn.autocommit = True
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
		  'filledExternally': int(fields[7]),
		  #'labelsState': str(fields[1])[1:-1]
	  }
	  feeders.append(Feeder(values))

	cursor.close()
	conn.close()

	return feeders

def syncFeeders(users, feeders):
	for feeder in feeders:
		userId = feeder.getUserId()
		for user in users:
			if (user.getUserId()==userId):
				user.addFeeder(feeder)