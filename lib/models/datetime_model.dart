class DateTimeModel {
  double? trueMonthly;
  double? month;
  double? days;
  double? hours;
  double? seconds;
  String? start;
  String? finish;

  DateTimeModel({
    this.trueMonthly,
    this.month,
    this.days,
    this.hours,
    this.seconds,
    this.start,
    this.finish,
  });

  DateTimeModel.fromJson(Map<String, dynamic> json) {
    trueMonthly = json['TrueMonthly'];
    month = json['Month'];
    days = json['Days'];
    hours = json['Hours'];
    seconds = json['Seconds'];
    start = json['Start'];
    finish = json['Finish'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TrueMonthly'] = this.trueMonthly;
    data['Month'] = this.month;
    data['Days'] = this.days;
    data['Hours'] = this.hours;
    data['Seconds'] = this.seconds;
    data['Start'] = this.start;
    data['Finish'] = this.finish;
    return data;
  }
}
