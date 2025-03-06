class ApiEndpoints {
     // static const String baseUrl = 'http://59.97.23.99:90/api';//define the static constant url
      static const String baseUrl = 'http://183.83.33.156:90/api';//define the static constant url
    // static const String baseUrl = 'http://192.168.100.50:98/api';//define the static constant url
    //static const String baseUrl = 'http://192.168.100.17:96/api';//define the static constant url

  static const String changePwd= '$baseUrl/Forgot/ChangePwd'; //change_password.dart

  static const String forgotPwd = '$baseUrl/Forgot/GetMobile'; //forgot_password.dart

  static const String logins = '$baseUrl/LoginUser/AddLogins'; //login_page.dart

  static const String vendorReg = '$baseUrl/Branch/GetBranchLists'; //vendor_registartion_page.dart

  static const String verifyAccount = '$baseUrl/Forgot/OtpValidate'; //verify_account.dart

  static const String controlNumber= '$baseUrl/Invoice/GetControl'; //login_page.dart

  static const String accountNumber= '$baseUrl/Company/CheckAccount';//vendor_registartion_page.dart

  static const String submitData= '$baseUrl/Company/AddCompanyBankL'; //vendor_registartion_page.dart

  static const String allTransactions= '$baseUrl/Invoice/GetchTransact_Inv'; //all_transactions.dart

  static const String customerName= '$baseUrl/Invoice/GetCustomersS';  //edit_invoice.dart //create_invoice.dart //amend_invoice.dart //create_invoice_for_specific_customer.dart

  static const String customerData= '$baseUrl/RepCustomer/GetcustDetReport'; //customer_section.dart //customer_details.dart
  
  static const String getCompanyS= '$baseUrl/Invoice/GetcompanyS';  //home_section.dart

  static const String vendorUsers = '$baseUrl/CompanyUsers/GetCompanyUserss'; //vendor_users_section.dart

  static const String getOverview = '$baseUrl/Setup/Overview'; //home_section.dart //overview_page.dart

  static const String invoiceData = '$baseUrl/Invoice/GetSignedDetails'; //home_section.dart //overview_page.dart

  static const String getPaymentReport ='$baseUrl/Invoice/GetPaymentReport'; //completed_payments.dart

  static const String getCustDetails = '$baseUrl/InvoiceRep/GetCustDetails'; //completed_payments.dart //invoice_details_page.dart //amendments_details_page.dart  //payment_details_page.dart //cancelled_invoice_page.dart

  static const String getInvReport = '$baseUrl/RepCompInvoice/GetInvReport'; //completed_payments.dart //invoice_details_page.dart //amendments_details_page.dart //cancelled_invoice_page.dart

  static const String getAmendReport = '$baseUrl/Invoice/GetAmendReport'; //amendments_details_page.dart

  static const String getInvoiceTransact = '$baseUrl/Invoice/GetchTransact_B'; //payment_details_page.dart

  static const String getCancelledInvoice = '$baseUrl/Invoice/GetCancelReport'; //cancelled_invoice_page.dart

  static const String getInvoiceAuditTrails = '$baseUrl/AuditTrail/report'; //audit_trails_page.dart

  static const String getAuditTypes = '$baseUrl/AuditTrail/GetAvailableAuditTypes'; //audit_trails_page.dart

  static const String getPages = '$baseUrl/AuditTrail/GetAvailablePages'; //audit_trails_page.dart

  static const String getDetails = '$baseUrl/Invoice/GetchDetails'; //overview_page.dart

  static const String editCompanyUsers = '$baseUrl/CompanyUsers/EditCompanyUserss'; //settings_page.dart

  static const String getLogout = '$baseUrl/LoginUser/Logout'; //settings_page.dart

  static const String getUpdatePwd = '$baseUrl/Updatepwd/UpdatePwd'; //settings_page.dart

  static const String addInvoice = '$baseUrl/Invoice/AddInvoice'; //created_invoice_tab.dart //edit_invoice_tab.dart

  static const String addCancel = '$baseUrl/Invoice/AddCancel'; //created_invoice_tab.dart

  static const String addAmend = '$baseUrl/Invoice/AddAmend'; // amend_invoice.dart

  static const String getFindInvoice = '$baseUrl/Invoice/FindInvoice'; //created_invoice_tab.dart

  static const String getCurrency = '$baseUrl/Invoice/GetCurrency'; //edit_invoice_tab.dart //amend_invoice.dart

  static const String getRoleData = '$baseUrl/Role/GetRolesAct'; //vendor_users_section.dart

  static const String getVendorApi = '$baseUrl/CompanyUsers/AddCompanyUser'; //vendor_users_section.dart

  static const String resendCredentials = '$baseUrl/CompanyUsers/ResendCredentials'; //vendor_users_section.dart

  static const String addCustomer = '$baseUrl/Customer/AddCustomer'; //customer_section.dart

  static const String getCustbyId = '$baseUrl/Customer/GetCustbyId'; //customer_section.dart

  static const String deleteCust = '$baseUrl/Customer/DeleteCust'; //customer_section.dart

}