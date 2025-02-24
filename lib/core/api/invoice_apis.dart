import 'package:learingdart/core/enums/request_method.dart';
import 'package:learingdart/core/utils/api_config.dart';
 class InvoiceApis extends ApiConfig { 
 InvoiceApis(
      {super.module = '/Invoice',
       required super.path,
       required super.method,
      super.isAuth = false});

 static final getchDetails = InvoiceApis(path: '/GetchDetails', method: RequestMethod.post);
  static final addDCode = InvoiceApis(path: '/AddDCode', method: RequestMethod.post);
static final isExistInvoice = InvoiceApis(method: RequestMethod.get,path: '/IsExistInvoice');
  static final findInvoice = InvoiceApis(method: RequestMethod.get,path: '/FindInvoice');
 }
