import 'dart:io';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/warning_letter_model.dart';

class WarningLetterService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> warningLetters(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Warning Letters');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetWarningLetters/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<WarningLetterModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(WarningLetterModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
