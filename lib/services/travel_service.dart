import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/travel_model.dart';

class TravelService {
  RestApi _restApi = RestApi();
  String? _apiToken = globals.appAuth.data;

  Future<ApiResponse> travel(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Travel');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/travel/get',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TravelModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TravelModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> travelSave(
      String route, PlatformFile fileDoc, String data, String reason) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${globals.apiUrl}/travel/$route'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['jsonData'] = data;
      request.fields['reason'] = reason;
      request.files.add(http.MultipartFile(
        'fileUpload',
        fileDoc.readStream!,
        fileDoc.size,
        filename: fileDoc.name,
      ));

      final response = await request.send();
      String stream = await response.stream.bytesToString();

      _apiResponse = ApiResponse.completed(json.decode(stream));
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> travelDelete(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Deleting Data');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/travel/delete',
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

  Future<ApiResponse> travelDiscard(String id) async {
    var _apiResponse = ApiResponse.loading('Discarding Changes');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/travel/discardChange/$id',
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

  Future<ApiResponse> travelByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Travel');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/travel/getByInstance/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = TravelModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
