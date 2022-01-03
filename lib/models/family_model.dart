class FamilyModel {
  dynamic old;
  String? name;
  String? firstName;
  String? lastName;
  String? middleName;
  String? nik;
  String? noTelp;
  String? email;
  String? birthplace;
  String? birthdate;
  int? gender;
  String? genderDescription;
  String? job;
  int? religion;
  String? religionDescription;
  int? purpose;
  String? relationship;
  String? relationshipDescription;
  String? noBPJS;
  String? noInsurance;
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

  FamilyModel({
    this.old,
    this.name,
    this.firstName,
    this.lastName,
    this.middleName,
    this.nik,
    this.noTelp,
    this.email,
    this.birthplace,
    this.birthdate,
    this.gender,
    this.genderDescription,
    this.job,
    this.religion,
    this.religionDescription,
    this.purpose,
    this.relationship,
    this.relationshipDescription,
    this.noBPJS,
    this.noInsurance,
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

  FamilyModel.fromJson(Map<String, dynamic> json) {
    old = json['Old'];
    name = json['Name'];
    firstName = json['FirstName'];
    lastName = json['LastName'];
    middleName = json['MiddleName'];
    nik = json['NIK'];
    noTelp = json['NoTelp'];
    email = json['Email'];
    birthplace = json['Birthplace'];
    birthdate = json['Birthdate'];
    gender = json['Gender'];
    genderDescription = json['GenderDescription'];
    job = json['Job'];
    religion = json['Religion'];
    religionDescription = json['ReligionDescription'];
    purpose = json['Purpose'];
    relationship = json['Relationship'];
    relationshipDescription = json['RelationshipDescription'] != null ? json['RelationshipDescription'] : '';
    noBPJS = json['NoBPJS'];
    noInsurance = json['NoInsurance'];
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
    data['Name'] = this.name;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['MiddleName'] = this.middleName;
    data['NIK'] = this.nik;
    data['NoTelp'] = this.noTelp;
    data['Email'] = this.email;
    data['Birthplace'] = this.birthplace;
    data['Birthdate'] = this.birthdate;
    data['Gender'] = this.gender;
    data['GenderDescription'] = this.genderDescription;
    data['Job'] = this.job;
    data['Religion'] = this.religion;
    data['ReligionDescription'] = this.religionDescription;
    data['Purpose'] = this.purpose;
    data['Relationship'] = this.relationship;
    data['RelationshipDescription'] = this.relationshipDescription;
    data['NoBPJS'] = this.noBPJS;
    data['NoInsurance'] = this.noInsurance;
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
