import 'package:admin/dto/inventory/Inventory_dto.dart';
import 'package:admin/dto/medication/category_dto.dart';

abstract class InventoryManagementState {}

class InventoryManagementInitial extends InventoryManagementState {}

class InventoryManagementLoading extends InventoryManagementState {}

class InventoryManagementError extends InventoryManagementState {
  final String message;
  InventoryManagementError(this.message);
}

class InventoryManagementLoaded extends InventoryManagementState {
  final List<InventoryDto> allInventory;
  final List<InventoryDto> filteredInventory;
  final List<InventoryDto> currentInventory;
  final int currentPage;
  final int totalPages;
  final String searchQuery;
  final String? stockFilter;
  final int? selectedCategoryId;
  final int itemsPerPage;
  final List<CategoryDto> categories;

  InventoryManagementLoaded({
    required this.allInventory,
    required this.filteredInventory,
    required this.currentInventory,
    required this.currentPage,
    required this.totalPages,
    required this.searchQuery,
    this.stockFilter,
    this.selectedCategoryId,
    this.itemsPerPage = 10,
    this.categories = const [],
  });

  InventoryManagementLoaded copyWith({
    List<InventoryDto>? allInventory,
    List<InventoryDto>? filteredInventory,
    List<InventoryDto>? currentInventory,
    int? currentPage,
    int? totalPages,
    String? searchQuery,
    String? stockFilter,
    int? selectedCategoryId,
    int? itemsPerPage,
    List<CategoryDto>? categories,
  }) {
    return InventoryManagementLoaded(
      allInventory: allInventory ?? this.allInventory,
      filteredInventory: filteredInventory ?? this.filteredInventory,
      currentInventory: currentInventory ?? this.currentInventory,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      searchQuery: searchQuery ?? this.searchQuery,
      stockFilter: stockFilter ?? this.stockFilter,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      categories: categories ?? this.categories,
    );
  }

  // Helper getters
  int get totalItems => filteredInventory.length;

  int get lowStockCount =>
      allInventory
          .where(
            (item) =>
                (item.quantity - item.soldOut) <= 10 &&
                (item.quantity - item.soldOut) > 0,
          )
          .length;

  int get outOfStockCount =>
      allInventory.where((item) => (item.quantity - item.soldOut) <= 0).length;

  int get availableCount =>
      allInventory.where((item) => (item.quantity - item.soldOut) > 10).length;

  double get totalInventoryValue => allInventory.fold(
    0.0,
    (sum, item) => sum + (item.price * (item.quantity - item.soldOut)),
  );
}

class InventoryManagementActionLoading extends InventoryManagementState {}

class InventoryManagementActionSuccess extends InventoryManagementState {
  final String message;
  InventoryManagementActionSuccess(this.message);
}

class InventoryManagementActionError extends InventoryManagementState {
  final String message;
  InventoryManagementActionError(this.message);
}
