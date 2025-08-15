import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/bloc/inventory_management/inventory_management_event.dart';
import 'package:admin/bloc/inventory_management/inventory_management_state.dart';
import 'package:admin/repository/inventory/inventory_repository.dart';
import 'package:admin/repository/medication/medication_repository.dart';
import 'package:admin/dto/inventory/Inventory_dto.dart';
import 'package:admin/dto/inventory/import_inventory.dart';
import 'package:admin/dto/inventory/Medication_import_request.dart';
import 'package:admin/dto/inventory/update_medication_status.dart';
import 'package:admin/dto/medication/category_dto.dart';

class InventoryManagementBloc
    extends Bloc<InventoryManagementEvent, InventoryManagementState> {
  final InventoryRepository inventoryRepository;
  final MedicationRepository medicationRepository;

  InventoryManagementBloc({
    required this.inventoryRepository,
    required this.medicationRepository,
  }) : super(InventoryManagementInitial()) {
    on<LoadInventoryEvent>(_onLoadInventory);
    on<SearchInventoryEvent>(_onSearchInventory);
    on<FilterInventoryByStockEvent>(_onFilterInventoryByStock);
    on<FilterInventoryByCategoryEvent>(_onFilterInventoryByCategory);
    on<ImportExistingMedicationEvent>(_onImportExistingMedication);
    on<ImportNewMedicationEvent>(_onImportNewMedication);
    on<UpdateMedicationStatusEvent>(_onUpdateMedicationStatus);
    on<ChangePaginationEvent>(_onChangePagination);
    on<RefreshInventoryEvent>(_onRefreshInventory);
  }

  Future<void> _onLoadInventory(
    LoadInventoryEvent event,
    Emitter<InventoryManagementState> emit,
  ) async {
    // Emit loading state
    emit(InventoryManagementLoading());
    try {
      // Fetch inventory and categories
      final inventory = await inventoryRepository.getAllInventory();
      final categories = await medicationRepository.getAllCategories();
      // Emit loaded state with fetched data
      _emitLoadedState(emit, inventory, '', 0, null, null, categories);
    } catch (e) {
      // Emit error state with message
      emit(
        InventoryManagementError('Cannot load inventory data: ${e.toString()}'),
      );
    }
  }

  void _onSearchInventory(
    SearchInventoryEvent event,
    Emitter<InventoryManagementState> emit,
  ) {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allInventory,
        event.query,
        0,
        currentState.stockFilter,
        currentState.selectedCategoryId,
        currentState.categories,
      );
    }
  }

  void _onFilterInventoryByStock(
    FilterInventoryByStockEvent event,
    Emitter<InventoryManagementState> emit,
  ) {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allInventory,
        currentState.searchQuery,
        0,
        event.stockFilter,
        currentState.selectedCategoryId,
        currentState.categories,
      );
    }
  }

  void _onFilterInventoryByCategory(
    FilterInventoryByCategoryEvent event,
    Emitter<InventoryManagementState> emit,
  ) {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allInventory,
        currentState.searchQuery,
        0,
        currentState.stockFilter,
        event.categoryId,
        currentState.categories,
      );
    }
  }

  Future<void> _onImportExistingMedication(
    ImportExistingMedicationEvent event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      emit(InventoryManagementActionLoading());

      try {
        final request = ImportInventory(
          medicationId: event.medicationId,
          quantity: event.quantity,
          price: event.price,
        );

        await inventoryRepository.importInventory(request);

        // Reload inventory
        final inventory = await inventoryRepository.getAllInventory();

        // Emit success state
        emit(InventoryManagementActionSuccess('Nhập kho thành công'));

        // Sau đó emit loaded state để đảm bảo UI hiển thị đúng
        _emitLoadedState(
          emit,
          inventory,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.stockFilter,
          currentState.selectedCategoryId,
          currentState.categories,
        );
      } catch (e) {
        emit(
          InventoryManagementActionError('Không thể nhập kho: ${e.toString()}'),
        );
      }
    }
  }

  Future<void> _onImportNewMedication(
    ImportNewMedicationEvent event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      emit(InventoryManagementActionLoading());

      try {
        final request = MedicationImportRequest(
          name: event.name,
          description: event.description,
          unit: event.unit,
          price: event.price,
          quantity: event.quantity,
          categoryId: event.categoryId,
        );

        await inventoryRepository.importMedicationNew(request);
        final inventory = await inventoryRepository.getAllInventory();

        emit(InventoryManagementActionSuccess('Thêm thuốc mới thành công'));

        _emitLoadedState(
          emit,
          inventory,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.stockFilter,
          currentState.selectedCategoryId,
          currentState.categories,
        );
      } catch (e) {
        emit(
          InventoryManagementActionError(
            'Không thể thêm thuốc mới: ${e.toString()}',
          ),
        );
      }
    }
  }

  void _onChangePagination(
    ChangePaginationEvent event,
    Emitter<InventoryManagementState> emit,
  ) {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      _emitLoadedState(
        emit,
        currentState.allInventory,
        currentState.searchQuery,
        event.page,
        currentState.stockFilter,
        currentState.selectedCategoryId,
        currentState.categories,
      );
    }
  }

  Future<void> _onRefreshInventory(
    RefreshInventoryEvent event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      try {
        final inventory = await inventoryRepository.getAllInventory();
        _emitLoadedState(
          emit,
          inventory,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.stockFilter,
          currentState.selectedCategoryId,
          currentState.categories,
        );
      } catch (e) {
        emit(
          InventoryManagementError(
            'Không thể làm mới dữ liệu: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onUpdateMedicationStatus(
    UpdateMedicationStatusEvent event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementLoaded) {
      final currentState = state as InventoryManagementLoaded;
      emit(InventoryManagementActionLoading());

      try {
        final request = UpdateMedicationStatus(
          medicationId: event.medicationId,
          isSale: event.isSale,
        );

        await inventoryRepository.updateMedicationStatus(request);

        // Reload inventory
        final inventory = await inventoryRepository.getAllInventory();

        final statusText = event.isSale == 0 ? 'ngưng bán' : 'đang bán';

        // Emit success state
        emit(
          InventoryManagementActionSuccess(
            'Đã cập nhật trạng thái thuốc thành $statusText',
          ),
        );

        // Sau đó emit loaded state để đảm bảo UI hiển thị đúng
        _emitLoadedState(
          emit,
          inventory,
          currentState.searchQuery,
          currentState.currentPage,
          currentState.stockFilter,
          currentState.selectedCategoryId,
          currentState.categories,
        );
      } catch (e) {
        emit(
          InventoryManagementActionError(
            'Không thể cập nhật trạng thái thuốc: ${e.toString()}',
          ),
        );
      }
    }
  }

  void _emitLoadedState(
    Emitter<InventoryManagementState> emit,
    List<InventoryDto> allInventory,
    String searchQuery,
    int currentPage,
    String? stockFilter,
    int? selectedCategoryId,
    List<CategoryDto> categories,
  ) {
    // Apply filters
    List<InventoryDto> filteredInventory = allInventory;

    // Search filter
    if (searchQuery.isNotEmpty) {
      filteredInventory =
          filteredInventory.where((item) {
            final query = searchQuery.toLowerCase();
            return item.medication.name.toLowerCase().contains(query) ||
                item.medication.description.toLowerCase().contains(query) ||
                item.medication.category.name.toLowerCase().contains(query);
          }).toList();
    }

    // Stock filter
    if (stockFilter != null) {
      switch (stockFilter) {
        case 'low':
          filteredInventory =
              filteredInventory.where((item) {
                final available = item.quantity - item.soldOut;
                return available <= 10 && available > 0;
              }).toList();
          break;
        case 'out':
          filteredInventory =
              filteredInventory.where((item) {
                final available = item.quantity - item.soldOut;
                return available <= 0;
              }).toList();
          break;
        case 'available':
          filteredInventory =
              filteredInventory.where((item) {
                final available = item.quantity - item.soldOut;
                return available > 10;
              }).toList();
          break;
      }
    }

    // Category filter
    if (selectedCategoryId != null) {
      filteredInventory =
          filteredInventory
              .where(
                (item) => item.medication.category.id == selectedCategoryId,
              )
              .toList();
    }

    // Pagination
    const itemsPerPage = 10;
    final totalPages = (filteredInventory.length / itemsPerPage).ceil();
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredInventory.length,
    );
    final currentInventory = filteredInventory.sublist(startIndex, endIndex);

    emit(
      InventoryManagementLoaded(
        allInventory: allInventory,
        filteredInventory: filteredInventory,
        currentInventory: currentInventory,
        currentPage: currentPage,
        totalPages: totalPages,
        searchQuery: searchQuery,
        stockFilter: stockFilter,
        selectedCategoryId: selectedCategoryId,
        categories: categories,
      ),
    );
  }
}
