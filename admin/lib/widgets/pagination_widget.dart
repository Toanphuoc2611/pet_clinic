import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Thông tin tổng số
          Text(
            'Hiển thị ${_getStartItem()} - ${_getEndItem()} của $totalItems mục',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

          Row(
            children: [
              // Chọn số mục trên mỗi trang
              Text(
                'Hiển thị: ',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: itemsPerPage,
                    items:
                        [10, 20, 50, 100].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        onItemsPerPageChanged(newValue);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Điều hướng trang
              Row(
                children: [
                  // Nút trang đầu
                  IconButton(
                    onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                    icon: const Icon(Icons.first_page),
                    tooltip: 'Trang đầu',
                  ),

                  // Nút trang trước
                  IconButton(
                    onPressed:
                        currentPage > 1
                            ? () => onPageChanged(currentPage - 1)
                            : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Trang trước',
                  ),

                  // Hiển thị số trang
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Trang $currentPage / $totalPages',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  // Nút trang sau
                  IconButton(
                    onPressed:
                        currentPage < totalPages
                            ? () => onPageChanged(currentPage + 1)
                            : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Trang sau',
                  ),

                  // Nút trang cuối
                  IconButton(
                    onPressed:
                        currentPage < totalPages
                            ? () => onPageChanged(totalPages)
                            : null,
                    icon: const Icon(Icons.last_page),
                    tooltip: 'Trang cuối',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getStartItem() {
    if (totalItems == 0) return 0;
    return (currentPage - 1) * itemsPerPage + 1;
  }

  int _getEndItem() {
    final endItem = currentPage * itemsPerPage;
    return endItem > totalItems ? totalItems : endItem;
  }
}
