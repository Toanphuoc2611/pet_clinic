import 'package:flutter/material.dart';

abstract class InventoryManagementEvent {}

class LoadInventoryEvent extends InventoryManagementEvent {}

class SearchInventoryEvent extends InventoryManagementEvent {
  final String query;
  SearchInventoryEvent(this.query);
}

class FilterInventoryByStockEvent extends InventoryManagementEvent {
  final String? stockFilter;
  FilterInventoryByStockEvent(this.stockFilter);
}

class FilterInventoryByCategoryEvent extends InventoryManagementEvent {
  final int? categoryId;
  FilterInventoryByCategoryEvent(this.categoryId);
}

class ImportExistingMedicationEvent extends InventoryManagementEvent {
  final int medicationId;
  final int quantity;
  final int price;
  final BuildContext context;

  ImportExistingMedicationEvent({
    required this.medicationId,
    required this.quantity,
    required this.price,
    required this.context,
  });
}

class ImportNewMedicationEvent extends InventoryManagementEvent {
  final String name;
  final String description;
  final String unit;
  final int price;
  final int quantity;
  final int categoryId;
  final BuildContext context;

  ImportNewMedicationEvent({
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.context,
  });
}

class UpdateMedicationStatusEvent extends InventoryManagementEvent {
  final int medicationId;
  final int isSale;
  final BuildContext context;

  UpdateMedicationStatusEvent({
    required this.medicationId,
    required this.isSale,
    required this.context,
  });
}

class ChangePaginationEvent extends InventoryManagementEvent {
  final int page;
  ChangePaginationEvent(this.page);
}

class RefreshInventoryEvent extends InventoryManagementEvent {}
