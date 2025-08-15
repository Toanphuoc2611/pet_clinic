import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_state.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/repository/invoice/invoice_repository.dart';
import 'package:ung_dung_thu_y/repository/invoice_deposit/invoice_deposit_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with TickerProviderStateMixin {
  final Map<int, String> statusMap = {
    -1: "Tất cả",
    0: "Chưa thanh toán",
    1: "Đã thanh toán",
    2: "Đã hủy",
  };

  int selectedStatus = -1;
  List<InvoiceDepositDto> invoiceDeposit = [];
  List<InvoiceDepositDto> filteredInvoices = [];
  late TabController _tabController;

  // Regular invoices data
  List<InvoiceResponse> regularInvoices = [];
  List<InvoiceKennelDto> kennelInvoices = [];
  List<dynamic> filteredRegularInvoices = [];
  bool isLoadingRegularInvoices = false;
  bool isLoadingKennelInvoices = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize filtered lists
    _filterInvoices();

    // Load invoice deposit data
    context.read<InvoiceDepositBloc>().add(InvoiceDepositGetStarted());

    // Load regular invoices data
    context.read<InvoiceBloc>().add(InvoiceGetByUserStarted());
    context.read<InvoiceBloc>().add(InvoiceKennelGetByUserStarted());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterInvoices() {
    setState(() {
      filteredInvoices =
          selectedStatus == -1
              ? invoiceDeposit
              : invoiceDeposit
                  .where((invoice) => invoice.status == selectedStatus)
                  .toList();

      // Filter regular invoices
      List<dynamic> allRegularInvoices = [
        ...regularInvoices,
        ...kennelInvoices,
      ];
      filteredRegularInvoices =
          selectedStatus == -1
              ? allRegularInvoices
              : allRegularInvoices
                  .where((invoice) => invoice.status == selectedStatus)
                  .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Hóa đơn của tôi",
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: backScreen,
          icon: Icon(Icons.arrow_back, color: TColor.primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: Column(children: [_buildTabBar(), _buildStatusFilter()]),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<InvoiceDepositBloc, InvoiceDepositState>(
            listener: (context, state) {
              if (state is InvoiceDepositGetStartedSuccess) {
                setState(() {
                  invoiceDeposit = state.lists;
                  _filterInvoices();
                });
              }
            },
          ),
          BlocListener<InvoiceBloc, InvoiceState>(
            listener: (context, state) {
              if (state is InvoiceGetByUserInProgress) {
                setState(() {
                  isLoadingRegularInvoices = true;
                });
              } else if (state is InvoiceGetByUserSuccess) {
                print(
                  'InvoiceGetByUserSuccess: ${state.invoices.length} invoices loaded',
                );
                setState(() {
                  regularInvoices = state.invoices;
                  isLoadingRegularInvoices = false;
                  _filterInvoices();
                });
              } else if (state is InvoiceGetByUserFailure) {
                setState(() {
                  isLoadingRegularInvoices = false;
                });
              } else if (state is InvoiceKennelGetByUserInProgress) {
                setState(() {
                  isLoadingKennelInvoices = true;
                });
              } else if (state is InvoiceKennelGetByUserSuccess) {
                setState(() {
                  kennelInvoices = state.invoiceKennels;
                  isLoadingKennelInvoices = false;
                  _filterInvoices();
                });
              } else if (state is InvoiceKennelGetByUserFailure) {
                setState(() {
                  isLoadingKennelInvoices = false;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<InvoiceDepositBloc, InvoiceDepositState>(
          builder: (context, state) {
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  void backScreen() {
    Navigator.pop(context);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: TColor.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        tabs: const [
          Padding(padding: EdgeInsets.all(10), child: Tab(text: "Hóa đơn")),
          Padding(
            padding: EdgeInsets.all(10),
            child: Tab(text: "Hóa đơn tạm ứng"),
          ),
        ],
        onTap: (index) {
          _filterInvoices();
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DropdownButton<int>(
          value: selectedStatus,
          isExpanded: true,
          underline: const SizedBox(),
          hint: const Text("Lọc theo trạng thái"),
          icon: Icon(Icons.keyboard_arrow_down, color: TColor.primary),
          items:
              statusMap.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    children: [
                      _getStatusIcon(entry.key),
                      const SizedBox(width: 8),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: _getStatusColor(entry.key),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedStatus = value;
                _filterInvoices();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(InvoiceDepositState state) {
    return switch (state) {
      InvoiceDepositGetStartedInProgress() => _buildLoadingState(),
      InvoiceDepositGetStartedSuccess() => _buildInvoiceList(),
      InvoiceDepositGetStartedFailure() => _buildErrorState(state.message),
      _ => _buildEmptyState(),
    };
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang tải hóa đơn...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<InvoiceDepositBloc>().add(
                InvoiceDepositGetStarted(),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có hóa đơn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hóa đơn sẽ xuất hiện ở đây sau khi bạn sử dụng dịch vụ',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    // Check if we have any data at all (filtered or unfiltered)
    bool hasInvoiceDeposits =
        invoiceDeposit.isNotEmpty || filteredInvoices.isNotEmpty;
    bool hasRegularInvoices =
        regularInvoices.isNotEmpty ||
        kennelInvoices.isNotEmpty ||
        filteredRegularInvoices.isNotEmpty;

    if (!hasInvoiceDeposits && !hasRegularInvoices) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildRegularInvoicesTab(), // Appointment invoices (regular invoices)
        _buildInvoicesByType(), // Kennel invoices (invoice deposits)
      ],
    );
  }

  Widget _buildInvoicesByType() {
    // Use filtered invoices if available, otherwise use original data
    List<InvoiceDepositDto> displayInvoices =
        filteredInvoices.isNotEmpty ? filteredInvoices : invoiceDeposit;

    if (displayInvoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có hóa đơn tạm ứng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hóa đơn tạm ứng sẽ xuất hiện ở đây',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<InvoiceDepositBloc>().add(InvoiceDepositGetStarted());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayInvoices.length,
        itemBuilder: (context, index) {
          return _buildModernInvoiceCard(displayInvoices[index]);
        },
      ),
    );
  }

  Widget _buildRegularInvoicesTab() {
    if (isLoadingRegularInvoices || isLoadingKennelInvoices) {
      return const Center(child: CircularProgressIndicator());
    }

    // Use filtered invoices if available, otherwise use original data
    List<dynamic> displayInvoices =
        filteredRegularInvoices.isNotEmpty
            ? filteredRegularInvoices
            : [...regularInvoices, ...kennelInvoices];

    print(
      '_buildRegularInvoicesTab: displayInvoices.length=${displayInvoices.length}',
    );
    for (int i = 0; i < displayInvoices.length; i++) {
      print('Invoice $i: ${displayInvoices[i].runtimeType}');
    }

    if (displayInvoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có hóa đơn khám bệnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hóa đơn khám bệnh sẽ xuất hiện ở đây',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<InvoiceBloc>().add(InvoiceGetByUserStarted());
        context.read<InvoiceBloc>().add(InvoiceKennelGetByUserStarted());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayInvoices.length,
        itemBuilder: (context, index) {
          final invoice = displayInvoices[index];
          if (invoice is InvoiceResponse) {
            return _buildInvoiceResponseCard(invoice);
          } else if (invoice is InvoiceKennelDto) {
            return _buildKennelInvoiceCard(invoice);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildModernInvoiceCard(InvoiceDepositDto invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          context.push(
            RouteName.invoiceDeposit,
            extra: {'idInvoice': invoice.id, 'type': invoice.type},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceHeader(invoice),
              const SizedBox(height: 16),
              _buildUserInfo(invoice),
              const SizedBox(height: 16),
              _buildInvoiceDetails(invoice),
              const SizedBox(height: 16),
              _buildInvoiceStatus(invoice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader(InvoiceDepositDto invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã hóa đơn',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              invoice.invoiceCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getTypeColor(invoice.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            invoice.type == 0 ? 'Lưu chuồng' : 'Khám bệnh',
            style: TextStyle(
              color: _getTypeColor(invoice.type),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(InvoiceDepositDto invoice) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/image/avatar_default.jpg",
              image:
                  invoice.user.avatar ??
                  "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/image/avatar_default.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.user.fullname ?? 'Không có tên',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    invoice.user.phoneNumber,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceDetails(InvoiceDepositDto invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Ngày tạo',
            FormatDate.formatDate(invoice.createdAt),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Tổng tiền',
            NumberFormat('#,###').format(invoice.totalAmount) + ' VNĐ',
            Icons.account_balance_wallet_outlined,
            valueColor: TColor.primary,
            isHighlight: true,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Số tiền thanh toán',
            NumberFormat('#,###').format(invoice.deposit) + ' VNĐ',
            Icons.payment_outlined,
            valueColor: Colors.green,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceStatus(InvoiceDepositDto invoice) {
    return displayByStatus(invoice.status);
  }

  Color _getTypeColor(int type) {
    return type == 0 ? Colors.purple : Colors.blue;
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return TColor.appointmentStatusWaitingColor;
      case 1:
        return TColor.appointmentStatusAccessedColor;
      case 2:
        return TColor.appointmentStatusCanceledColor;
      default:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icon(
          Icons.access_time,
          size: 16,
          color: _getStatusColor(status),
        );
      case 1:
        return Icon(
          Icons.check_circle,
          size: 16,
          color: _getStatusColor(status),
        );
      case 2:
        return Icon(Icons.cancel, size: 16, color: _getStatusColor(status));
      default:
        return Icon(Icons.list, size: 16, color: Colors.grey);
    }
  }

  Widget displayByStatus(int status) {
    switch (status) {
      case 0:
        return _displayStatusItem(
          TColor.appointmentStatusWaitingColor,
          Icons.access_time_filled,
          "Chờ thanh toán",
        );
      case 1:
        return _displayStatusItem(
          TColor.appointmentStatusAccessedColor,
          Icons.check_circle,
          "Đã thanh toán",
        );
      case 2:
        return _displayStatusItem(
          TColor.appointmentStatusCanceledColor,
          Icons.cancel,
          "Đã hủy",
        );
      case 3:
      default:
        return _displayStatusItem(
          TColor.appointmentStatusCompletedColor,
          Icons.warning,
          "Quá hạn",
        );
    }
  }

  Widget _displayStatusItem(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularInvoiceCard(InvoiceDto invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          context.push(
            RouteName.doctorInvoiceDetail,
            extra: {'invoice': invoice, 'isFromUser': true},
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRegularInvoiceHeader(invoice),
              const SizedBox(height: 16),
              _buildRegularInvoiceUserInfo(invoice),
              const SizedBox(height: 16),
              _buildRegularInvoiceDetails(invoice),
              const SizedBox(height: 16),
              _buildRegularInvoiceStatus(invoice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKennelInvoiceCard(InvoiceKennelDto invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          context.push(RouteName.doctorInvoiceKennelDetail, extra: invoice);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKennelInvoiceHeader(invoice),
              const SizedBox(height: 16),
              _buildKennelInvoiceUserInfo(invoice),
              const SizedBox(height: 16),
              _buildKennelInvoiceDetails(invoice),
              const SizedBox(height: 16),
              _buildKennelInvoiceStatus(invoice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularInvoiceHeader(InvoiceDto invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã hóa đơn',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              invoice.invoiceCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Khám bệnh',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKennelInvoiceHeader(InvoiceKennelDto invoice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã hóa đơn',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              invoice.invoiceCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Lưu chuồng',
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularInvoiceUserInfo(InvoiceDto invoice) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/image/avatar_default.jpg",
              image:
                  invoice.user.avatar ??
                  "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/image/avatar_default.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.user.fullname ?? 'Không có tên',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    invoice.user.phoneNumber,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKennelInvoiceUserInfo(InvoiceKennelDto invoice) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/image/avatar_default.jpg",
              image:
                  invoice.user.avatar ??
                  "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/image/avatar_default.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.user.fullname ?? 'Không có tên',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    invoice.user.phoneNumber,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegularInvoiceDetails(InvoiceDto invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Ngày tạo',
            DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Tổng tiền',
            '${NumberFormat('#,###').format(invoice.totalAmount)} VNĐ',
            Icons.account_balance_wallet_outlined,
            valueColor: TColor.primary,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildKennelInvoiceDetails(InvoiceKennelDto invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Ngày tạo',
            FormatDate.formatDate(invoice.createdAt),
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Tổng tiền',
            NumberFormat('#,###').format(invoice.totalAmount) + ' VNĐ',
            Icons.account_balance_wallet_outlined,
            valueColor: TColor.primary,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRegularInvoiceStatus(InvoiceDto invoice) {
    return displayByStatus(invoice.status);
  }

  Widget _buildKennelInvoiceStatus(InvoiceKennelDto invoice) {
    return displayByStatus(invoice.status);
  }

  Widget _buildInvoiceResponseCard(InvoiceResponse invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to invoice detail screen
          context.push(
            RouteName.doctorInvoiceDetail,
            extra: {'invoice': invoice, 'isFromUser': true},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with invoice code and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                      ),
                    ),
                  ),
                  _buildInvoiceResponseStatus(invoice),
                ],
              ),
              const SizedBox(height: 12),

              // Doctor info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Bác sĩ: ${invoice.doctor.fullname}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Services
              if (invoice.services.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dịch vụ: ${invoice.services.map((s) => s.name).join(', ')}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Date and amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FormatDate.formatDate(invoice.createdAt),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Text(
                    '${NumberFormat('#,###', 'vi_VN').format(invoice.totalAmount)} VNĐ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceResponseStatus(InvoiceResponse invoice) {
    return displayByStatus(invoice.status);
  }
}
