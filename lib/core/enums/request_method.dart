import 'package:http/http.dart' as http;


enum RequestMethod {get,post,put,delete}

extension MethodManager on RequestMethod {
  Future<http.Response> apiCall(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    switch (this) {
      case RequestMethod.get:
        return await http.get(url, headers: headers);
      case RequestMethod.post:
        return await http.post(url, headers: headers, body: body);
      case RequestMethod.put:
        return await http.put(url, headers: headers, body: body);
      case RequestMethod.delete:
        return await http.delete(url, headers: headers, body: body);
    }
  }
}