import 'package:ess_mobile/models/datetime_model.dart';

class LeaveHistoryModel {
  int? status;
  String? description;
  String? emplId;
  String? emplName;
  String? endDate;
  int? recId;
  String? startDate;
  DateTimeModel? schedule;

  LeaveHistoryModel({
    this.status,
    this.description,
    this.emplId,
    this.emplName,
    this.endDate,
    this.recId,
    this.startDate,
    this.schedule,
  });

  LeaveHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    description = json['Description'];
    emplId = json['EmplId'];
    emplName = json['EmplName'];
    endDate = json['EndDate'];
    recId = json['RecId'];
    startDate = json['StartDate'];
    schedule = json['Schedule'] != null
        ? new DateTimeModel.fromJson(json['Schedule'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Description'] = this.description;
    data['EmplId'] = this.emplId;
    data['EmplName'] = this.emplName;
    data['EndDate'] = this.endDate;
    data['RecId'] = this.recId;
    data['StartDate'] = this.startDate;
    if (this.schedule != null) {
      data['Schedule'] = this.schedule?.toJson();
    }
    return data;
  }
}

class SubordinateModel {
  int? status;
  String? description;
  String? emplId;
  String? emplName;
  int? recId;
  String? reportToEmplId;
  String? reportToEmplName;
  String? monthGroup;
  String? startDate;
  String? endDate;

  SubordinateModel({
    this.status,
    this.description,
    this.emplId,
    this.emplName,
    this.recId,
    this.reportToEmplId,
    this.reportToEmplName,
    this.monthGroup,
    this.startDate,
    this.endDate,
  });

  SubordinateModel.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    description = json['Description'];
    emplId = json['EmplId'];
    emplName = json['EmplName'];
    recId = json['RecId'];
    reportToEmplId = json['ReportToEmplId'];
    reportToEmplName = json['ReportToEmplName'];
    monthGroup = json['MonthGroup'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Description'] = this.description;
    data['EmplId'] = this.emplId;
    data['EmplName'] = this.emplName;
    data['RecId'] = this.recId;
    data['ReportToEmplId'] = this.reportToEmplId;
    data['ReportToEmplName'] = this.reportToEmplName;
    data['MonthGroup'] = this.monthGroup;
    data['StartDate'] = this.startDate;
    data['EndDate'] = this.endDate;
    return data;
  }
}

class LeaveCalendarModel {
  List<LeaveModel>? leaves;
  List<HolidayModel>? holidays;

  LeaveCalendarModel({this.leaves, this.holidays});

  LeaveCalendarModel.fromJson(Map<String, dynamic> json) {
    if (json['Leaves'] != null) {
      leaves = <LeaveModel>[];
      json['Leaves'].forEach((v) {
        leaves?.add(new LeaveModel.fromJson(v));
      });
    }
    if (json['Holidays'] != null) {
      holidays = <HolidayModel>[];
      json['Holidays'].forEach((v) {
        holidays?.add(new HolidayModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.leaves != null) {
      data['Leaves'] = this.leaves?.map((v) => v.toJson()).toList();
    }
    if (this.holidays != null) {
      data['Holidays'] = this.holidays?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeaveModel {
  DateTimeModel? schedule;
  String? description;
  String? type;
  String? typeDescription;
  String? addressDuringLeave;
  String? contactDuringLeave;
  String? subtituteEmployeeID;
  String? subtituteEmployeeName;
  int? pendingRequest;
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

  LeaveModel({
    this.schedule,
    this.description,
    this.type,
    this.typeDescription,
    this.addressDuringLeave,
    this.contactDuringLeave,
    this.subtituteEmployeeID,
    this.subtituteEmployeeName,
    this.pendingRequest,
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

  LeaveModel.fromJson(Map<String, dynamic> json) {
    schedule = json['Schedule'] != null
        ? new DateTimeModel.fromJson(json['Schedule'])
        : null;
    description = json['Description'];
    type = json['Type'];
    typeDescription = json['TypeDescription'];
    addressDuringLeave = json['AddressDuringLeave'];
    contactDuringLeave = json['ContactDuringLeave'];
    subtituteEmployeeID = json['SubtituteEmployeeID'];
    subtituteEmployeeName = json['SubtituteEmployeeName'];
    pendingRequest = json['PendingRequest'];
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
    if (this.schedule != null) {
      data['Schedule'] = this.schedule?.toJson();
    }
    data['Description'] = this.description;
    data['Type'] = this.type;
    data['TypeDescription'] = this.typeDescription;
    data['AddressDuringLeave'] = this.addressDuringLeave;
    data['ContactDuringLeave'] = this.contactDuringLeave;
    data['SubtituteEmployeeID'] = this.subtituteEmployeeID;
    data['SubtituteEmployeeName'] = this.subtituteEmployeeName;
    data['PendingRequest'] = this.pendingRequest;
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
    data['EmployeeID'] = this.employeeID;
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

class HolidayModel {
  String? employeeID;
  String? loggedDate;
  String? absenceCode;
  bool? isLeave;
  int? recId;

  HolidayModel({
    this.employeeID,
    this.loggedDate,
    this.absenceCode,
    this.isLeave,
    this.recId,
  });

  HolidayModel.fromJson(Map<String, dynamic> json) {
    employeeID = json['EmployeeID'];
    loggedDate = json['LoggedDate'];
    absenceCode = json['AbsenceCode'];
    isLeave = json['IsLeave'];
    recId = json['RecId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EmployeeID'] = this.employeeID;
    data['LoggedDate'] = this.loggedDate;
    data['AbsenceCode'] = this.absenceCode;
    data['IsLeave'] = this.isLeave;
    data['RecId'] = this.recId;
    return data;
  }
}

class LeaveTypeModel {
  String? categoryId;
  String? description;
  String? effectiveDateFrom;
  String? effectiveDateTo;
  bool? isClosed;
  int? typeId;
  int? maxDayLeave;
  int? remainder;
  int? consumeDay;

  LeaveTypeModel({
    this.categoryId,
    this.description,
    this.effectiveDateFrom,
    this.effectiveDateTo,
    this.isClosed,
    this.typeId,
    this.maxDayLeave,
    this.remainder,
    this.consumeDay,
  });

  LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    categoryId = json['CategoryId'];
    description = json['Description'];
    effectiveDateFrom = json['EffectiveDateFrom'];
    effectiveDateTo = json['EffectiveDateTo'];
    isClosed = json['IsClosed'];
    typeId = json['TypeId'];
    maxDayLeave = json['MaxDayLeave'];
    remainder = json['Remainder'];
    consumeDay = json['ConsumeDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CategoryId'] = this.categoryId;
    data['Description'] = this.description;
    data['EffectiveDateFrom'] = this.effectiveDateFrom;
    data['EffectiveDateTo'] = this.effectiveDateTo;
    data['IsClosed'] = this.isClosed;
    data['TypeId'] = this.typeId;
    data['MaxDayLeave'] = this.maxDayLeave;
    data['Remainder'] = this.remainder;
    data['ConsumeDay'] = this.consumeDay;
    return data;
  }
}

class LeaveInfoModel {
  List<MaintenanceModel>? maintenances;
  int? totalRemainder;
  int? totalPending;

  LeaveInfoModel({this.maintenances, this.totalRemainder, this.totalPending});

  LeaveInfoModel.fromJson(Map<String, dynamic> json) {
    if (json['Maintenances'] != null) {
      maintenances = <MaintenanceModel>[];
      json['Maintenances'].forEach((v) {
        maintenances?.add(new MaintenanceModel.fromJson(v));
      });
    }
    totalRemainder = json['TotalRemainder'];
    totalPending = json['TotalPending'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.maintenances != null) {
      data['Maintenances'] = this.maintenances?.map((v) => v.toJson()).toList();
    }
    data['TotalRemainder'] = this.totalRemainder;
    data['TotalPending'] = this.totalPending;
    return data;
  }
}

class MaintenanceModel {
  bool? available;
  DateTimeModel? availabilitySchedule;
  String? cFexpiredDate;
  String? employeeID;
  bool? isClosed;
  int? cf;
  String? description;
  int? remainder;
  int? rights;
  int? year;

  MaintenanceModel({
    this.available,
    this.availabilitySchedule,
    this.cFexpiredDate,
    this.employeeID,
    this.isClosed,
    this.cf,
    this.description,
    this.remainder,
    this.rights,
    this.year,
  });

  MaintenanceModel.fromJson(Map<String, dynamic> json) {
    available = json['Available'];
    availabilitySchedule = json['AvailabilitySchedule'] != null
        ? new DateTimeModel.fromJson(json['AvailabilitySchedule'])
        : null;
    cFexpiredDate = json['CFexpiredDate'];
    employeeID = json['EmployeeID'];
    isClosed = json['IsClosed'];
    cf = json['CF'];
    description = json['Description'];
    remainder = json['Remainder'];
    rights = json['Rights'];
    year = json['Year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Available'] = this.available;
    if (this.availabilitySchedule != null) {
      data['AvailabilitySchedule'] = this.availabilitySchedule?.toJson();
    }
    data['CFexpiredDate'] = this.cFexpiredDate;
    data['EmployeeID'] = this.employeeID;
    data['IsClosed'] = this.isClosed;
    data['CF'] = this.cf;
    data['Description'] = this.description;
    data['Remainder'] = this.remainder;
    data['Rights'] = this.rights;
    data['Year'] = this.year;
    return data;
  }
}
