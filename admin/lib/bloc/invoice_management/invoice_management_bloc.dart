import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/bloc/invoice_management/invoice_management_event.dart';
import 'package:admin/bloc/invoice_management/invoice_management_state.dart';
import 'package:admin/repository/invoice/invoice_repository.dart';
import 'package:admin/repository/invoice_kennel/invoice_kennel_repository.dart';
import 'package:admin/dto/invoice/invoice_response.dart';
import 'package:admin/dto/invoice_kennel/invoice_kennel_dto.dart';

class InvoiceManagementBloc
    extends Bloc<InvoiceManagementEvent, InvoiceManagementState> {
  final InvoiceRepository invoiceRepository;
  final InvoiceKennelRepository invoiceKennelRepository;

  InvoiceManagementBloc({
    required this.invoiceRepository,
    required this.invoiceKennelRepository,
  }) : super(InvoiceManagementInitial()) {
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<LoadInvoiceKennelsEvent>(_onLoadInvoiceKennels);
    on<FilterInvoicesByStatusEvent>(_onFilterInvoicesByStatus);
    on<FilterInvoiceKennelsByStatusEvent>(_onFilterInvoiceKennelsByStatus);
    on<SearchInvoicesEvent>(_onSearchInvoices);
    on<SearchInvoiceKennelsEvent>(_onSearchInvoiceKennels);
    on<ChangeInvoiceTypeEvent>(_onChangeInvoiceType);
    on<ChangePaginationEvent>(_onChangePagination);
  }

  Future<void> _onLoadInvoices(
    LoadInvoicesEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    try {
      emit(InvoiceManagementLoading());

      final medicalInvoices = await invoiceRepository.getAllInvoices();
      final kennelInvoices =
          await invoiceKennelRepository.getAllInvoiceKennels();

      emit(
        InvoiceManagementLoaded(
          medicalInvoices: medicalInvoices,
          kennelInvoices: kennelInvoices,
          filteredMedicalInvoices: medicalInvoices,
          filteredKennelInvoices: kennelInvoices,
          currentType: InvoiceType.medical,
          searchQuery: '',
          currentPage: 0,
          itemsPerPage: 10,
        ),
      );
    } catch (e) {
      emit(InvoiceManagementError(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceKennels(
    LoadInvoiceKennelsEvent event,
    Emitter<InvoiceManagementState> emit,
  ) async {
    try {
      if (state is! InvoiceManagementLoaded) return;

      final currentState = state as InvoiceManagementLoaded;
      final kennelInvoices =
          await invoiceKennelRepository.getAllInvoiceKennels();

      emit(
        currentState.copyWith(
          kennelInvoices: kennelInvoices,
          filteredKennelInvoices: kennelInvoices,
        ),
      );
    } catch (e) {
      emit(InvoiceManagementError(e.toString()));
    }
  }

  void _onFilterInvoicesByStatus(
    FilterInvoicesByStatusEvent event,
    Emitter<InvoiceManagementState> emit,
  ) {
    if (state is! InvoiceManagementLoaded) return;

    final currentState = state as InvoiceManagementLoaded;
    List<InvoiceResponse> filtered = currentState.medicalInvoices;

    if (event.status != null) {
      filtered =
          filtered.where((invoice) => invoice.status == event.status).toList();
    }

    // Apply search filter if exists
    if (currentState.searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (invoice) =>
                    invoice.invoiceCode.toLowerCase().contains(
                      currentState.searchQuery.toLowerCase(),
                    ) ||
                    invoice.user.fullname!.toLowerCase().contains(
                      currentState.searchQuery.toLowerCase(),
                    ) ||
                    invoice.doctor.fullname!.toLowerCase().contains(
                      currentState.searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    emit(
      currentState.copyWith(
        filteredMedicalInvoices: filtered,
        selectedStatus: event.status,
        currentPage: 0,
      ),
    );
  }

  void _onFilterInvoiceKennelsByStatus(
    FilterInvoiceKennelsByStatusEvent event,
    Emitter<InvoiceManagementState> emit,
  ) {
    if (state is! InvoiceManagementLoaded) return;

    final currentState = state as InvoiceManagementLoaded;
    List<InvoiceKennelDto> filtered = currentState.kennelInvoices;

    if (event.status != null) {
      filtered =
          filtered.where((invoice) => invoice.status == event.status).toList();
    }

    // Apply search filter if exists
    if (currentState.searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (invoice) =>
                    invoice.invoiceCode.toLowerCase().contains(
                      currentState.searchQuery.toLowerCase(),
                    ) ||
                    invoice.user.fullname!.toLowerCase().contains(
                      currentState.searchQuery.toLowerCase(),
                    ) ||
                    invoice.doctor.fullname!.toLowerCase().contains(
                      currentState.searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    emit(
      currentState.copyWith(
        filteredKennelInvoices: filtered,
        selectedStatus: event.status,
        currentPage: 0,
      ),
    );
  }

  void _onSearchInvoices(
    SearchInvoicesEvent event,
    Emitter<InvoiceManagementState> emit,
  ) {
    if (state is! InvoiceManagementLoaded) return;

    final currentState = state as InvoiceManagementLoaded;
    List<InvoiceResponse> filtered = currentState.medicalInvoices;

    // Apply status filter if exists
    if (currentState.selectedStatus != null) {
      filtered =
          filtered
              .where((invoice) => invoice.status == currentState.selectedStatus)
              .toList();
    }

    // Apply search filter
    if (event.query.isNotEmpty) {
      filtered =
          filtered
              .where(
                (invoice) =>
                    invoice.invoiceCode.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ||
                    invoice.user.fullname!.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ||
                    invoice.doctor.fullname!.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ),
              )
              .toList();
    }

    emit(
      currentState.copyWith(
        filteredMedicalInvoices: filtered,
        searchQuery: event.query,
        currentPage: 0,
      ),
    );
  }

  void _onSearchInvoiceKennels(
    SearchInvoiceKennelsEvent event,
    Emitter<InvoiceManagementState> emit,
  ) {
    if (state is! InvoiceManagementLoaded) return;

    final currentState = state as InvoiceManagementLoaded;
    List<InvoiceKennelDto> filtered = currentState.kennelInvoices;

    // Apply status filter if exists
    if (currentState.selectedStatus != null) {
      filtered =
          filtered
              .where((invoice) => invoice.status == currentState.selectedStatus)
              .toList();
    }

    // Apply search filter
    if (event.query.isNotEmpty) {
      filtered =
          filtered
              .where(
                (invoice) =>
                    invoice.invoiceCode.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ||
                    invoice.user.fullname!.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ) ||
                    invoice.doctor.fullname!.toLowerCase().contains(
                      event.query.toLowerCase(),
                    ),
              )
              .toList();
    }

    emit(
      currentState.copyWith(
        filteredKennelInvoices: filtered,
        searchQuery: event.query,
        currentPage: 0,
      ),
    );
  }

  void _onChangeInvoiceType(
    ChangeInvoiceTypeEvent event,
    Emitter<InvoiceManagementState> emit,
  ) {
    if (state is! InvoiceManagementLoaded) return;

    final currentState = state as InvoiceManagementLoaded;

    emit(
      currentState.copyWith(
        currentType: event.type,
        selectedStatus: null,
        searchQuery: '',
        currentPage: 0,
      ),
    );
  }

  void _onChangePagination(
    ChangePaginationEvent event,
    Emitter<InvoiceManagementState> emit,
  ) {
    if (state is! InvoiceManagementLoaded) return;

    final currentState = state as InvoiceManagementLoaded;

    emit(currentState.copyWith(currentPage: event.page));
  }
}
