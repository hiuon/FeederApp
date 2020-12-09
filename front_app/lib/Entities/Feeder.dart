class Feeder {
  int feederId;
  int userId;
  //List<String> stateLabels_;
  List<bool> stateLabels;
  List<String> labels;
  String feederType;
  String timeTable;
  int capacity;
  int filledInernally;
  int filledExternally;

  Feeder(
      {this.feederId,
      this.labels,
      //this.stateLabels_,
      this.feederType,
      this.stateLabels,
      this.timeTable,
      this.capacity,
      this.filledExternally,
      this.filledInernally});

  factory Feeder.fromJson(Map<String, dynamic> json) {
    print("////////");
    print(json);
    return Feeder(
        feederId: json["feederId"] as int,
        labels: (json["labels"] as String).split("__"),
        //stateLabels_: (json["labelsState"] as String).split("__"),
        feederType: (json["feederType"] as String).toString(),
        timeTable: (json["timeTable"] as String).toString(),
        capacity: json["capacity"] as int,
        filledExternally: json["filledExternally"] as int,
        filledInernally: json["filledInternally"] as int,
        stateLabels: fromStringToBool((json["labelState"] as String).split("__"));
  }

  static List<bool> fromStringToBool(List<String> state) {
    List<bool> stateL = new List<bool>();
    for (String i in state) {
      if (i == "0") {
        stateL.add(false);
      }
      else{
        stateL.add(true);
      }
    }
    return stateL;
  }
}
