import 'dart:io';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/payslip_model.dart';
import 'package:ess_mobile/models/loan_type_model.dart';
import 'package:ess_mobile/models/loan_period_model.dart';

class PayrollService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> payslip(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Payslip');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/payroll/MGetPaySlip/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<PayslipModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(PayslipModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> getLoanTypes(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Loan Types');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/payroll/MListLoanType',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<LoanTypeModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          var o = LoanTypeModel.fromJson(v);
          if (!_data.any((x) => x.id == o.id)) _data.add(o);
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> getLoanMethods(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Loan Methods');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/payroll/MListLoanMethod',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<String> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(v);
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> getLoanPeriods(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Loan Periods');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/payroll/MListLoanPeriod',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<LoanPeriodModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(LoanPeriodModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> getLatestPayslip(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Simulasi Pinjaman');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/payroll/MGetLatestPaySlip/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      _res.data = PayslipModel.fromJson(response['Data']);
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
