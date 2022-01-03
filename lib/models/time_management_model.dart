import 'package:ess_mobile/models/datetime_model.dart';

class TimeAttendanceModel {
  dynamic old;
  String? absenceCode;
  String? reportToEmployeeID;
  String? name;
  String? project;
  int? days;
  String? loggedDate;
  DateTimeModel? scheduledDate;
  DateTimeModel? actualLogedDate;
  bool? absent;
  String? absenceCodeDescription;
  bool? isLeave;
  String? filepath;
  String? filename;
  String? fileext;
  String? checksum;
  bool? accessible;
  String? id;
  int? status;
  String? statusDescription;
  String? axRequestID;
  int? axid;
  String? employeeID;
  String? employeeName;
  String? reason;
  String? oldData;
  String? newData;
  String? createdDate;
  int? action;
  String? lastUpdate;
  String? updateBy;
  dynamic updateRequest;

  TimeAttendanceModel({
    this.old,
    this.absenceCode,
    this.reportToEmployeeID,
    this.name,
    this.project,
    this.days,
    this.loggedDate,
    this.scheduledDate,
    this.actualLogedDate,
    this.absent,
    this.absenceCodeDescription,
    this.isLeave,
    this.filepath,
    this.filename,
    this.fileext,
    this.checksum,
    this.accessible,
    this.id,
    this.status,
    this.statusDescription,
    this.axRequestID,
    this.axid,
    this.employeeID,
    this.employeeName,
    this.reason,
    this.oldData,
    this.newData,
    this.createdDate,
    this.action,
    this.lastUpdate,
    this.updateBy,
    this.updateRequest,
  });

  TimeAttendanceModel.fromJson(Map<String, dynamic> json) {
    old = json['Old'];
    absenceCode = json['AbsenceCode'];
    reportToEmployeeID = json['ReportToEmployeeID'];
    name = json['Name'];
    project = json['Project'];
    days = json['Days'];
    loggedDate = json['LoggedDate'];
    scheduledDate = json['ScheduledDate'] != null
        ? new DateTimeModel.fromJson(json['ScheduledDate'])
        : null;
    actualLogedDate = json['ActualLogedDate'] != null
        ? new DateTimeModel.fromJson(json['ActualLogedDate'])
        : null;
    absent = json['Absent'];
    absenceCodeDescription = json['AbsenceCodeDescription'];
    isLeave = json['IsLeave'];
    filepath = json['Filepath'];
    filename = json['Filename'];
    fileext = json['Fileext'];
    checksum = json['Checksum'];
    accessible = json['Accessible'];
    id = json['Id'];
    status = json['Status'];
    statusDescription = json['StatusDescription'];
    axRequestID = json['AXRequestID'];
    axid = json['AXID'];
    employeeID = json['EmployeeID'];
    employeeName = json['EmployeeName'];
    reason = json['Reason'];
    oldData = json['OldData'];
    newData = json['NewData'];
    createdDate = json['CreatedDate'];
    action = json['Action'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
    updateRequest = json['UpdateRequest'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Old'] = this.old;
    data['AbsenceCode'] = this.absenceCode;
    data['ReportToEmployeeID'] = this.reportToEmployeeID;
    data['Name'] = this.name;
    data['Project'] = this.project;
    data['Days'] = this.days;
    data['LoggedDate'] = this.loggedDate;
    if (this.scheduledDate != null) {
      data['ScheduledDate'] = this.scheduledDate?.toJson();
    }
    if (this.actualLogedDate != null) {
      data['ActualLogedDate'] = this.actualLogedDate?.toJson();
    }
    data['Absent'] = this.absent;
    data['AbsenceCodeDescription'] = this.absenceCodeDescription;
    data['IsLeave'] = this.isLeave;
    data['Filepath'] = this.filepath;
    data['Filename'] = this.filename;
    data['Fileext'] = this.fileext;
    data['Checksum'] = this.checksum;
    data['Accessible'] = this.accessible;
    data['Id'] = this.id;
    data['Status'] = this.status;
    data['StatusDescription'] = this.statusDescription;
    data['AXRequestID'] = this.axRequestID;
    data['AXID'] = this.axid;
    data['employeeID'] = this.employeeID;
    data['EmployeeName'] = this.employeeName;
    data['Reason'] = this.reason;
    data['OldData'] = this.oldData;
    data['NewData'] = this.newData;
    data['CreatedDate'] = this.createdDate;
    data['Action'] = this.action;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    data['UpdateRequest'] = this.updateRequest;
    return data;
  }
}

class AbsenceImportedModel {
  AbsenceImportedModel.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
