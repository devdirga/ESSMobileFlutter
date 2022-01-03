class TicketCategoryModel {
  String? name;
  String? description;
  List<ContactModel>? contacts;
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

  TicketCategoryModel({
    this.name,
    this.description,
    this.contacts,
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

  TicketCategoryModel.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    description = json["Description"];
    if (json['Contacts'] != null) {
      contacts = <ContactModel>[];
      json['Contacts'].forEach((v) {
        contacts?.add(new ContactModel.fromJson(v));
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
    closedDate = json['ClosedDate'];
    action = json['Action'];
    lastUpdate = json['LastUpdate'];
    updateBy = json['UpdateBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['Description'] = this.description;
    if (this.contacts != null) {
      data['Contacts'] = this.contacts?.map((v) => v.toJson()).toList();
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
    data['ClosedDate'] = this.closedDate;
    data['Action'] = this.action;
    data['LastUpdate'] = this.lastUpdate;
    data['UpdateBy'] = this.updateBy;
    return data;
  }
}

class ContactModel {
  String? employeeID;
  String? name;
  String? description;
  String? email;

  ContactModel({
    this.employeeID,
    this.name,
    this.description,
    this.email
  });

  ContactModel.fromJson(Map<String, dynamic> json) {
    employeeID = json['EmployeeID'];
    name = json["Name"];
    description= json["Description"];
    email = json['Email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['EmployeeID'] = this.employeeID;
    data['Name'] = this.name;
    data['Description'] = this.description;
    data['Email'] = this.email;
    return data;
  }
}
