class RawInvoice {
  int invMasSno;
  int invDetSno;
  String? invoiceDate;
  String? paymentType;
  String? invoiceNo;
  String? dueDate;
  String? invoiceExpiredDate;
  int chusMasNo;
  String? chusName;
  int comMasSno;
  String? companyName;
  String? invRemarks;
  String remarks;
  String? vatCategory;
  String? currencyCode;
  String? currencyName;
  double totalWithoutVt;
  double totalVt;
  double total;
  double itemQty;
  double itemUnitPrice;
  double itemTotalAmount;
  double vatPercentage;
  double vatAmount;
  double itemWithoutVat;
  String? itemDescription;
  String? auditBy;
  String? warranty;
  String? vatType;
  String? goodsStatus;
  String? deliveryStatus;
  String? auditDate;
  int? grandCount;
  int? dailyCount;
  String? approvalStatus;
  String? approvalDate;
  String? pDate;
  String? customerIdType;
  String? customerIdNo;
  int zReportSno;
  String? zReportStatus;
  String? zReportStatus1;
  String? zReportDate;
  String? zReportDate1;
  String? zReportDate2;
  String controlNo;
  String? reason;
  String status;
  String? mobile;
  String? email;

  RawInvoice({
    required this.invMasSno,
    required this.invDetSno,
    this.invoiceDate,
    this.paymentType,
    this.invoiceNo,
    this.dueDate,
    this.invoiceExpiredDate,
    required this.chusMasNo,
    this.chusName,
    required this.comMasSno,
    this.companyName,
    this.invRemarks,
    required this.remarks,
    this.vatCategory,
    this.currencyCode,
    this.currencyName,
    required this.totalWithoutVt,
    required this.totalVt,
    required this.total,
    required this.itemQty,
    required this.itemUnitPrice,
    required this.itemTotalAmount,
    required this.vatPercentage,
    required this.vatAmount,
    required this.itemWithoutVat,
    this.itemDescription,
    this.auditBy,
    this.warranty,
    this.vatType,
    this.goodsStatus,
    this.deliveryStatus,
    this.auditDate,
    this.grandCount,
    this.dailyCount,
    this.approvalStatus,
    this.approvalDate,
    this.pDate,
    this.customerIdType,
    this.customerIdNo,
    required this.zReportSno,
    this.zReportStatus,
    this.zReportStatus1,
    this.zReportDate,
    this.zReportDate1,
    this.zReportDate2,
    required this.controlNo,
    this.reason,
    required this.status,
    this.mobile,
    this.email,
  });

  factory RawInvoice.fromJson(Map<String, dynamic> json) {
    return RawInvoice(
      invMasSno: json['Inv_Mas_Sno'],
      invDetSno: json['Inv_Det_Sno'],
      invoiceDate: json['Invoice_Date'],
      paymentType: json['Payment_Type'],
      invoiceNo: json['Invoice_No'],
      dueDate: json['Due_Date'],
      invoiceExpiredDate: json['Invoice_Expired_Date'],
      chusMasNo: json['Chus_Mas_No'],
      chusName: json['Chus_Name'],
      comMasSno: json['Com_Mas_Sno'],
      companyName: json['Company_Name'],
      invRemarks: json['Inv_Remarks'],
      remarks: json['Remarks'],
      vatCategory: json['vat_category'],
      currencyCode: json['Currency_Code'],
      currencyName: json['Currency_Name'],
      totalWithoutVt: json['Total_Without_Vt'],
      totalVt: json['Total_Vt'],
      total: json['Total'],
      itemQty: json['Item_Qty'],
      itemUnitPrice: json['Item_Unit_Price'],
      itemTotalAmount: json['Item_Total_Amount'],
      vatPercentage: json['Vat_Percentage'],
      vatAmount: json['Vat_Amount'],
      itemWithoutVat: json['Item_Without_vat'],
      itemDescription: json['Item_Description'],
      auditBy: json['AuditBy'],
      warranty: json['warrenty'],
      vatType: json['Vat_Type'],
      goodsStatus: json['goods_status'],
      deliveryStatus: json['delivery_status'],
      auditDate: json['Audit_Date'],
      grandCount: json['grand_count'],
      dailyCount: json['daily_count'],
      approvalStatus: json['approval_status'],
      approvalDate: json['approval_date'],
      pDate: json['p_date'],
      customerIdType: json['Customer_ID_Type'],
      customerIdNo: json['Customer_ID_No'],
      zReportSno: json['Zreport_Sno'],
      zReportStatus: json['Zreport_Status'],
      zReportStatus1: json['Zreport_Status1'],
      zReportDate: json['Zreport_Date'],
      zReportDate1: json['Zreport_Date1'],
      zReportDate2: json['Zreport_Date2'],
      controlNo: json['Control_No'] ?? '',
      reason: json['Reason'],
      status: json['Status'],
      mobile: json['Mobile'],
      email: json['Email'],
    );
  }
}
