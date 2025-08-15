class EndPoints {
  // static const String baseUrl = "http://192.168.1.16:8080/api/clinic";
  static const String baseUrl = "http://localhost:8080/api/clinic";
  static const String wsUrl = "ws://localhost:8080/api/clinic/ws";
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String getRevenueInvoice = "$baseUrl/invoices/admin/revenue";
  static const String getRevenueInvoiceKennel =
      "$baseUrl/invoice/kennels/admin/revenue";
  static const String getListDoctor = "$baseUrl/users/doctors";
  static const String getLogUserCredit = "$baseUrl/log_user_credits";
  static const getListCustomer = "$baseUrl/users/admin/user";
  static const String getListPetByUserId = "$baseUrl/pets/user";
  static const String getAllDoctorsAppointmentsInWeek =
      "$baseUrl/appointments/doctors/week";
  static const String getAllInvoices = "$baseUrl/invoices/admin";
  static const String getAllInvoiceKennels = "$baseUrl/invoice/kennels/admin";
  static const String getAllMedicalRecords = "$baseUrl/medical_records/admin";
  static const String getPrescriptionByMedicalRecord =
      "$baseUrl/prescriptions/medical_record";
  static const String getKennelByPetId = "$baseUrl/kennels/book/pet";

  static const String getAllKennelValid = "$baseUrl/kennels";
  static const String getAllKennelAll = "$baseUrl/kennels/all";
  static const String getAllService = "$baseUrl/services/admin";
  static const String services = "$baseUrl/services";
  static const String getInvetory = "$baseUrl/inventory";
  static const String importInventory = "$baseUrl/inventory/import";
  static const String getAllCategories = "$baseUrl/categories";

  static const String getAllAccount = "$baseUrl/account/admin";
  static const String createAccount = "$baseUrl/account/admin/doctor";
}
