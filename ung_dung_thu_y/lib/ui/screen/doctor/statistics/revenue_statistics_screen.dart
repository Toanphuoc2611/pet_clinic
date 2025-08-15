import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_state.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class RevenueStatisticsScreen extends StatefulWidget {
  const RevenueStatisticsScreen({super.key});

  @override
  State<RevenueStatisticsScreen> createState() =>
      _RevenueStatisticsScreenState();
}

class _RevenueStatisticsScreenState extends State<RevenueStatisticsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  List<InvoiceDto> _filteredInvoices = [];
  List<InvoiceKennelDto> _filteredKennelInvoices = [];
  List<InvoiceDto> _allInvoices = [];
  List<InvoiceKennelDto> _allKennelInvoices = [];
  bool _isLoadingInvoices = false;
  bool _isLoadingKennelInvoices = false;
  String? _invoiceError;
  String? _kennelInvoiceError;

  @override
  void initState() {
    super.initState();
    // Set default date range (current month)
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;

    _loadData();
  }

  void _loadData() {
    context.read<InvoiceBloc>().add(InvoiceGetStarted());
    context.read<InvoiceBloc>().add(InvoiceKennelGetStarted());
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
  }

  void _filterInvoicesByDate() {
    if (_fromDate == null || _toDate == null) {
      _filteredInvoices = _allInvoices;
      _filteredKennelInvoices = _allKennelInvoices;
      return;
    }

    _filteredInvoices =
        _allInvoices.where((invoice) {
          return invoice.createdAt.isAfter(
                _fromDate!.subtract(const Duration(days: 1)),
              ) &&
              invoice.createdAt.isBefore(_toDate!.add(const Duration(days: 1)));
        }).toList();

    _filteredKennelInvoices =
        _allKennelInvoices.where((invoice) {
          final createdAt = DateTime.parse(invoice.createdAt);
          return createdAt.isAfter(
                _fromDate!.subtract(const Duration(days: 1)),
              ) &&
              createdAt.isBefore(_toDate!.add(const Duration(days: 1)));
        }).toList();
  }

  int _calculateTotalRevenue() {
    final invoiceTotal = _filteredInvoices
        .where((invoice) => invoice.status == 1) // Only paid invoices
        .fold(0, (sum, invoice) => sum + invoice.totalAmount);

    final kennelTotal = _filteredKennelInvoices
        .where((invoice) => invoice.status == 1) // Only paid invoices
        .fold(0, (sum, invoice) => sum + invoice.totalAmount);

    return invoiceTotal + kennelTotal;
  }

  int _calculateMedicalRevenue() {
    return _filteredInvoices
        .where((invoice) => invoice.status == 1)
        .fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  int _calculateKennelRevenue() {
    return _filteredKennelInvoices
        .where((invoice) => invoice.status == 1)
        .fold(0, (sum, invoice) => sum + invoice.totalAmount);
  }

  int _getTotalInvoices() {
    return _filteredInvoices.length + _filteredKennelInvoices.length;
  }

  int _getPaidInvoices() {
    final paidInvoices =
        _filteredInvoices.where((invoice) => invoice.status == 1).length;
    final paidKennelInvoices =
        _filteredKennelInvoices.where((invoice) => invoice.status == 1).length;
    return paidInvoices + paidKennelInvoices;
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        _filterInvoicesByDate();
      });
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
        _filterInvoicesByDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Thống kê doanh thu',
          style: TextStyle(color: TColor.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: TColor.primary,
        foregroundColor: TColor.white,
        elevation: 0,
      ),
      body: BlocListener<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceGetInProgress) {
            setState(() {
              _isLoadingInvoices = true;
              _invoiceError = null;
            });
          } else if (state is InvoiceGetSuccess) {
            setState(() {
              _isLoadingInvoices = false;
              _allInvoices = state.invoices;
              _invoiceError = null;
              _filterInvoicesByDate();
            });
          } else if (state is InvoiceGetFailure) {
            setState(() {
              _isLoadingInvoices = false;
              _invoiceError = state.message;
            });
          } else if (state is InvoiceKennelGetInProgress) {
            setState(() {
              _isLoadingKennelInvoices = true;
              _kennelInvoiceError = null;
            });
          } else if (state is InvoiceKennelGetSuccess) {
            setState(() {
              _isLoadingKennelInvoices = false;
              _allKennelInvoices = state.invoiceKennels;
              _kennelInvoiceError = null;
              _filterInvoicesByDate();
            });
          } else if (state is InvoiceKennelGetFailure) {
            setState(() {
              _isLoadingKennelInvoices = false;
              _kennelInvoiceError = state.message;
            });
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Show loading if either is loading
    if (_isLoadingInvoices || _isLoadingKennelInvoices) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if either has error
    if (_invoiceError != null || _kennelInvoiceError != null) {
      final errorMessage =
          _invoiceError ?? _kennelInvoiceError ?? 'Có lỗi xảy ra';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadData();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Show content when data is loaded
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filter Section
          _buildDateFilterSection(),
          const SizedBox(height: 20),

          // Summary Cards
          _buildSummaryCards(),
          const SizedBox(height: 20),

          // Revenue Breakdown
          _buildRevenueBreakdown(),
          const SizedBox(height: 20),

          // Recent Invoices
          _buildRecentInvoices(),
        ],
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc thời gian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'Từ ngày',
                  _fromDate,
                  _selectFromDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector('Đến ngày', _toDate, _selectToDate),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterInvoicesByDate();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Áp dụng bộ lọc'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  date != null ? _formatDate(date) : 'Chọn ngày',
                  style: TextStyle(
                    fontSize: 14,
                    color: date != null ? Colors.black87 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Tổng doanh thu',
            _formatCurrency(_calculateTotalRevenue()),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Tổng hóa đơn',
            '${_getTotalInvoices()}',
            Icons.receipt_long,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    final medicalRevenue = _calculateMedicalRevenue();
    final kennelRevenue = _calculateKennelRevenue();
    final totalRevenue = medicalRevenue + kennelRevenue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân tích doanh thu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildRevenueItem(
            'Doanh thu khám chữa bệnh',
            medicalRevenue,
            totalRevenue > 0 ? (medicalRevenue / totalRevenue * 100) : 0,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildRevenueItem(
            'Doanh thu lưu chuồng',
            kennelRevenue,
            totalRevenue > 0 ? (kennelRevenue / totalRevenue * 100) : 0,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(
    String title,
    int amount,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentInvoices() {
    final recentInvoices = [..._filteredInvoices, ..._filteredKennelInvoices]
      ..sort((a, b) {
        final aDate =
            a is InvoiceDto
                ? a.createdAt
                : DateTime.parse((a as InvoiceKennelDto).createdAt);
        final bDate =
            b is InvoiceDto
                ? b.createdAt
                : DateTime.parse((b as InvoiceKennelDto).createdAt);
        return bDate.compareTo(aDate);
      });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hóa đơn gần đây',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          if (recentInvoices.isEmpty)
            Center(
              child: Text(
                'Không có hóa đơn nào trong khoảng thời gian này',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ...recentInvoices.take(5).map((invoice) {
              if (invoice is InvoiceDto) {
                return _buildInvoiceItem(
                  invoice.invoiceCode,
                  _formatDate(invoice.createdAt),
                  _formatCurrency(invoice.totalAmount),
                  invoice.status,
                  'Khám chữa bệnh',
                );
              } else {
                final kennelInvoice = invoice as InvoiceKennelDto;
                return _buildInvoiceItem(
                  kennelInvoice.invoiceCode,
                  _formatDate(DateTime.parse(kennelInvoice.createdAt)),
                  _formatCurrency(kennelInvoice.totalAmount),
                  kennelInvoice.status,
                  'Lưu chuồng',
                );
              }
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(
    String code,
    String date,
    String amount,
    int status,
    String type,
  ) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 0:
        statusColor = Colors.orange;
        statusText = 'Chưa thanh toán';
        break;
      case 1:
        statusColor = Colors.green;
        statusText = 'Đã thanh toán';
        break;
      case 2:
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$type • $date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
