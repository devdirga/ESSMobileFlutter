import 'package:ess_mobile/models/loan_period_model.dart';

class LoanTypeModel {
  String? id;
  String? name;
  String? description;
  int? minimumRangePeriode;
  int? maximumRangePeriode;
  double? maximumLoan;
  LoanPeriodModel? detail;
  List<String>? email;

  LoanTypeModel({
    this.id,
    this.name,
    this.description,
    this.minimumRangePeriode,
    this.maximumRangePeriode,
    this.maximumLoan,
    this.detail,
    this.email
  });

  LoanTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    description = json['Description'];
    minimumRangePeriode = json['MinimumRangePeriode'];
    maximumRangePeriode = json['MaximumRangePeriode'];
    maximumLoan = json['MaximumLoan'];
    detail = json['Detail'] != null
        ? new LoanPeriodModel.fromJson(json['Detail'])
        : null;
    email = json['Email'] != null 
      ? [...json['Email']]
      : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["Id"] = this.id;
    data["Name"] = this.name;
    data['Description'] = this.description;
    data['MinimumRangePeriode'] = this.minimumRangePeriode;
    data['MaximumRangePeriode'] = this.maximumRangePeriode;
    data['MaximumLoan'] = this.maximumLoan;
    if (this.detail != null) {
      data['Detail'] = this.detail?.toJson();
    }
    if (this.email != null) {
      data['Email'] = this.email;
    }
    return data;
  }
}
