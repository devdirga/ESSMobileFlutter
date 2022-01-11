import 'dart:io';
import 'dart:convert';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/training_model.dart';

class TrainingService {
  RestApi _restApi = RestApi();
  String? _apiToken = globals.appAuth.data;

  Future<ApiResponse> training(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Training');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/training/get',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TrainingModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TrainingModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> trainingHistory(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Training History');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/training/history',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TrainingModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TrainingModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> trainingRegister(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Registering Data');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/training/register',
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

  Future<ApiResponse> trainingReference(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Training Reference');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/training/references/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TrainingReferenceModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TrainingReferenceModel.fromJson(v));
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
