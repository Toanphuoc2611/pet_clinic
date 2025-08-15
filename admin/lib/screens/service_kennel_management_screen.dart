import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:admin/bloc/service_kennel_management/service_kennel_management_bloc.dart';
import 'package:admin/bloc/service_kennel_management/service_kennel_management_event.dart';
import 'package:admin/bloc/service_kennel_management/service_kennel_management_state.dart';
import 'package:admin/dto/service/services_get_dto.dart';
import 'package:admin/dto/kennel/get_kennel_dto.dart';

class ServiceKennelManagementScreen extends StatefulWidget {
  const ServiceKennelManagementScreen({super.key});

  @override
  State<ServiceKennelManagementScreen> createState() =>
      _ServiceKennelManagementScreenState();
}

class _ServiceKennelManagementScreenState
    extends State<ServiceKennelManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _serviceSearchController =
      TextEditingController();
  final TextEditingController _kennelSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ServiceKennelManagementBloc>().add(LoadServicesEvent());

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<ServiceKennelManagementBloc>().add(
          SwitchTabEvent(_tabController.index),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serviceSearchController.dispose();
    _kennelSearchController.dispose();
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
            _buildTabBar(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocConsumer<
                ServiceKennelManagementBloc,
                ServiceKennelManagementState
              >(
                listener: (context, state) {
                  if (state is ServiceKennelManagementActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is ServiceKennelManagementActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ServiceKennelManagementLoading ||
                      state is ServiceKennelManagementActionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ServiceKennelManagementError) {
                    return _buildErrorView(state.message);
                  } else if (state is ServiceKennelManagementLoaded) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildServicesTab(state),
                        _buildKennelsTab(state),
                      ],
                    );
                  } else if (state is ServiceKennelManagementActionSuccess ||
                      state is ServiceKennelManagementActionError) {
                    // Đợi trạng thái Loaded tiếp theo
                    return const Center(child: CircularProgressIndicator());
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.business, color: Colors.blue[600], size: 28),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý dịch vụ & chuồng',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Quản lý dịch vụ khám bệnh và chuồng lưu trú',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue[600],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(icon: Icon(Icons.medical_services), text: 'Dịch vụ'),
          Tab(icon: Icon(Icons.home), text: 'Chuồng'),
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
              context.read<ServiceKennelManagementBloc>().add(
                LoadServicesEvent(),
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(ServiceKennelManagementLoaded state) {
    return Column(
      children: [
        _buildServiceFiltersAndSearch(state),
        const SizedBox(height: 16),
        _buildServiceStatsCards(state),
        const SizedBox(height: 16),
        Expanded(child: _buildServiceList(state)),
        const SizedBox(height: 16),
        _buildServicePagination(state),
      ],
    );
  }

  Widget _buildKennelsTab(ServiceKennelManagementLoaded state) {
    return Column(
      children: [
        _buildKennelFiltersAndSearch(state),
        const SizedBox(height: 16),
        _buildKennelStatsCards(state),
        const SizedBox(height: 16),
        Expanded(child: _buildKennelList(state)),
        const SizedBox(height: 16),
        _buildKennelPagination(state),
      ],
    );
  }

  Widget _buildServiceFiltersAndSearch(ServiceKennelManagementLoaded state) {
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
              controller: _serviceSearchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên dịch vụ, giá...',
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
                context.read<ServiceKennelManagementBloc>().add(
                  SearchServicesEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddServiceDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Thêm dịch vụ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
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

  Widget _buildKennelFiltersAndSearch(ServiceKennelManagementLoaded state) {
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
              controller: _kennelSearchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên chuồng, loại...',
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
                context.read<ServiceKennelManagementBloc>().add(
                  SearchKennelsEvent(value),
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
            child: DropdownButton<int?>(
              value: state.selectedKennelStatus,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Lọc theo trạng thái'),
              ),
              items: const [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Tất cả'),
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Bình thường'),
                  ),
                ),
                DropdownMenuItem<int?>(
                  value: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Ngưng sử dụng'),
                  ),
                ),
              ],
              onChanged: (value) {
                context.read<ServiceKennelManagementBloc>().add(
                  FilterKennelsByStatusEvent(value),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddKennelDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Thêm chuồng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
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

  Widget _buildServiceStatsCards(ServiceKennelManagementLoaded state) {
    final totalServices = state.filteredServices.length;
    final avgPrice =
        state.filteredServices.isEmpty
            ? 0
            : state.filteredServices
                    .map((s) => s.price)
                    .reduce((a, b) => a + b) /
                state.filteredServices.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng dịch vụ',
            totalServices.toString(),
            Icons.medical_services,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Giá trung bình',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
            ).format(avgPrice),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Hiển thị',
            '${state.currentServices.length}/${state.filteredServices.length}',
            Icons.visibility,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildKennelStatsCards(ServiceKennelManagementLoaded state) {
    final totalKennels = state.filteredKennels.length;
    final availableKennels =
        state.filteredKennels.where((k) => k.status == 1).length;
    final occupiedKennels =
        state.filteredKennels.where((k) => k.status == 0).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng chuồng',
            totalKennels.toString(),
            Icons.home,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Chuồng trống',
            availableKennels.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Đang sử dụng',
            occupiedKennels.toString(),
            Icons.pets,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Hiển thị',
            '${state.currentKennels.length}/${state.filteredKennels.length}',
            Icons.visibility,
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

  Widget _buildServiceList(ServiceKennelManagementLoaded state) {
    if (state.currentServices.isEmpty) {
      return _buildEmptyView('Không có dịch vụ nào', Icons.medical_services);
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
          _buildServiceTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentServices.length,
              itemBuilder: (context, index) {
                final service = state.currentServices[index];
                return _buildServiceRow(service);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKennelList(ServiceKennelManagementLoaded state) {
    if (state.currentKennels.isEmpty) {
      return _buildEmptyView('Không có chuồng nào', Icons.home);
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
          _buildKennelTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentKennels.length,
              itemBuilder: (context, index) {
                final kennel = state.currentKennels[index];
                return _buildKennelRow(kennel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String message, IconData icon) {
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
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTableHeader() {
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
            flex: 1,
            child: Text(
              'ID',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Tên dịch vụ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
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
          SizedBox(width: 100),
        ],
      ),
    );
  }

  Widget _buildKennelTableHeader() {
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
            flex: 1,
            child: Text(
              'ID',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Tên chuồng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Loại',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Hệ số giá',
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
          SizedBox(width: 100),
        ],
      ),
    );
  }

  Widget _buildServiceRow(ServicesGetDto service) {
    final isEven = (service.id ?? 0) % 2 == 0;

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
            flex: 1,
            child: Text(
              '#${service.id}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 3, child: Text(service.name)),
          Expanded(
            flex: 2,
            child: Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              ).format(service.price),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 1, child: _buildServiceStatusChip(service.status)),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showEditServiceDialog(service),
                  icon: Icon(Icons.edit, color: Colors.blue[600]),
                  tooltip: 'Chỉnh sửa',
                ),
                IconButton(
                  onPressed: () => _showServiceStatusDialog(service),
                  icon: Icon(Icons.settings, color: Colors.orange[600]),
                  tooltip: 'Cập nhật trạng thái',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKennelRow(KennelDto kennel) {
    final isEven = kennel.id % 2 == 0;

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
            flex: 1,
            child: Text(
              '#${kennel.id}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 2, child: Text(kennel.name)),
          Expanded(flex: 2, child: Text(kennel.type)),
          Expanded(flex: 2, child: Text('x${kennel.priceMultiplier}')),
          Expanded(flex: 1, child: _buildKennelStatusChip(kennel.status)),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showKennelStatusDialog(kennel),
                  icon: Icon(Icons.edit, color: Colors.blue[600]),
                  tooltip: 'Cập nhật trạng thái',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusChip(int? status) {
    Color color;
    String text;

    if (status == 1) {
      color = Colors.green;
      text = 'Đang sử dụng';
    } else if (status == 0) {
      color = Colors.red;
      text = 'Ngưng sử dụng';
    } else {
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

  Widget _buildKennelStatusChip(int? status) {
    Color color;
    String text;

    if (status == 1) {
      color = Colors.green;
      text = 'Bình thường';
    } else if (status == 2) {
      color = Colors.red;
      text = 'Ngưng sử dụng';
    } else {
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

  Widget _buildServicePagination(ServiceKennelManagementLoaded state) {
    if (state.serviceTotalPages <= 1) return const SizedBox();

    return _buildPagination(
      currentPage: state.serviceCurrentPage,
      totalPages: state.serviceTotalPages,
      onPageChanged: (page) {
        context.read<ServiceKennelManagementBloc>().add(
          ChangeServicePaginationEvent(page),
        );
      },
    );
  }

  Widget _buildKennelPagination(ServiceKennelManagementLoaded state) {
    if (state.kennelTotalPages <= 1) return const SizedBox();

    return _buildPagination(
      currentPage: state.kennelCurrentPage,
      totalPages: state.kennelTotalPages,
      onPageChanged: (page) {
        context.read<ServiceKennelManagementBloc>().add(
          ChangeKennelPaginationEvent(page),
        );
      },
    );
  }

  Widget _buildPagination({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
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
            'Trang ${currentPage + 1} / $totalPages',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    currentPage > 0
                        ? () => onPageChanged(currentPage - 1)
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(totalPages.clamp(0, 5), (index) {
                final page = index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onPageChanged(page),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            currentPage == page
                                ? Colors.blue[600]
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${page + 1}',
                        style: TextStyle(
                          color:
                              currentPage == page
                                  ? Colors.white
                                  : Colors.grey[600],
                          fontWeight:
                              currentPage == page
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
                    currentPage < totalPages - 1
                        ? () => onPageChanged(currentPage + 1)
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm dịch vụ mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên dịch vụ',
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty) {
                    // Đảm bảo chuyển đổi giá trị price thành số nguyên
                    int price = 0;
                    try {
                      price = int.parse(priceController.text.trim());
                      print("Price: $price");
                    } catch (e) {
                      // Xử lý lỗi nếu không thể chuyển đổi
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Giá phải là số nguyên')),
                      );
                      return;
                    }

                    context.read<ServiceKennelManagementBloc>().add(
                      AddServiceEvent(nameController.text.trim(), price),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  void _showEditServiceDialog(ServicesGetDto service) {
    final priceController = TextEditingController(
      text: service.price.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Chỉnh sửa dịch vụ: ${service.name}'),
            content: TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Giá (VNĐ)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (priceController.text.isNotEmpty) {
                    context.read<ServiceKennelManagementBloc>().add(
                      UpdateServiceEvent(
                        service.id.toString(),
                        int.parse(priceController.text),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Cập nhật'),
              ),
            ],
          ),
    );
  }

  void _showAddKennelDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final multiplierController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm chuồng mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên chuồng',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Loại chuồng',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: multiplierController,
                  decoration: const InputDecoration(
                    labelText: 'Hệ số giá',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                  if (nameController.text.isNotEmpty &&
                      typeController.text.isNotEmpty &&
                      multiplierController.text.isNotEmpty) {
                    context.read<ServiceKennelManagementBloc>().add(
                      AddKennelEvent(
                        nameController.text,
                        typeController.text,
                        double.parse(multiplierController.text),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  void _showServiceStatusDialog(ServicesGetDto service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cập nhật trạng thái: ${service.name}'),
            content: const Text('Chọn trạng thái mới cho dịch vụ:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ServiceKennelManagementBloc>().add(
                    UpdateServiceStatusEvent(service.id.toString(), 1),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đang sử dụng'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ServiceKennelManagementBloc>().add(
                    UpdateServiceStatusEvent(service.id.toString(), 0),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ngưng sử dụng'),
              ),
            ],
          ),
    );
  }

  void _showKennelStatusDialog(KennelDto kennel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cập nhật trạng thái: ${kennel.name}'),
            content: const Text('Chọn trạng thái mới cho chuồng:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ServiceKennelManagementBloc>().add(
                    UpdateKennelStatusEvent(kennel.id.toString(), 'normal'),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bình thường'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ServiceKennelManagementBloc>().add(
                    UpdateKennelStatusEvent(kennel.id.toString(), 'inactive'),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ngưng sử dụng'),
              ),
            ],
          ),
    );
  }
}
