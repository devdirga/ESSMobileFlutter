import 'package:ess_mobile/models/datetime_model.dart';

class SleepMonitorModel {
  String? id;
  String? employeeID;
  String? employeeName;
  DateTimeModel? actualSleep;
  int? totalTimeAwakened;
  double? totalSleepHours;
  double? totalWakeUpHours;
  int? action;
  String? createdDate;
  String? lastUpdate;
  String? updateBy;
  dynamic updateRequest;

  SleepMonitorModel({
    this.id,
    this.employeeID,
    this.employeeName,
    this.actualSleep,
    this.totalTimeAwakened,
    this.totalSleepHours,
    this.totalWakeUpHours,
    this.action,
    this.createdDate,
    this.lastUpdate,
    this.updateBy,
    this.updateRequest,
  });

  SleepMonitorModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    employeeID = json['EmployeeID'];
    employeeName = json['EmployeeName'];
    actualSleep = json['ActualSleep'] != null
        ? new DateTimeModel.fromJson(json['ActualSleep'])
        : null;
    totalTimeAwakened = json['TotalTimeAwakened'];
    totalSleepHours = json['TotalSleepHours'];
    totalWakeUpHours = json['TotalWakeUpHours'];
    action = json['Action'];
    createdDate = json['CreatedDate'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
    updateRequest = json['UpdateRequest'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['EmployeeID'] = this.employeeID;
    data['EmployeeName'] = this.employeeName;
    if (this.actualSleep != null) {
      data['ActualSleep'] = this.actualSleep?.toJson();
    }
    data['TotalTimeAwakened'] = this.totalTimeAwakened;
    data['TotalSleepHours'] = this.totalSleepHours;
    data['TotalWakeUpHours'] = this.totalWakeUpHours;
    data['Action'] = this.action;
    data['CreatedDate'] = this.createdDate;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    data['UpdateRequest'] = this.updateRequest;
    return data;
  }
}
