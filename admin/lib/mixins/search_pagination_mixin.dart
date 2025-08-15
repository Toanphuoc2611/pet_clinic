import 'package:flutter/material.dart';

mixin SearchPaginationMixin<T extends StatefulWidget> on State<T> {
  // Tìm kiếm
  String _searchQuery = '';

  // Phân trang
  int _currentPage = 1;
  int _itemsPerPage = 20;
  int _totalItems = 0;

  // Getters
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();

  // Setters
  void setSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1; // Reset về trang đầu khi tìm kiếm
    });
    onSearchChanged(query);
  }

  void setCurrentPage(int page) {
    setState(() {
      _currentPage = page;
    });
    onPageChanged(page);
  }

  void setItemsPerPage(int items) {
    setState(() {
      _itemsPerPage = items;
      _currentPage = 1; // Reset về trang đầu khi thay đổi số mục
    });
    onItemsPerPageChanged(items);
  }

  void setTotalItems(int total) {
    setState(() {
      _totalItems = total;
    });
  }

  void clearSearch() {
    setState(() {
      _searchQuery = '';
      _currentPage = 1;
    });
    onSearchCleared();
  }

  // Abstract methods - phải được implement trong class sử dụng mixin
  void onSearchChanged(String query);
  void onPageChanged(int page);
  void onItemsPerPageChanged(int itemsPerPage);
  void onSearchCleared();

  // Helper methods
  List<T> applyPagination<T>(List<T> items) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= items.length) return [];

    return items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );
  }

  List<T> applySearch<T>(
    List<T> items,
    bool Function(T item, String query) searchFunction,
  ) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((item) => searchFunction(item, _searchQuery.toLowerCase()))
        .toList();
  }
}
