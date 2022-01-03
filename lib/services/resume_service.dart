import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:ess_mobile/utils/globals.dart' as globals;
import 'package:ess_mobile/utils/rest_api.dart';
import 'package:ess_mobile/utils/api_response.dart';
import 'package:ess_mobile/models/response_model.dart';
import 'package:ess_mobile/models/resume_model.dart';
import 'package:ess_mobile/models/bank_account_model.dart';
import 'package:ess_mobile/models/tax_model.dart';
import 'package:ess_mobile/models/identification_model.dart';
import 'package:ess_mobile/models/electronic_address_model.dart';

class ResumeService {
  RestApi _restApi = RestApi();
  String _apiToken = globals.appAuth.data!;

  Future<ApiResponse> profile(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Profile');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGet/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        if (response['Data']['Employee'] != null) {
          _res.data = EmployeeModel.fromJson(response['Data']['Employee']);
        }

        if (response['Data']['updateRequest'] != null) {
          _res.data = EmployeeModel.fromJson(response['Data']['UpdateRequest']);
          _res.data.updateRequest = 1;
        }
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> profileByInstance(
      String employeeId, String instanceId) async {
    var _apiResponse = ApiResponse.loading('Fetching Profile');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetByInstanceID/$employeeId/$instanceId',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        _res.data = EmployeeModel.fromJson(response['Data']);
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> profileDiscard(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Discarding Changes');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MDiscard/${body['EmployeeID']}',
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

  Future<ApiResponse> profileUpdate(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Updating Profile');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/employee/MUpdate',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        if (response['Data']['Employee'] != null) {
          _res.data = EmployeeModel.fromJson(response['Data']['Employee']);
        }
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> profileUpdateRequest(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Updating Profile');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/ess/employee/MUpdateRequestResume',
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

  Future<ApiResponse> profileCancelRequest(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Cancel Request');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/employee/cancelRequest/resume',
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

  Future<ApiResponse> profilePicture(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Updating Profile Picture');

    try {
      final response = await _restApi.post(
        '${globals.apiUrl}/employee/updateprofile',
        body: body,
        headers: {
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

  Future<ApiResponse> address(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Address');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetAddress/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);

      if (response['Data'] != null) {
        if (response['Data']['Address'] != null) {
          _res.data = AddressModel.fromJson(response['Data']['Address']);
        }

        if (response['Data']['updateRequest'] != null) {
          _res.data = AddressModel.fromJson(response['Data']['UpdateRequest']);
        }
      }

      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> bankAccounts(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Bank Account');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetBankAccounts/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<BankAccountModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['BankAccount'] = v['UpdateRequest'];
            v['BankAccount']['UpdateRequest'] = 1;
          }

          _data.add(BankAccountModel.fromJson(v['BankAccount']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> taxes(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Taxes');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetTaxes/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<TaxModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['Tax'] = v['UpdateRequest'];
            v['Tax']['UpdateRequest'] = 1;
          }

          _data.add(TaxModel.fromJson(v['Tax']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> identifications(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Identifications');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetIdentifications/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<IdentificationModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['Identification'] = v['UpdateRequest'];
            v['Identification']['UpdateRequest'] = 1;
          }

          _data.add(IdentificationModel.fromJson(v['Identification']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> electronicAddresses(Map<String, dynamic> body) async {
    var _apiResponse = ApiResponse.loading('Fetching Electronic Addresses');

    try {
      final response = await _restApi.get(
        '${globals.apiUrl}/ess/employee/MGetElectronicAddresses/${body['EmployeeID']}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        },
      );

      ResponseModel _res = ResponseModel.fromJson(response);
      List<ElectronicAddressModel> _data = [];

      if (response['Data'] != null) {
        response['Data'].forEach((v) {
          if (v['UpdateRequest'] != null) {
            v['ElectronicAddress'] = v['UpdateRequest'];
            v['ElectronicAddress']['UpdateRequest'] = 1;
          }

          _data.add(ElectronicAddressModel.fromJson(v['ElectronicAddress']));
        });
      }

      _res.data = _data;
      _apiResponse = ApiResponse.completed(_res);
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }

  Future<ApiResponse> fileUpload(
      String route, PlatformFile fileDoc, String data) async {
    var _apiResponse = ApiResponse.loading('Uploading Files');

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${globals.apiUrl}/ess/employee/$route'));
      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $_apiToken',
        'Content-Type': 'multipart/form-data'
      };
      
      request.headers.addAll(headers);
      request.fields['JsonData'] = data;
      request.files.add(http.MultipartFile(
        'FileUpload',
        fileDoc.readStream!,
        fileDoc.size,
        filename: fileDoc.name,
      ));

      print(request.headers);
      final response = await request.send();
      String stream = await response.stream.bytesToString();

      _apiResponse = ApiResponse.completed(json.decode(stream));
    } catch (e) {
      _apiResponse = ApiResponse.error(e.toString());
    }

    return _apiResponse;
  }
}
