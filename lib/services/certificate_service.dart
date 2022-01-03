import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/certificate_model.dart';

class CertificateService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> certificates(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Certificates');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetCertificates/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<CertificateModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['Certificate'] = v['UpdateRequest'];
            v['Certificate']['UpdateRequest'] = 1;
          }

          _data.add(CertificateModel.fromJson(v['Certificate']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> certificateByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Certificate');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetCertificateByInstanceID/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = CertificateModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> certificateSave(
      String route, PlatformFile fileDoc, String data, String reason) async {
    var _apiResponse = ApiResponse.loading('Saving Data');

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${globals.apiUrl}/ess/employee/MSaveCertificate'));
      Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer $_apiToken'};
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;
      request.fields['Reason'] = reason;
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

  Future<ApiResponse> certificateDelete(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Deleting Data');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/employee/MRemoveCertificate',
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

  Future<ApiResponse> certificateDiscard(String id) async {
    var _apiResponse = ApiResponse.loading('Discarding Changes');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MDiscardCertificateChange/$id',
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
