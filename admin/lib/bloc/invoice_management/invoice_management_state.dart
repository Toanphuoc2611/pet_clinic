import 'package:admin/dto/invoice/invoice_response.dart';
import 'package:admin/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:admin/bloc/invoice_management/invoice_management_event.dart';

abstract class InvoiceManagementState {}

class InvoiceManagementInitial extends InvoiceManagementState {}

class InvoiceManagementLoading extends InvoiceManagementState {}

class InvoiceManagementLoaded extends InvoiceManagementState {
  final List<InvoiceResponse> medicalInvoices;
  final List<InvoiceKennelDto> kennelInvoices;
  final List<InvoiceResponse> filteredMedicalInvoices;
  final List<InvoiceKennelDto> filteredKennelInvoices;
  final InvoiceType currentType;
  final int? selectedStatus;
  final String searchQuery;
  final int currentPage;
  final int itemsPerPage;

  InvoiceManagementLoaded({
    required this.medicalInvoices,
    required this.kennelInvoices,
    required this.filteredMedicalInvoices,
    required this.filteredKennelInvoices,
    required this.currentType,
    this.selectedStatus,
    required this.searchQuery,
    required this.currentPage,
    required this.itemsPerPage,
  });

  List<dynamic> get currentInvoices {
    final invoices =
        currentType == InvoiceType.medical
            ? filteredMedicalInvoices
            : filteredKennelInvoices;

    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, invoices.length);

    return invoices.sublist(startIndex, endIndex);
  }

  int get totalPages {
    final totalItems =
        currentType == InvoiceType.medical
            ? filteredMedicalInvoices.length
            : filteredKennelInvoices.length;
    return (totalItems / itemsPerPage).ceil();
  }

  int get totalItems {
    return currentType == InvoiceType.medical
        ? filteredMedicalInvoices.length
        : filteredKennelInvoices.length;
  }

  InvoiceManagementLoaded copyWith({
    List<InvoiceResponse>? medicalInvoices,
    List<InvoiceKennelDto>? kennelInvoices,
    List<InvoiceResponse>? filteredMedicalInvoices,
    List<InvoiceKennelDto>? filteredKennelInvoices,
    InvoiceType? currentType,
    int? selectedStatus,
    String? searchQuery,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return InvoiceManagementLoaded(
      medicalInvoices: medicalInvoices ?? this.medicalInvoices,
      kennelInvoices: kennelInvoices ?? this.kennelInvoices,
      filteredMedicalInvoices:
          filteredMedicalInvoices ?? this.filteredMedicalInvoices,
      filteredKennelInvoices:
          filteredKennelInvoices ?? this.filteredKennelInvoices,
      currentType: currentType ?? this.currentType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}

class InvoiceManagementError extends InvoiceManagementState {
  final String message;
  InvoiceManagementError(this.message);
}
