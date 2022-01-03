import 'package:ess_mobile/models/datetime_model.dart';
import 'package:ess_mobile/models/attachment_model.dart';

class TravelModel {
  String? travelID;
  int? intention;
  String? intentionDescription;
  String? requestForID;
  String? requestForName;
  bool? isGuest;
  String? origin;
  String? destination;
  DateTimeModel? schedule;
  int? travelPurpose;
  String? travelPurposeDescription;
  int? transportation;
  String? transportationDescription;
  String? transactionDate;
  bool? needPassportExtension;
  bool? needVisaExtension;
  String? description;
  List<SppdModel>? sppd;
  String? createdBy;
  String? verifiedBy;
  String? canceledBy;
  String? closedDate;
  String? canceledDate;
  String? verifiedDate;
  int? travelRequestStatus;
  int? transportasi;
  String? note;
  String? noteRevision;
  String? revisionBy;
  String? revisionDate;
  int? travelType;
  String? travelTypeDescription;
  List<DocumentListModel>? documentList;
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

  TravelModel({
    this.travelID,
    this.intention,
    this.intentionDescription,
    this.requestForID,
    this.requestForName,
    this.isGuest,
    this.origin,
    this.destination,
    this.schedule,
    this.travelPurpose,
    this.travelPurposeDescription,
    this.transportation,
    this.transportationDescription,
    this.transactionDate,
    this.needPassportExtension,
    this.needVisaExtension,
    this.description,
    this.sppd,
    this.createdBy,
    this.verifiedBy,
    this.canceledBy,
    this.closedDate,
    this.canceledDate,
    this.verifiedDate,
    this.travelRequestStatus,
    this.transportasi,
    this.note,
    this.noteRevision,
    this.revisionBy,
    this.revisionDate,
    this.travelType,
    this.travelTypeDescription,
    this.documentList,
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

  TravelModel.fromJson(Map<String, dynamic> json) {
    travelID = json['TravelID'];
    intention = json['Intention'];
    intentionDescription = json['IntentionDescription'];
    requestForID = json['RequestForID'];
    requestForName = json['RequestForName'];
    isGuest = json['IsGuest'];
    origin = json['Origin'];
    destination = json['Destination'];
    schedule = json['Schedule'] != null
        ? new DateTimeModel.fromJson(json['Schedule'])
        : null;
    travelPurpose = json['TravelPurpose'];
    travelPurposeDescription = json['TravelPurposeDescription'];
    transportation = json['Transportation'];
    transportationDescription = json['TransportationDescription'];
    transactionDate = json['TransactionDate'];
    needPassportExtension = json['NeedPassportExtension'];
    needVisaExtension = json['NeedVisaExtension'];
    description = json['Description'];
    if (json['Sppd'] != null) {
      sppd = <SppdModel>[];
      json['Sppd'].forEach((v) {
        sppd?.add(new SppdModel.fromJson(v));
      });
    }
    createdBy = json['CreatedBy'];
    verifiedBy = json['VerifiedBy'];
    canceledBy = json['CanceledBy'];
    closedDate = json['ClosedDate'];
    canceledDate = json['CanceledDate'];
    verifiedDate = json['VerifiedDate'];
    travelRequestStatus = json['TravelRequestStatus'];
    transportasi = json['Transportasi'];
    note = json['Note'];
    noteRevision = json['NoteRevision'];
    revisionBy = json['RevisionBy'];
    revisionDate = json['RevisionDate'];
    travelType = json['TravelType'];
    travelTypeDescription = json['TravelTypeDescription'];
    if (json['DocumentList'] != null) {
      documentList = <DocumentListModel>[];
      json['DocumentList'].forEach((v) {
        documentList?.add(new DocumentListModel.fromJson(v));
      });
    }
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
    data['TravelID'] = this.travelID;
    data['Intention'] = this.intention;
    data['IntentionDescription'] = this.intentionDescription;
    data['RequestForID'] = this.requestForID;
    data['RequestForName'] = this.requestForName;
    data['IsGuest'] = this.isGuest;
    data['Origin'] = this.origin;
    data['Destination'] = this.destination;
    if (this.schedule != null) {
      data['Schedule'] = this.schedule?.toJson();
    }
    data['TravelPurpose'] = this.travelPurpose;
    data['TravelPurposeDescription'] = this.travelPurposeDescription;
    data['Transportation'] = this.transportation;
    data['TransportationDescription'] = this.transportationDescription;
    data['TransactionDate'] = this.transactionDate;
    data['NeedPassportExtension'] = this.needPassportExtension;
    data['NeedVisaExtension'] = this.needVisaExtension;
    data['Description'] = this.description;
    if (this.sppd != null) {
      data['Sppd'] = this.sppd?.map((v) => v.toJson()).toList();
    }
    data['CreatedBy'] = this.createdBy;
    data['VerifiedBy'] = this.verifiedBy;
    data['CanceledBy'] = this.canceledBy;
    data['ClosedDate'] = this.closedDate;
    data['CanceledDate'] = this.canceledDate;
    data['VerifiedDate'] = this.verifiedDate;
    data['TravelRequestStatus'] = this.travelRequestStatus;
    data['Transportasi'] = this.transportasi;
    data['Note'] = this.note;
    data['NoteRevision'] = this.noteRevision;
    data['RevisionBy'] = this.revisionBy;
    data['RevisionDate'] = this.revisionDate;
    data['TravelType'] = this.travelType;
    data['TravelTypeDescription'] = this.travelTypeDescription;
    if (this.documentList != null) {
      data['DocumentList'] = this.documentList?.map((v) => v.toJson()).toList();
    }
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

class SppdModel {
  String? sppdid;
  double? accommodation;
  double? fuel;
  String? employeeID;
  String? employeeName;
  Null grade;
  String? position;
  double? laundry;
  double? parking;
  int? axid;
  String? axRequestID;
  double? rent;
  int? status;
  String? start;
  String? end;
  double? ticket;
  double? highway;
  double? airportTransportation;
  double? localTransportation;
  double? mealAllowance;
  double? pocketMoney;
  List<TransportationDetailModel>? transportationDetails;
  List<AttachmentModel>? attachments;
  bool? isAttachmentExist;
  String? sppdNumber;
  int? sppdStatus;

  SppdModel({
    this.sppdid,
    this.accommodation,
    this.fuel,
    this.employeeID,
    this.employeeName,
    this.grade,
    this.position,
    this.laundry,
    this.parking,
    this.axid,
    this.axRequestID,
    this.rent,
    this.status,
    this.start,
    this.end,
    this.ticket,
    this.highway,
    this.airportTransportation,
    this.localTransportation,
    this.mealAllowance,
    this.pocketMoney,
    this.transportationDetails,
    this.attachments,
    this.isAttachmentExist,
    this.sppdNumber,
    this.sppdStatus,
  });

  SppdModel.fromJson(Map<String, dynamic> json) {
    sppdid = json['Sppdid'];
    accommodation = json['Accommodation'];
    fuel = json['Fuel'];
    employeeID = json['EmployeeID'];
    employeeName = json['EmployeeName'];
    grade = json['Grade'];
    position = json['Position'];
    laundry = json['Laundry'];
    parking = json['Parking'];
    axid = json['AXID'];
    axRequestID = json['AXRequestID'];
    rent = json['Rent'];
    status = json['Status'];
    start = json['Start'];
    end = json['End'];
    ticket = json['Ticket'];
    highway = json['Highway'];
    airportTransportation = json['AirportTransportation'];
    localTransportation = json['LocalTransportation'];
    mealAllowance = json['MealAllowance'];
    pocketMoney = json['PocketMoney'];
    if (json['TransportationDetails'] != null) {
      transportationDetails = <TransportationDetailModel>[];
      json['TransportationDetails'].forEach((v) {
        transportationDetails?.add(new TransportationDetailModel.fromJson(v));
      });
    }
    if (json['Attachments'] != null) {
      attachments = <AttachmentModel>[];
      json['Attachments'].forEach((v) {
        attachments?.add(new AttachmentModel.fromJson(v));
      });
    }
    isAttachmentExist = json['IsAttachmentExist'];
    sppdNumber = json['SppdNumber'];
    sppdStatus = json['SppdStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Sppdid'] = this.sppdid;
    data['Accommodation'] = this.accommodation;
    data['Fuel'] = this.fuel;
    data['EmployeeID'] = this.employeeID;
    data['EmployeeName'] = this.employeeName;
    data['Grade'] = this.grade;
    data['Position'] = this.position;
    data['Laundry'] = this.laundry;
    data['Parking'] = this.parking;
    data['AXID'] = this.axid;
    data['AXRequestID'] = this.axRequestID;
    data['Rent'] = this.rent;
    data['Status'] = this.status;
    data['Start'] = this.start;
    data['End'] = this.end;
    data['Ticket'] = this.ticket;
    data['Highway'] = this.highway;
    data['AirportTransportation'] = this.airportTransportation;
    data['LocalTransportation'] = this.localTransportation;
    data['MealAllowance'] = this.mealAllowance;
    data['PocketMoney'] = this.pocketMoney;
    if (this.transportationDetails != null) {
      data['TransportationDetails'] =
          this.transportationDetails?.map((v) => v.toJson()).toList();
    }
    if (this.attachments != null) {
      data['Attachments'] = this.attachments?.map((v) => v.toJson()).toList();
    }
    data['IsAttachmentExist'] = this.isAttachmentExist;
    data['SppdNumber'] = this.sppdNumber;
    data['SppdStatus'] = this.sppdStatus;
    return data;
  }
}

class DocumentListModel {
  DocumentListModel.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}

class TransportationDetailModel {
  TransportationDetailModel.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    return data;
  }
}
