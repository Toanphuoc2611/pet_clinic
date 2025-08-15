abstract class InvoiceManagementEvent {}

class LoadInvoicesEvent extends InvoiceManagementEvent {}

class LoadInvoiceKennelsEvent extends InvoiceManagementEvent {}

class FilterInvoicesByStatusEvent extends InvoiceManagementEvent {
  final int? status;
  FilterInvoicesByStatusEvent(this.status);
}

class FilterInvoiceKennelsByStatusEvent extends InvoiceManagementEvent {
  final int? status;
  FilterInvoiceKennelsByStatusEvent(this.status);
}

class SearchInvoicesEvent extends InvoiceManagementEvent {
  final String query;
  SearchInvoicesEvent(this.query);
}

class SearchInvoiceKennelsEvent extends InvoiceManagementEvent {
  final String query;
  SearchInvoiceKennelsEvent(this.query);
}

class ChangeInvoiceTypeEvent extends InvoiceManagementEvent {
  final InvoiceType type;
  ChangeInvoiceTypeEvent(this.type);
}

class ChangePaginationEvent extends InvoiceManagementEvent {
  final int page;
  ChangePaginationEvent(this.page);
}

enum InvoiceType { medical, kennel }
