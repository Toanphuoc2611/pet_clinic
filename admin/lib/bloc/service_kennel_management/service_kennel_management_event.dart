abstract class ServiceKennelManagementEvent {}

// Service Events
class LoadServicesEvent extends ServiceKennelManagementEvent {}

class SearchServicesEvent extends ServiceKennelManagementEvent {
  final String query;
  SearchServicesEvent(this.query);
}

class AddServiceEvent extends ServiceKennelManagementEvent {
  final String name;
  final int price;
  AddServiceEvent(this.name, this.price);
}

class UpdateServiceEvent extends ServiceKennelManagementEvent {
  final String id;
  final int price;
  UpdateServiceEvent(this.id, this.price);
}

class UpdateServiceStatusEvent extends ServiceKennelManagementEvent {
  final String id;
  final int status; // 0 = ngưng sử dụng, 1 = đang sử dụng
  UpdateServiceStatusEvent(this.id, this.status);
}

// Kennel Events
class LoadKennelsEvent extends ServiceKennelManagementEvent {}

class SearchKennelsEvent extends ServiceKennelManagementEvent {
  final String query;
  SearchKennelsEvent(this.query);
}

class FilterKennelsByStatusEvent extends ServiceKennelManagementEvent {
  final int? status; // null = all, 1 = normal, 2 = inactive
  FilterKennelsByStatusEvent(this.status);
}

class AddKennelEvent extends ServiceKennelManagementEvent {
  final String name;
  final String type;
  final double priceMultiplier;
  AddKennelEvent(this.name, this.type, this.priceMultiplier);
}

class UpdateKennelStatusEvent extends ServiceKennelManagementEvent {
  final String id;
  final String status;
  UpdateKennelStatusEvent(this.id, this.status);
}

// Tab switching
class SwitchTabEvent extends ServiceKennelManagementEvent {
  final int tabIndex; // 0 = services, 1 = kennels
  SwitchTabEvent(this.tabIndex);
}

// Pagination
class ChangeServicePaginationEvent extends ServiceKennelManagementEvent {
  final int page;
  ChangeServicePaginationEvent(this.page);
}

class ChangeKennelPaginationEvent extends ServiceKennelManagementEvent {
  final int page;
  ChangeKennelPaginationEvent(this.page);
}
