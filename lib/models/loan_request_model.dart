import 'package:ess_mobile/models/loan_type_model.dart';

class LoanRequestModel {
  String? idSimulation; 
  String? description;
  double? amount;
  double? netIncome;
  LoanTypeModel? type;
  String? requestDate;
  double? loanValue;
  String? loanSchedule;
  int? periodeLength;
  double? compensationValue;
  double? installmentValue;
  double? incomeAfterInstallment;
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

  LoanRequestModel({
    this.idSimulation, 
    this.description,
    this.amount,
    this.netIncome,
    this.type,
    this.requestDate,
    this.loanValue,
    this.loanSchedule,
    this.periodeLength,
    this.compensationValue,
    this.installmentValue,
    this.incomeAfterInstallment,
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

  LoanRequestModel.fromJson(Map<String, dynamic> json) {
    idSimulation = json['IdSimulation'];
    description = json['Description'];
    amount = json['Amount'];
    netIncome = json['NetIncome'];
    type = json['Type'] != null
        ? new LoanTypeModel.fromJson(json['Type'])
        : null;
    requestDate = json['RequestDate'];
    loanValue = json['LoanValue'];
    loanSchedule = json['LoanSchedule'];
    periodeLength = json['PeriodeLength'];
    compensationValue = json['CompensationValue'];
    installmentValue = json['InstallmentValue'];
    incomeAfterInstallment = json['IncomeAfterInstallment'];
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
    data['IdSimulation'] = this.idSimulation;
    data['Description'] = this.description;
    data['Amount'] = this.amount;
    data['NetIncome'] = this.netIncome;
    if (this.type != null) {
      data['Type'] = this.type?.toJson();
    }
    data['RequestDate'] = this.requestDate;
    data['LoanValue'] = this.loanValue;
    data['LoanSchedule'] = this.loanSchedule;
    data['PeriodeLength'] = this.periodeLength;
    data['CompensationValue'] = this.compensationValue;
    data['InstallmentValue'] = this.installmentValue;
    data['IncomeAfterInstallment'] = this.incomeAfterInstallment;
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
