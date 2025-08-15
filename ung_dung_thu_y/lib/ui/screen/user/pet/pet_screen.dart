import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/bloc/pet_search/pet_search_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet_search/pet_search_event.dart';
import 'package:ung_dung_thu_y/bloc/pet_search/pet_search_state.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/card_display_pet.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PetBloc>().add(PetGetStarted());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              PetSearchBloc(context.read<PetRepository>())
                ..add(PetSearchStarted("")),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Thú cưng',
            style: TextStyle(
              color: TColor.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: TColor.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: TColor.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Thú cưng của tôi'), Tab(text: 'Tìm kiếm')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildMyPetsTab(), _buildSearchTab()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<PetBloc>().add(PetAddPrepare());
            context.push('/handle-pet');
          },
          backgroundColor: TColor.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMyPetsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PetBloc>().add(PetGetStarted());
      },
      child: BlocBuilder<PetBloc, PetState>(
        builder: (context, state) {
          return switch (state) {
            PetGetInProgress() => const Center(
              child: CircularProgressIndicator(),
            ),
            PetGetSuccess() => _buildPetsList(state.list, isMyPets: true),
            PetGetFailure() => _buildErrorState(state.message),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thú cưng...',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          _searchController.clear();
                          context.read<PetSearchBloc>().add(
                            PetSearchStarted(""),
                          );
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              context.read<PetSearchBloc>().add(PetSearchStarted(value));
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<PetSearchBloc, PetSearchState>(
            builder: (context, state) {
              return switch (state) {
                PetSearchInProgress() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PetSearchSuccess() => _buildPetsList(
                  state.listPet,
                  isMyPets: false,
                ),
                PetSearchFailure() => _buildErrorState(state.message),
                _ => _buildEmptySearchState(),
              };
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetsList(List<PetGetDto> pets, {required bool isMyPets}) {
    if (pets.isEmpty) {
      return isMyPets ? _buildEmptyMyPetsState() : _buildEmptySearchState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: CardDisplayPet(petGetDto: pets[index]),
        );
      },
    );
  }

  Widget _buildEmptyMyPetsState() {
    return _buildEmptyState(
      icon: Icons.pets_outlined,
      title: 'Chưa có thú cưng nào',
      subtitle: 'Hãy thêm thú cưng đầu tiên của bạn',
      showButton: true,
    );
  }

  Widget _buildEmptySearchState() {
    return _buildEmptyState(
      icon: Icons.search_outlined,
      title: 'Tìm kiếm thú cưng',
      subtitle: 'Nhập tên thú cưng để tìm kiếm',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PetBloc>().add(PetAddPrepare());
                context.push('/handle-pet');
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm thú cưng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
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
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<PetBloc>().add(PetGetStarted()),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
