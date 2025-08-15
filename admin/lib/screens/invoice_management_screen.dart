import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:admin/bloc/invoice_management/invoice_management_bloc.dart';
import 'package:admin/bloc/invoice_management/invoice_management_event.dart';
import 'package:admin/bloc/invoice_management/invoice_management_state.dart';
import 'package:admin/dto/invoice/invoice_response.dart';
import 'package:admin/dto/invoice_kennel/invoice_kennel_dto.dart';

class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({super.key});

  @override
  State<InvoiceManagementScreen> createState() =>
      _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<InvoiceManagementBloc>().add(LoadInvoicesEvent());
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
            _buildFiltersAndSearch(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<InvoiceManagementBloc, InvoiceManagementState>(
                builder: (context, state) {
                  if (state is InvoiceManagementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InvoiceManagementError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<InvoiceManagementBloc>().add(
                                LoadInvoicesEvent(),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is InvoiceManagementLoaded) {
                    return Column(
                      children: [
                        _buildInvoiceTypeToggle(state),
                        const SizedBox(height: 16),
                        _buildStatsCards(state),
                        const SizedBox(height: 16),
                        Expanded(child: _buildInvoiceList(state)),
                        const SizedBox(height: 16),
                        _buildPagination(state),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return BlocBuilder<InvoiceManagementBloc, InvoiceManagementState>(
      builder: (context, state) {
        if (state is! InvoiceManagementLoaded) return const SizedBox();

        return Row(
          children: [
            Expanded(
              flex: 2,
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
                    hintText:
                        'Tìm kiếm theo mã hóa đơn, tên khách hàng, bác sĩ...',
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
                    if (state.currentType == InvoiceType.medical) {
                      context.read<InvoiceManagementBloc>().add(
                        SearchInvoicesEvent(value),
                      );
                    } else {
                      context.read<InvoiceManagementBloc>().add(
                        SearchInvoiceKennelsEvent(value),
                      );
                    }
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
                child: DropdownButton<int?>(
                  value: state.selectedStatus,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Lọc theo trạng thái'),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Tất cả trạng thái'),
                      ),
                    ),
                    ...List.generate(4, (index) {
                      return DropdownMenuItem<int?>(
                        value: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(_getStatusText(index)),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (state.currentType == InvoiceType.medical) {
                      context.read<InvoiceManagementBloc>().add(
                        FilterInvoicesByStatusEvent(value),
                      );
                    } else {
                      context.read<InvoiceManagementBloc>().add(
                        FilterInvoiceKennelsByStatusEvent(value),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceTypeToggle(InvoiceManagementLoaded state) {
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
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<InvoiceManagementBloc>().add(
                  ChangeInvoiceTypeEvent(InvoiceType.medical),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      state.currentType == InvoiceType.medical
                          ? Colors.blue[600]
                          : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services,
                      color:
                          state.currentType == InvoiceType.medical
                              ? Colors.white
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hóa đơn khám bệnh',
                      style: TextStyle(
                        color:
                            state.currentType == InvoiceType.medical
                                ? Colors.white
                                : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<InvoiceManagementBloc>().add(
                  ChangeInvoiceTypeEvent(InvoiceType.kennel),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      state.currentType == InvoiceType.kennel
                          ? Colors.blue[600]
                          : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hotel,
                      color:
                          state.currentType == InvoiceType.kennel
                              ? Colors.white
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hóa đơn lưu chuồng',
                      style: TextStyle(
                        color:
                            state.currentType == InvoiceType.kennel
                                ? Colors.white
                                : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(InvoiceManagementLoaded state) {
    final totalInvoices = state.totalItems;
    final totalAmount =
        state.currentType == InvoiceType.medical
            ? state.filteredMedicalInvoices.fold<int>(
              0,
              (sum, invoice) => sum + invoice.totalAmount,
            )
            : state.filteredKennelInvoices.fold<int>(
              0,
              (sum, invoice) => sum + invoice.totalAmount,
            );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng hóa đơn',
            totalInvoices.toString(),
            Icons.receipt_long,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Tổng doanh thu',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
            ).format(totalAmount),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Hiển thị',
            '${state.currentInvoices.length}/${state.totalItems}',
            Icons.visibility,
            Colors.orange,
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

  Widget _buildInvoiceList(InvoiceManagementLoaded state) {
    if (state.currentInvoices.isEmpty) {
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
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Không có hóa đơn nào',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Thử thay đổi bộ lọc hoặc tìm kiếm',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
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
          _buildTableHeader(state),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentInvoices.length,
              itemBuilder: (context, index) {
                final invoice = state.currentInvoices[index];
                return _buildInvoiceRow(invoice, state.currentType);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(InvoiceManagementLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text(
              'Mã hóa đơn',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Khách hàng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Bác sĩ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          if (state.currentType == InvoiceType.kennel)
            const Expanded(
              flex: 1,
              child: Text(
                'Đặt cọc',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          const Expanded(
            flex: 2,
            child: Text(
              'Tổng tiền',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Trạng thái',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Ngày tạo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(dynamic invoice, InvoiceType type) {
    final isEven = (invoice.id % 2) == 0;

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
            flex: 2,
            child: Text(
              invoice.invoiceCode,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 2, child: Text(invoice.user.fullname)),
          Expanded(flex: 2, child: Text(invoice.doctor.fullname)),
          if (type == InvoiceType.kennel)
            Expanded(
              flex: 1,
              child: Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                ).format((invoice as InvoiceKennelDto).deposit),
                style: TextStyle(color: Colors.orange[600]),
              ),
            ),
          Expanded(
            flex: 2,
            child: Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              ).format(invoice.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 1, child: _buildStatusChip(invoice.status)),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(invoice.createdAt)),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: () => _showInvoiceDetails(invoice, type),
              icon: Icon(Icons.visibility, color: Colors.blue[600]),
              tooltip: 'Xem chi tiết',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color color;
    String text;

    switch (status) {
      case 0:
        color = Colors.orange;
        text = 'Chờ thanh toán';
        break;
      case 1:
        color = Colors.blue;
        text = 'Đã thanh toán';
        break;
      case 2:
        color = Colors.green;
        text = 'Hoàn thành';
        break;
      case 3:
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
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

  Widget _buildPagination(InvoiceManagementLoaded state) {
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
                        ? () => context.read<InvoiceManagementBloc>().add(
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
                        () => context.read<InvoiceManagementBloc>().add(
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
                        ? () => context.read<InvoiceManagementBloc>().add(
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

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ thanh toán';
      case 1:
        return 'Đã thanh toán';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  void _showInvoiceDetails(dynamic invoice, InvoiceType type) {
    showDialog(
      context: context,
      builder: (context) => _InvoiceDetailDialog(invoice: invoice, type: type),
    );
  }
}

class _InvoiceDetailDialog extends StatelessWidget {
  final dynamic invoice;
  final InvoiceType type;

  const _InvoiceDetailDialog({required this.invoice, required this.type});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  type == InvoiceType.medical
                      ? Icons.medical_services
                      : Icons.hotel,
                  color: Colors.blue[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Chi tiết hóa đơn',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Mã hóa đơn', invoice.invoiceCode),
            _buildDetailRow('Khách hàng', invoice.user.fullname),
            _buildDetailRow('Bác sĩ', invoice.doctor.fullname),
            if (type == InvoiceType.kennel)
              _buildDetailRow(
                'Đặt cọc',
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                ).format((invoice as InvoiceKennelDto).deposit),
              ),
            _buildDetailRow(
              'Tổng tiền',
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              ).format(invoice.totalAmount),
            ),
            _buildDetailRow('Trạng thái', _getStatusText(invoice.status)),
            _buildDetailRow(
              'Ngày tạo',
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(invoice.createdAt)),
            ),
            if (type == InvoiceType.medical &&
                (invoice as InvoiceResponse).services.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Dịch vụ:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              ...(invoice as InvoiceResponse).services.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('• ${service.name}'),
                ),
              ),
            ],
            if (type == InvoiceType.medical &&
                (invoice as InvoiceResponse).prescriptionDetail.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Đơn thuốc:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              ...(invoice as InvoiceResponse).prescriptionDetail.map(
                (prescription) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    '• ${prescription.medication.name} - SL: ${prescription.quantity}',
                  ),
                ),
              ),
            ],
            if (type == InvoiceType.kennel) ...[
              const SizedBox(height: 16),
              Text(
                'Thông tin khách sạn:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Loại phòng',
                "${(invoice as InvoiceKennelDto).kennelDetail.kennel.name} - ${(invoice as InvoiceKennelDto).kennelDetail.kennel.type == "NORMAL" ? "Bình thường" : "Đặc biệt"}",
              ),
              _buildDetailRow(
                'Giá/ngày',
                NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(
                  (invoice as InvoiceKennelDto)
                          .kennelDetail
                          .kennel
                          .priceMultiplier *
                      50000,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ thanh toán';
      case 1:
        return 'Đã thanh toán';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
