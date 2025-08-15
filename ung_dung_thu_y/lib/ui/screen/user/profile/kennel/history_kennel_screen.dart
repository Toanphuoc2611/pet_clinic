import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/button_back_screen.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/my_app_bar.dart';

class HistoryKennelScreen extends StatefulWidget {
  const HistoryKennelScreen({super.key});

  @override
  State<HistoryKennelScreen> createState() => _HistoryKennelScreenState();
}

class _HistoryKennelScreenState extends State<HistoryKennelScreen> {
  List<KennelDetailDto> allKennelDetails = [];
  List<KennelDetailDto> filteredKennelDetails = [];
  int selectedStatusFilter = -1; // -1 means all statuses
  String selectedKennelTypeFilter = "ALL"; // ALL, NORMAL, SPECIAL
  TextEditingController searchController = TextEditingController();
  final WebSocketService _webSocketService = WebSocketService.instance;
  @override
  void initState() {
    super.initState();
    context.read<KennelDetailBloc>().add(KennelDetailGetStarted());
    searchController.addListener(_onSearchChanged);
    _webSocketService.addKennelListener(_refreshKennel);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _webSocketService.removeKennelListener(_refreshKennel);
    super.dispose();
  }

  void _refreshKennel() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.read<KennelDetailBloc>().add(KennelDetailGetStarted());
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      filteredKennelDetails =
          allKennelDetails.where((kennel) {
            // Search filter
            bool matchesSearch =
                searchController.text.isEmpty ||
                (kennel.pet.name.isNotEmpty &&
                    kennel.pet.name.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    )) ||
                (kennel.kennel.name.isNotEmpty &&
                    kennel.kennel.name.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ));

            // Status filter
            bool matchesStatus =
                selectedStatusFilter == -1 ||
                kennel.status == selectedStatusFilter;

            // Kennel type filter
            bool matchesKennelType =
                selectedKennelTypeFilter == "ALL" ||
                kennel.kennel.type == selectedKennelTypeFilter;

            return matchesSearch && matchesStatus && matchesKennelType;
          }).toList();

      // Sort by creation date (newest first)
      filteredKennelDetails.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.bgColorPrimary,
      appBar: MyAppBar(
        title: const Text("Lịch sử đặt chuồng"),
        leading: ButtonBackScreen(onPress: () => Navigator.pop(context)),
      ),
      body: BlocListener<KennelDetailBloc, KennelDetailState>(
        listener: (context, state) {
          if (state is KennelDetailGetSuccess) {
            setState(() {
              allKennelDetails = state.kennels;
              filteredKennelDetails = state.kennels;
            });
            _applyFilters();
          }
        },
        child: BlocBuilder<KennelDetailBloc, KennelDetailState>(
          builder: (context, state) {
            if (state is KennelDetailGetInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KennelDetailGetFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Không thể tải dữ liệu",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<KennelDetailBloc>().add(
                          KennelDetailGetStarted(),
                        );
                      },
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildFilterSection(),
                Expanded(
                  child:
                      filteredKennelDetails.isEmpty
                          ? _buildEmptyState()
                          : _buildKennelList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm theo tên thú cưng hoặc chuồng...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: TColor.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusFilterChip("Tất cả", -1),
                const SizedBox(width: 8),
                _buildStatusFilterChip("Chờ xác nhận", 0),
                const SizedBox(width: 8),
                _buildStatusFilterChip("Đã xác nhận", 1),
                const SizedBox(width: 8),
                _buildStatusFilterChip("Đang lưu chuồng", 2),
                const SizedBox(width: 8),
                _buildStatusFilterChip("Hoàn thành", 3),
                const SizedBox(width: 8),
                _buildStatusFilterChip("Đã hủy", 4),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Kennel type filter
          Row(
            children: [
              _buildKennelTypeFilterChip("Tất cả", "ALL"),
              const SizedBox(width: 8),
              _buildKennelTypeFilterChip("Bình thường", "NORMAL"),
              const SizedBox(width: 8),
              _buildKennelTypeFilterChip("Đặc biệt", "SPECIAL"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, int status) {
    bool isSelected = selectedStatusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedStatusFilter = status;
        });
        _applyFilters();
      },
      selectedColor: TColor.primary.withOpacity(0.2),
      checkmarkColor: TColor.primary,
      labelStyle: TextStyle(
        color: isSelected ? TColor.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildKennelTypeFilterChip(String label, String type) {
    bool isSelected = selectedKennelTypeFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedKennelTypeFilter = type;
        });
        _applyFilters();
      },
      selectedColor: TColor.primary.withOpacity(0.2),
      checkmarkColor: TColor.primary,
      labelStyle: TextStyle(
        color: isSelected ? TColor.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Không có lịch sử đặt chuồng",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bạn chưa có lịch sử đặt chuồng nào",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildKennelList() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<KennelDetailBloc>().add(KennelDetailGetStarted());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredKennelDetails.length,
        itemBuilder: (context, index) {
          return _buildKennelCard(filteredKennelDetails[index]);
        },
      ),
    );
  }

  Widget _buildKennelCard(KennelDetailDto kennel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await context.push(
            RouteName.detailKennel,
            extra: kennel,
          );

          if (result == true) {
            context.read<KennelDetailBloc>().add(KennelDetailGetStarted());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Mã đặt: #${kennel.id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(kennel.status),
                ],
              ),
              const SizedBox(height: 12),

              // Pet info
              Row(
                children: [
                  _buildPetAvatar(kennel.pet.avatar),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kennel.pet.name.isEmpty
                              ? "Chưa cập nhật"
                              : kennel.pet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${kennel.pet.breed?.isEmpty == true ? "Chưa cập nhật" : kennel.pet.breed ?? "Chưa cập nhật"} - ${kennel.pet.gender == 0 ? "Cái" : "Đực"}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Kennel info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TColor.bgColorPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.home_outlined,
                      "Chuồng",
                      "${kennel.kennel.name.isEmpty ? "Chưa cập nhật" : kennel.kennel.name} - ${kennel.kennel.type == "NORMAL"
                          ? "Bình thường"
                          : kennel.kennel.type == "SPECIAL"
                          ? "Đặc biệt"
                          : "Chưa cập nhật"}",
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.login_outlined,
                      "Giờ vào",
                      _formatDateTime(kennel.inTime),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.logout_outlined,
                      "Giờ ra",
                      _formatDateTime(kennel.outTime),
                    ),
                    if (kennel.note != null && kennel.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.note_outlined,
                        "Ghi chú",
                        kennel.note!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Doctor info
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: TColor.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: TColor.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Bs. ${kennel.doctor.fullname?.isEmpty == true ? "Chưa cập nhật" : kennel.doctor.fullname ?? "Chưa cập nhật"}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Created date
              Text(
                "Ngày tạo: ${_formatDateTime(kennel.createdAt)}",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(String? avatarUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: FadeInImage.assetNetwork(
        placeholder: "assets/image/pet_default.jpg",
        image:
            avatarUrl ??
            "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678351/pet_default_vg54u5.jpg",
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        imageErrorBuilder: (context, error, _) {
          return Image.asset(
            "assets/image/pet_default.jpg",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 0:
        color = TColor.appointmentStatusWaitingColor;
        text = "Chờ xác nhận";
        icon = Icons.access_time;
        break;
      case 1:
        color = TColor.appointmentStatusAccessedColor;
        text = "Đã xác nhận";
        icon = Icons.check_circle_outline;
        break;
      case 2:
        color = Colors.blue;
        text = "Đang lưu chuồng";
        icon = Icons.play_circle_outline;
        break;
      case 3:
        color = TColor.appointmentStatusCompletedColor;
        text = "Hoàn thành";
        icon = Icons.check_circle;
        break;
      case 4:
        color = TColor.appointmentStatusCanceledColor;
        text = "Đã hủy";
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        text = "Không xác định";
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return "Chưa cập nhật";
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Convert to local timezone if the parsed datetime is in UTC
      if (dateTime.isUtc) {
        dateTime = dateTime.toLocal();
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString.isEmpty ? "Chưa cập nhật" : dateTimeString;
    }
  }
}
