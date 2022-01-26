import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/document_model.dart';

class DocumentService {
  RestApi _restApi = RestApi();
  String? _apiToken = globals.appAuth.data;

  Future<ApiResponse> documents(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Documents');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetDocuments/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<DocumentModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['Document'] = v['UpdateRequest'];
            v['Document']['UpdateRequest'] = 1;
          }

          _data.add(DocumentModel.fromJson(v['Document']));
        });
      }
      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }
    return _apiResponse;
  }

  Future<ApiResponse> documentRequests(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Document Requests');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetDocumentRequests/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<DocumentRequestModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          _data.add(DocumentRequestModel.fromJson(v));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> saveDocumentRequest(PlatformFile fileDoc, String data) async {
    var _apiResponse = ApiResponse.loading('Saving Data');
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${globals.apiUrl}/ess/employee/MSaveDocumentRequest'));
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
}
