# from dbHelper import
from utilities import datetimeToStr, safeIntForDB
import psycopg2
from psycopg2 import sql
#from utilities import 

db_name = 'feeder_system'
db_user = 'postgres'
db_password = 'admin'
db_host = 'localhost'

lastFeederId=0
lastUserId=0
lastLogId=0

def logIdWithAutoInc():
	global lastLogId
	lastLogId +=1
	return lastLogId-1

def getLastLogId():
	global lastLogId
	conn = psycopg2.connect(dbname=db_name, user=db_user, 
  password=db_password, host=db_host)
	cursor = conn.cursor()
	conn.autocommit = True

	querry = sql.SQL('SELECT COUNT(*) FROM logs;')
	cursor.execute(querry) 

	for row in cursor:
		lastLogId = int(row[0])
		break
		
	cursor.close()
	conn.close()
	return lastLogId

def log(logType, logMessage, userId=None, feederId=None):
	global lastLogId
	lastLogId=getLastLogId()
	conn = psycopg2.connect(dbname=db_name, user=db_user, 
  password=db_password, host=db_host)
	cursor = conn.cursor()
	conn.autocommit = True
	# logId = logIdWithAutoInc()

	if userId is None:
		querry = sql.SQL(
			"INSERT INTO logs VALUES(DEFAULT, '"+str(logType)+"', '"+str(logMessage)+"');")
	elif feederId is None:
		querry = sql.SQL(
			"INSERT INTO logs VALUES(DEFAULT, '"+str(logType)+"', '"+str(logMessage)+"', "+str(userId)+");")
	else:
		querry = sql.SQL(
			"INSERT INTO logs VALUES(DEFAULT, '"+str(logType)+"', '"+str(logMessage)+"', "+str(userId)+", "+str(feederId)+");")
	cursor.execute(querry) 
	cursor.close()
	conn.close()

class Feeder:
	feederId = 0
	labels = ''
	labelsState = ''
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
		self.labelsState = str(values["labelsState"])
		self.userId = int(values["userId"])
		self.feederType = str(values["feederType"])
		self.timeTable = str(values["timeTable"])
		self.capacity = int(values["capacity"])
		self.filledInternally = int(values["filledInternally"])
		self.filledExternally = int(values["filledExternally"])

	def setUserId(self, userId):
		self.userId = int(userId)
		self.updateInDB()
		log("FEEDER STATE", "FEEDER OWNER CHANGE", self.userId, self.feederId)

	def getUserId(self):
		return int(self.userId)

	def feed(self, amount):
		amount = int(amount)
		if (self.filledInternally-amount>=0):
			self.filledInternally -= amount
			self.filledExternally += amount
			self.updateInDBOnlyFood()
			log("FEEDER STATE", "FEEDING OK", self.userId, self.feederId)
		else:
			self.filledInternally = 50
			self.updateInDBOnlyFood
			log("FEEDER ERROR", "FEEDING FAILED. WRONG FEED VALUE (TOO BIG)", self.userId, self.feederId)

	def eat(self, amount):
		amount = int(amount)
		if (self.filledExternally-amount<0):
			log("FEEDER ERROR", "EATING FAILED. WRONG EAT VALUE (TOO BIG)", self.userId, self.feederId)
		else:
			self.filledExternally -= amount
			self.updateInDBOnlyFood()
			log("FEEDER STATE", "EATING OK", self.userId, self.feederId)

	def currentStateToDict(self):
		feeder = {
			'feederId': int(self.feederId),
			'labels': str(self.labels),
			'labelsState':str(self.labelsState),
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
		self.labelsState = str(values["labelsState"])
		self.userId = int(values["userId"])
		self.feederType = str(values["feederType"])
		self.timeTable = str(values["timeTable"])
		self.capacity = int(values["capacity"])
		self.filledInternally = int(values["filledInternally"])
		self.filledExternally = int(values["filledExternally"])
		self.updateInDB()

	def saveToDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
		cursor = conn.cursor()
		conn.autocommit = True
		columns = "feederid, labels, labelsState, userid, feedertype, timetable, capacity, filledinternally, filledexternally"#, labelsState"
		values = str(self.feederId)+", '"+str(self.labels)+"', '"+str(self.labelsState)+"', "+str(self.userId)+", '"+str(self.feederType)+"', '"+str(self.timeTable)+"', "+str(self.capacity)+', '+str(self.filledInternally)+', '+str(self.filledExternally)#+", '"+str(self.labelsState)
		cursor.execute(sql.SQL(
			'INSERT INTO feeders VALUES('+values+');')) 
		cursor.close()
		conn.close()
		log("FEEDER SAVE", "FEEDER SAVED", self.userId, self.feederId)

	def updateInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
		cursor = conn.cursor()
		conn.autocommit = True
		values = "labels='"+str(self.labels)+"', "+"labelsState='"+str(self.labelsState)+"', "+ "userid="+str(self.userId)+", feedertype='"+str(self.feederType)+"', timetable='"+str(self.timeTable)+"', capacity="+str(self.capacity)+', filledInternally='+str(self.filledInternally)+', filledExternally='+str(self.filledExternally)#='+str(self.labelsState)
		cursor.execute(sql.SQL(
			'UPDATE feeders SET '+values+'WHERE feeders.feederid='+str(self.feederId)+';')) 
		cursor.close()
		conn.close()
		log("FEEDER UPDATE", "FEEDER UPDATED", self.userId, self.feederId)

	def updateInDBOnlyFood(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
		cursor = conn.cursor()
		conn.autocommit = True
		values = 'filledInternally='+str(self.filledInternally)+', filledExternally='+str(self.filledExternally)#='+str(self.labelsState)
		cursor.execute(sql.SQL(
			'UPDATE feeders SET '+values+'WHERE feeders.feederid='+str(self.feederId)+';')) 
		cursor.close()
		conn.close()
		log("FEEDER SMALL UPDATE", "FEEDER UPDATED", self.userId, self.feederId)

	def deleteInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)
		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute(sql.SQL(
			'DELETE FROM feeders WHERE feeders.feederid='+str(self.feederId)+';')) 
		cursor.close()
		conn.close()
		log("FEEDER DELETE", "FEEDER DELETED", self.userId, self.feederId)

	def getAllFeederLogs(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
		password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute('SELECT * FROM logs WHERE logs.feederid = '+str(self.feederId)+';')
		# cursor.execute('SELECT * FROM logs;')

		logs = []

		for row in cursor:
			fields = str(row)[1:-1].split(', ')
			log = {
				'logId': int(fields[0]),
				'logType': str(fields[1][1:-1]),
				'logMessage': str(fields[2][1:-1]),
				'userId': safeIntForDB(fields[3]),
				'feederId': safeIntForDB(fields[4]),
				'timeStamp': datetimeToStr(fields[-7:])
			}
			logs.append(log)

		cursor.close()
		conn.close()

		return logs

	def getTimeTable(self):
		return self.timeTable

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

	def getAllUserFeeders(self):
		return self.feeders

	def setName(self, name):
		self.name = name
		self.updateInDB()
		log("USER STATE", "USER NAME CHANGE", self.userId, self.feederId)


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
		log("USER SAVE", "USER "+self.name+"SAVED IN DB", self.userId)

	def updateInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute(sql.SQL(
			"UPDATE users SET username = '"+self.name+"' WHERE users.userid="+str(self.userId)+";")) 
		cursor.close()
		conn.close()
		log("USER UPDATE", "USER "+self.name+" UPDATED IN DB", self.userId)

	def deleteInDB(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute(sql.SQL(
			"DELETE FROM users WHERE users.userid="+str(self.userId)+";")) 
		cursor.close()
		conn.close()
		log("USER DELETE", "USER "+self.name+" DELETED IN DB", self.userId)

	def getAllUserLogs(self):
		conn = psycopg2.connect(dbname=db_name, user=db_user, 
		password=db_password, host=db_host)

		cursor = conn.cursor()
		conn.autocommit = True
		cursor.execute('SELECT * FROM logs WHERE logs.userid = '+str(self.userId)+';')
		# cursor.execute('SELECT * FROM logs;')

		logs = []

		for row in cursor:
			fields = str(row)[1:-1].split(', ')
			log = {
				'logId': int(fields[0]),
				'logType': str(fields[1][1:-1]),
				'logMessage': str(fields[2][1:-1]),
				'userId': safeIntForDB(fields[3]),
				'feederId': safeIntForDB(fields[4]),
				'timeStamp': datetimeToStr(fields[-7:])
			}
			logs.append(log)

		cursor.close()
		conn.close()

		return logs

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
	
	log("SYSTEM INIT", str(len(users))+" USERS LOADED FROM DB")

	return users

def loadFeeders():
	conn = psycopg2.connect(dbname=db_name, user=db_user, 
    password=db_password, host=db_host)

	cursor = conn.cursor()
	conn.autocommit = True
	cursor.execute('SELECT * FROM feeders order by feederid;')

	feeders = []

	global lastFeederId

	for row in cursor:
	  fields = str(row)[1:-1].split(', ')
	  lastFeederId= int(fields[0])
	  values= {
		  'feederId': int(fields[0]),
		  'labels': str(fields[1])[1:-1],
		  'labelsState': str(fields[2])[1:-1],
		  'userId': int(fields[3]),
		  'feederType': str(fields[4])[1:-1],
		  'timeTable': str(fields[5])[1:-1],
		  'capacity': int(fields[6]),
		  'filledInternally': int(fields[7]),
		  'filledExternally': int(fields[8])
	  }
	  feeders.append(Feeder(values))

	cursor.close()
	conn.close()

	log("SYSTEM INIT", str(len(feeders))+" FEEDERS LOADED FROM DB")

	return feeders

def syncFeeders(users, feeders):
	for feeder in feeders:
		userId = feeder.getUserId()
		for user in users:
			if (user.getUserId()==userId):
				user.addFeeder(feeder)