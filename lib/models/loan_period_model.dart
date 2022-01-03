class LoanPeriodModel {
  String? idDetail;
  String? idLoan;
  int? idLoanType;
  String? loanTypeName;
  String? periodeName;
  int? minimumRangePeriode;
  int? maximumRangePeriode;
  double? interest;
  int? methode;
  String? methodeName;
  int? periodType;
  int? minimumRangeLoanPeriode;
  int? maximumRangeLoanPeriode;
  double? maximumLoad;

  LoanPeriodModel({
    this.idDetail,
    this.idLoan,
    this.idLoanType,
    this.loanTypeName,
    this.periodeName,
    this.minimumRangePeriode,
    this.maximumRangePeriode,
    this.interest,
    this.methode,
    this.methodeName,
    this.periodType,
    this.minimumRangeLoanPeriode,
    this.maximumRangeLoanPeriode,
    this.maximumLoad
  });

  LoanPeriodModel.fromJson(Map<String, dynamic> json) {
    idDetail = json['IdDetail'];
    idLoan = json['IdLoan'];
    idLoanType = json['IdLoanType'];
    loanTypeName = json['LoanTypeName'];
    periodeName = json['PeriodeName'];
    minimumRangePeriode = json['MinimumRangePeriode'];
    maximumRangePeriode = json['MaximumRangePeriode'];
    interest = json['Interest'];
    methode = json['Methode'];
    methodeName = json['MethodeName'];
    periodType = json['PeriodType'];
    minimumRangeLoanPeriode = json['MinimumRangeLoanPeriode'];
    maximumRangeLoanPeriode = json['MaximumRangeLoanPeriode'];
    maximumLoad = json['MaximumLoad'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IdDetail'] = this.idDetail;
    data['IdLoan'] = this.idLoan;
    data['IdLoanType'] = this.idLoanType;
    data['LoanTypeName'] = this.loanTypeName;
    data['PeriodeName'] = this.periodeName;
    data['MinimumRangePeriode'] = this.minimumRangePeriode;
    data['MaximumRangePeriode'] = this.maximumRangePeriode;
    data['Interest'] = this.interest;
    data['Methode'] = this.methode;
    data['MethodeName'] = this.methodeName;
    data['PeriodType'] = this.periodType;
    data['MinimumRangeLoanPeriode'] = this.minimumRangeLoanPeriode;
    data['MaximumRangeLoanPeriode'] = this.minimumRangeLoanPeriode;
    data['MaximumLoad'] = this.maximumLoad;
    return data;
  }
}
