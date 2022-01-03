import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/complaint_model.dart';
import 'package:ess_mobile/models/ticket_category_model.dart';

class ComplaintService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> complaints(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Complaints');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/complaint/MGet',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<ComplaintModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(ComplaintModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> resolutions(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Resolution');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/complaint/MGetResolution',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<ComplaintModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(ComplaintModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> ticketCategories() async {
    var _apiResponse = ApiResponse.loading('Fetching Ticket Categories');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/complaint/MGetTicketCategories',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TicketCategoryModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(TicketCategoryModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> complaintByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Complaint');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/complaint/MGetByInstanceID/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = ComplaintModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> complaintSave(PlatformFile fileDoc, String data) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final request = http.MultipartRequest('POST',
          Uri.parse('${globals.apiUrl}/ess/complaint/MRequest'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;
      request.files.add(http.MultipartFile(
        'FileUpload',
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

  Future<ApiResponse> updateStatus(String data) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final request = http.MultipartRequest('POST',
          Uri.parse('${globals.apiUrl}/ess/complaint/MRequestUpdateStatus'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;

      final response = await request.send();
      String stream = await response.stream.bytesToString();

      _apiResponse = ApiResponse.completed(json.decode(stream));
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
