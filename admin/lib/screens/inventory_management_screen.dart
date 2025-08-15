import 'package:admin/dto/medication/category_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:admin/bloc/inventory_management/inventory_management_bloc.dart';
import 'package:admin/bloc/inventory_management/inventory_management_event.dart';
import 'package:admin/bloc/inventory_management/inventory_management_state.dart';
import 'package:admin/dto/inventory/Inventory_dto.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InventoryManagementBloc>().add(LoadInventoryEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            BlocConsumer<InventoryManagementBloc, InventoryManagementState>(
              listener: (context, state) {
                if (state is InventoryManagementActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is InventoryManagementActionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is InventoryManagementLoading ||
                    state is InventoryManagementActionLoading) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is InventoryManagementError) {
                  return Expanded(child: _buildErrorView(state.message));
                } else if (state is InventoryManagementLoaded) {
                  return Expanded(
                    child: Column(
                      children: [
                        _buildFiltersAndSearch(state),
                        const SizedBox(height: 16),
                        _buildStatsCards(state),
                        const SizedBox(height: 16),
                        Expanded(child: _buildInventoryList(state)),
                        const SizedBox(height: 16),
                        _buildPagination(state),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch(InventoryManagementLoaded state) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên thuốc, mô tả, danh mục...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                context.read<InventoryManagementBloc>().add(
                  SearchInventoryEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: state.stockFilter,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Lọc theo tồn kho'),
              ),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Tất cả'),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'available',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Còn hàng'),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'low',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Sắp hết'),
                  ),
                ),
                DropdownMenuItem<String?>(
                  value: 'out',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Hết hàng'),
                  ),
                ),
              ],
              onChanged: (value) {
                context.read<InventoryManagementBloc>().add(
                  FilterInventoryByStockEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showImportExistingDialog(),
          icon: const Icon(Icons.add_box),
          label: const Text('Nhập kho'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showAddNewMedicationDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Thêm thuốc mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(InventoryManagementLoaded state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng mặt hàng',
            state.totalItems.toString(),
            Icons.inventory_2,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Còn hàng',
            state.availableCount.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Sắp hết',
            state.lowStockCount.toString(),
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Hết hàng',
            state.outOfStockCount.toString(),
            Icons.error,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Tổng giá trị',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
            ).format(state.totalInventoryValue),
            Icons.attach_money,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildInventoryList(InventoryManagementLoaded state) {
    if (state.currentInventory.isEmpty) {
      return _buildEmptyView();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentInventory.length,
              itemBuilder: (context, index) {
                final item = state.currentInventory[index];
                return _buildInventoryRow(item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Không có thuốc nào trong kho',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc thêm thuốc mới',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Tên thuốc',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Danh mục',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Đơn vị',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Tồn kho',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Đã bán',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Còn lại',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Giá',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Trạng thái',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(InventoryDto item, int index) {
    final isEven = index % 2 == 0;
    final available = item.quantity - item.soldOut;
    final discontinued = item.medication.isSale;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[25] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medication.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: discontinued == 0 ? Colors.grey : Colors.black,
                    decoration:
                        discontinued == 0 ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (item.medication.description.isNotEmpty)
                  Text(
                    item.medication.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(item.medication.category.name)),
          Expanded(flex: 1, child: Text(item.medication.unit)),
          Expanded(flex: 1, child: Text(item.quantity.toString())),
          Expanded(flex: 1, child: Text(item.soldOut.toString())),
          Expanded(
            flex: 1,
            child: Text(
              available.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    discontinued == 0 ? Colors.grey : _getStockColor(available),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              ).format(item.price),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: discontinued == 0 ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStockStatusChip(available, discontinued: discontinued),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      discontinued == 0
                          ? null
                          : () => _showImportExistingDialog(item),
                  icon: Icon(
                    Icons.add_box,
                    color: discontinued == 0 ? Colors.grey : Colors.blue[600],
                  ),
                  tooltip: 'Nhập thêm',
                ),
                IconButton(
                  onPressed: () => _showUpdateStatusDialog(item),
                  icon: Icon(
                    discontinued == 0 ? Icons.check_circle : Icons.block,
                    color:
                        discontinued == 0 ? Colors.green[600] : Colors.red[600],
                  ),
                  tooltip: discontinued == 0 ? 'Bán lại' : 'Ngưng bán',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int available) {
    if (available <= 0) return Colors.red;
    if (available <= 10) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStockStatusChip(int available, {int discontinued = 1}) {
    Color color;
    String text;

    if (discontinued == 0) {
      color = Colors.grey;
      text = 'Ngưng bán';
    } else if (available <= 0) {
      color = Colors.red;
      text = 'Hết hàng';
    } else if (available <= 10) {
      color = Colors.orange;
      text = 'Sắp hết';
    } else {
      color = Colors.green;
      text = 'Còn hàng';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPagination(InventoryManagementLoaded state) {
    if (state.totalPages <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trang ${state.currentPage + 1} / ${state.totalPages}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    state.currentPage > 0
                        ? () => context.read<InventoryManagementBloc>().add(
                          ChangePaginationEvent(state.currentPage - 1),
                        )
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(state.totalPages.clamp(0, 5), (index) {
                final page = index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap:
                        () => context.read<InventoryManagementBloc>().add(
                          ChangePaginationEvent(page),
                        ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            state.currentPage == page
                                ? Colors.blue[600]
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${page + 1}',
                        style: TextStyle(
                          color:
                              state.currentPage == page
                                  ? Colors.white
                                  : Colors.grey[600],
                          fontWeight:
                              state.currentPage == page
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                onPressed:
                    state.currentPage < state.totalPages - 1
                        ? () => context.read<InventoryManagementBloc>().add(
                          ChangePaginationEvent(state.currentPage + 1),
                        )
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<InventoryManagementBloc>().add(LoadInventoryEvent());
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showImportExistingDialog([InventoryDto? item]) {
    final quantityController = TextEditingController();
    final priceController = TextEditingController(
      text: item?.price.toString() ?? '',
    );
    InventoryDto? selectedMedication = item;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Nhập kho thuốc'),
                  content: SizedBox(
                    width: 400,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item == null) ...[
                          BlocBuilder<
                            InventoryManagementBloc,
                            InventoryManagementState
                          >(
                            builder: (context, state) {
                              if (state is InventoryManagementLoaded) {
                                return DropdownButtonFormField<InventoryDto>(
                                  value: selectedMedication,
                                  decoration: const InputDecoration(
                                    labelText: 'Chọn thuốc',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      state.allInventory.map((item) {
                                        return DropdownMenuItem<InventoryDto>(
                                          value: item,
                                          child: Text(item.medication.name),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedMedication = value;
                                      priceController.text =
                                          value?.price.toString() ?? '';
                                    });
                                  },
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          Text('Thuốc: ${item.medication.name}'),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng nhập',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Giá (VNĐ)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedMedication != null &&
                            quantityController.text.isNotEmpty &&
                            priceController.text.isNotEmpty) {
                          context.read<InventoryManagementBloc>().add(
                            ImportExistingMedicationEvent(
                              medicationId: selectedMedication!.medication.id,
                              quantity: int.parse(quantityController.text),
                              price: int.parse(priceController.text),
                              context: context,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Nhập kho'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showUpdateStatusDialog(InventoryDto item) {
    final int currentStatus = item.medication.isSale;
    final String newStatus = currentStatus == 0 ? 'đang bán' : 'ngưng bán';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cập nhật trạng thái thuốc'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thuốc: ${item.medication.name}'),
                const SizedBox(height: 16),
                Text(
                  'Trạng thái hiện tại: ${currentStatus == 0 ? 'Ngưng bán' : 'Đang bán'}',
                ),
                const SizedBox(height: 16),
                Text(
                  'Bạn có chắc chắn muốn chuyển trạng thái thuốc này thành $newStatus?',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<InventoryManagementBloc>().add(
                    UpdateMedicationStatusEvent(
                      medicationId: item.medication.id,
                      isSale: currentStatus == 1 ? 0 : 1,
                      context: context,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      currentStatus == 0 ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Chuyển thành $newStatus'),
              ),
            ],
          ),
    );
  }

  void _showAddNewMedicationDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    CategoryDto? selectedCategory;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Thêm thuốc mới'),
                  content: SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Tên thuốc',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Mô tả',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: unitController,
                            decoration: const InputDecoration(
                              labelText: 'Đơn vị (viên, chai, hộp...)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: priceController,
                            decoration: const InputDecoration(
                              labelText: 'Giá (VNĐ)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Số lượng',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<
                            InventoryManagementBloc,
                            InventoryManagementState
                          >(
                            builder: (context, state) {
                              if (state is InventoryManagementLoaded) {
                                return DropdownButtonFormField<CategoryDto>(
                                  value: selectedCategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Danh mục',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      state.categories.map((category) {
                                        return DropdownMenuItem<CategoryDto>(
                                          value: category,
                                          child: Text(category.name),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            descriptionController.text.isNotEmpty &&
                            unitController.text.isNotEmpty &&
                            priceController.text.isNotEmpty &&
                            quantityController.text.isNotEmpty &&
                            selectedCategory != null) {
                          context.read<InventoryManagementBloc>().add(
                            ImportNewMedicationEvent(
                              name: nameController.text,
                              description: descriptionController.text,
                              unit: unitController.text,
                              price: int.parse(priceController.text),
                              quantity: int.parse(quantityController.text),
                              categoryId: selectedCategory!.id,
                              context: context,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Thêm thuốc'),
                    ),
                  ],
                ),
          ),
    );
  }
}
