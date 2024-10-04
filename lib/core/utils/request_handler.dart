import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:learingdart/core/enums/request_method.dart';
import 'package:learingdart/core/utils/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalResponseModel {
  String? message;
  bool status;
  String? statusCode;

  LocalResponseModel({
    this.message,
    this.status = false,
    this.statusCode,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'status': status,
      'statusCode': statusCode,
    };
  }

  static LocalResponseModel errorResponse({
    String? message,
    bool? status,
    String? statusCode,
  }) {
    return LocalResponseModel(
      message: message ?? 'An Error has occured on the server',
      status: status ?? false,
      statusCode: statusCode ?? '500',
    );
  }
}

class RequestHandler {
  /// The [urlString] is retrieved from api object.
  /// The [method] is obtained using object.value.method.
  /// For authorized requests, set [authorized] to true.
  /// The [body] parameter stores the request parameters.
  /// The [headersCustom] parameter holds custom header values.
  /// For [RequestMethod.get] and [RequestMethod.delete], append the ID to the [urlString].
  static Future<ResponseBody> call(String urlString, RequestMethod method,
      {bool authorized = true,
      RequestBody? body,
      ApiHeaderType? headersCustom}) async {
    try {
   
      // if (kDebugMode) {
      //   print(urlString);
      //   print(json.encode(body));
      // }

      /// set the Headers
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      Map<String, String> headers = headersCustom ??
          {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            //if (authorized) HttpHeaders.authorizationHeader: token,
          };

      //log(headers.toString());
      

      /// Api call
      final response = await method.apiCall(Uri.parse(urlString),
          headers: headers, body: json.encode(body));

      /// Setting Response Body
      final ResponseBody responseBody =
          json.decode(utf8.decode(response.bodyBytes));

      return responseBody;

    } catch (e) {
      if (kDebugMode) {
        print('There is an issue with : $urlString');
        print(e);
      }
      rethrow;
      //return LocalResponseModel.errorResponse().toMap();
    }
}

}