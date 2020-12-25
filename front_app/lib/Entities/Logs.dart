class Log {
  int feederId;
  int logId;
  String logMessage;
  String logType;
  String timeStamp;
  int userId;

  Log(
      {this.feederId,
      this.logId,
      this.logMessage,
      this.logType,
      this.timeStamp,
      this.userId});

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
        feederId: json["feederId"] as int,
        logId: json["logId"] as int,
        logMessage: json["logMessage"] as String,
        logType: json["logType"] as String,
        timeStamp: json["timeStamp"] as String,
        userId: json["userId"] as int);
  }

  static String logToString(List<Log> logs) {
    StringBuffer temp = new StringBuffer();
    temp.write("feederId | " +
        "logId | " +
        "logMessage | " +
        "logType | " +
        "timeStamp | " +
        "userId |\n");
    for (Log log in logs) {
      temp.write(log.feederId.toString() +
          " | " +
          log.logId.toString() +
          " | " +
          log.logMessage +
          " | " +
          log.logType +
          " | " +
          log.timeStamp +
          " | " +
          log.userId.toString() +
          " |\n");
    }
    print(temp);
    return temp.toString();
  }
}
