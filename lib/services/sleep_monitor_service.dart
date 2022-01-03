import 'dart:io';
import 'dart:convert';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/sleep_monitor_model.dart';

class SleepMonitorService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> sleepmonitor(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Sleep Monitor');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/timemanagement/sleepmonitor/gets/range',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<SleepMonitorModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(SleepMonitorModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> sleepmonitorSave(
      String route, Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/timemanagement/sleepmonitor/$route',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> sleepmonitorDelete(String id) async {
    var _apiResponse = ApiResponse.loading('Deleting Data');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/timemanagement/sleepmonitor/delete/$id',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> sleepmonitorDiscard(String id) async {
    var _apiResponse = ApiResponse.loading('Discarding Changes');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/timemanagement/sleepmonitor/discardChange/$id',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
