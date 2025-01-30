import 'package:learingdart/core/enums/request_method.dart';
import 'package:learingdart/core/utils/request_handler.dart';

///Base URL config
const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://183.83.33.156:90/api',
);

///Request Body
typedef RequestBody = Map<String, dynamic>;
///Response Body
typedef ResponseBody = Map<String, dynamic>;
/// Api Header
typedef ApiHeaderType = Map<String, String>;

// Base class for API configuration, containing information such as path, method, authorization, and module.
// The [module] attribute denotes the API's base path, specifying its category.
abstract class ApiConfig {
  String path;
  RequestMethod method;
  bool isAuth;
  String module;

ApiConfig({
    required this.path,
    required this.method,
    this.isAuth = true,
    required this.module,
  });

  /// to generate full URL
  String getUrlString({String? urlParam}) {
    return '$baseUrl$module$path${urlParam ?? ""}';
  }

 /// redirection
  Future<ResponseBody> sendRequest(
      {String? urlParam, RequestBody? body, ApiHeaderType? headersCustom}) {
    return RequestHandler.call(getUrlString(urlParam: urlParam), method,
        authorized: isAuth, body: body, headersCustom: headersCustom);
  }
}