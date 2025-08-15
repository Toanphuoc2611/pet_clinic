class EndPoints {
  static const String baseUrl = "http://192.168.187.222:8080/api/clinic";
  //   static const String baseUrl = "http://10.0.2.2:8080/api/clinic";
  static const String wsUrl = "ws://192.168.187.222:8080/api/clinic/ws";
  //   static const String wsUrl = "ws://10.0.2.2:8080/api/clinic/ws";
  // static const String baseUrl = "http://localhost:8080/api/clinic";
  // static const String wsUrl = "ws://localhost:8080/api/clinic/ws";
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String refeshToken = "$baseUrl/auth/refresh-token";
  static const String register = "$baseUrl/account/register";
  static const String sendOtp =
      "$baseUrl/send-otp"; // This is Api used to verify phone number
  static const String redirectVnpay = "$baseUrl/vnpay/payment";
  static const String getUser = "$baseUrl/users/user";
  static const String searchUsers = "$baseUrl/users/search";
  static const String handlePet =
      "$baseUrl/pets/pet"; // this is Api used to handle pet (create, update, delete) by user
  static const String getPets = "$baseUrl/pets";
  static const String uploadAvatarPet = "$baseUrl/upload/avatar/pet";
  static const String uploadAvatarUser = "$baseUrl/upload/avatar/user";
  static const String searchPetByName = "$baseUrl/pets/search";
  static const String getListAppointment = "$baseUrl/appointments";
  static const String getAllServices = "$baseUrl/services";
  static const String getListDoctor = "$baseUrl/users/doctors";
  static const String appointment =
      "$baseUrl/appointments/doctor"; // This is Api used to get doctor's schedule or create appointment for this doctor
  static const String handleAppointment =
      "$baseUrl/appointments/appointment"; // This is Api used to handle appointment (create, update, delete) by user
  static const String getProvinces = "$baseUrl/address/provinces";
  static const String getDistricts = "$baseUrl/address/districts";
  static const String getWards = "$baseUrl/address/wards";
  static const String getBreedsBySpecies =
      "$baseUrl/breeds"; // This is Api used to get breeds by species
  static const String getInvoiceDepositUser = "$baseUrl/deposit";
  static const String paymentInvoiceDeposit = "$baseUrl/deposit/payment";
  static const String getPetKennelvalid = "$baseUrl/pets/kennel/valid";
  static const String getKennels = "$baseUrl/kennels";
  static const String getUserCredit = "$baseUrl/user_credits/user";
  static const String getAllBookKennels = "$baseUrl/kennels/book";
  static const String bookKennel = "$baseUrl/kennels/book";
  static const String cancelBookingKennel = "$baseUrl/kennels/book/cancel";
  static const String getInvoiceDepositKennel = "$baseUrl/deposit/kennel";
  static const String getInvoiceDepositAppoint = "$baseUrl/deposit/appointment";
  static const String getMedicalRecordByUser = "$baseUrl/medical_records/pet";
  static const String getInvoiceByUser = "$baseUrl/invoices/user";
  static const String getInvoiceKennelsByUser = "$baseUrl/invoice/kennels/user";
  static const String getListMedicalRecordByPet =
      "$baseUrl/medical_history/pet";
  // Doctor
  static const String getAppointmentOfDoctorByDate =
      "$baseUrl/appointments/doctor/date"; // This is Api used to get appointments today of doctor

  static const getKennelOfDoctorToday =
      "$baseUrl/kennels/book/doctor/today"; // This is Api used to get kennels today of doctor

  static const getAllMedications = "$baseUrl/medications";
  static const getAllCategories = "$baseUrl/categories";
  static const createPrescription = "$baseUrl/prescriptions/create";
  static const getListMedicalRecord = "$baseUrl/medical_records/doctor";
  static const getPrescriptionsByMedicalRecord =
      "$baseUrl/prescriptions/medical_record";
  static const getKennelByPetId = "$baseUrl/kennels/book/pet";
  static const paymentInvoice = "$baseUrl/invoices/payment";
  static const updateStatusKennel = "$baseUrl/kennels/book";
  static const completeKennelBooking = "$baseUrl/kennels/book/complete";
  static const paymentInvoiceKennel = "$baseUrl/invoice/kennels/payment";
  static const getInvoicesByDoctor = "$baseUrl/invoices/doctor";
  static const getInvoiceKennelsByDoctor = "$baseUrl/invoice/kennels/doctor";
  static const getPetByUserId = "$baseUrl/pets/user";
  static const createPrescriptionByDoctor =
      "$baseUrl/prescriptions/doctor/create";
}
