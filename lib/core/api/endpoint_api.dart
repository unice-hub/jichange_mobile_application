class ApiEndpoints {
  static const String baseUrl = 'http://192.168.100.50:98/api';//define the static constant url

  static const String changePwd= '$baseUrl/Forgot/ChangePwd';
  static const String forgotPwd = '$baseUrl/Forgot/GetMobile';
  static const String logins = '$baseUrl/LoginUser/AddLogins';
  static const String vendorReg = '$baseUrl/Branch/GetBranchLists';
  static const String verifyAccount = '$baseUrl/Forgot/OtpValidate';
  static const String controlNumber= '$baseUrl/Invoice/GetControl';
  static const String accountNumber= '$baseUrl/Company/CheckAccount';
  static const String submitData= '$baseUrl/Company/AddCompanyBankL';

}