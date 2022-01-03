import 'package:ess_mobile/models/attachment_model.dart';
import 'package:ess_mobile/models/ticket_category_model.dart';

class ComplaintModel {
  String? ticketNumber;
  String? ticketResolution;
  String? subject;
  String? emailCc;
  List<String>? emailTo;
  String? emailFrom;
  int? ticketType;
  String? fullName;
  int? ticketMedia;
  String? description;
  String? ticketDate;
  int? ticketStatus;
  String? ticketCategory;
  TicketCategoryModel? category;
  AttachmentModel? attachments;
  int? invertedStatus;
  String? invertedStatusDescription;
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
  String? closedDate;
  int? action;
  String? lastUpdate;
  String? updateBy;

  ComplaintModel({
    this.ticketNumber,
    this.ticketResolution,
    this.subject,
    this.emailCc,
    this.emailTo,
    this.emailFrom,
    this.ticketType, 
    this.fullName,
    this.ticketMedia,
    this.description,
    this.ticketDate, 
    this.ticketStatus,
    this.ticketCategory,
    this.category,
    this.attachments,
    this.invertedStatus, 
    this.invertedStatusDescription,
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
    this.closedDate,
    this.action,
    this.lastUpdate,
    this.updateBy
  });

  ComplaintModel.fromJson(Map<String, dynamic> json) {
    ticketNumber = json['TicketNumber'];
    ticketResolution = json['TicketResolution'];
    subject = json['Subject'];
    emailCc = json['EmailCC'];
    emailTo = json['EmailTo'] != null 
      ? [...json['EmailTo']]
      : null;
    emailFrom = json['EmailFrom'];
    ticketType = json['TicketType'];
    fullName = json['FullName'];
    ticketMedia = json['TicketMedia'];
    description = json['Description'];
    ticketDate = json['TicketDate'];
    ticketStatus = json['TicketStatus'];
    ticketCategory = json['TicketCategory'];
    category = json['Category'] != null
        ? new TicketCategoryModel.fromJson(json['Category'])
        : null;
    attachments = json['Attachments'] != null
        ? new AttachmentModel.fromJson(json['Attachments'])
        : null;
    invertedStatus = json['InvertedStatus'];
    invertedStatusDescription = json['InvertedStatusDescription'];
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
    closedDate = json['ClosedDate'];
    action = json['Action'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TicketNumber'] = this.ticketNumber;
    data['TicketResolution'] = this.ticketResolution;
    data['Subject'] = this.subject;
    data['EmailCC'] = this.emailCc;
    if (this.emailTo != null) {
      data['EmailTo'] = this.emailTo;
    }
    data['EmailFrom'] = this.emailFrom;
    data['TicketType'] = this.ticketType;
    data['FullName'] = this.fullName;
    data['TicketMedia'] = this.ticketMedia;
    data['Description'] = this.description;
    data['TicketDate'] = this.ticketDate;
    data['TicketStatus'] = this.ticketStatus;
    data['TicketCategory'] = this.ticketCategory;
    if (this.category != null) {
      data['Category'] = this.category?.toJson();
    }
    if (this.attachments != null) {
      data['Attachments'] = this.attachments?.toJson();
    }
    data['InvertedStatus'] = this.invertedStatus;
    data['InvertedStatusDescription'] = this.invertedStatusDescription;
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
    data['ClosedDate'] = this.closedDate;
    data['Action'] = this.action;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    return data;
  }
}
