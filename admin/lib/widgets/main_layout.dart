import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/bloc/auth/auth_bloc.dart';
import 'package:admin/bloc/auth/auth_state.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String? title;
  final String? currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    this.title,
    this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLogoutSuccess) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isCollapsed ? 70 : 250,
              child: _buildSidebar(),
            ),
            // Main content
            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF2C3E50),
      child: Column(
        children: [
          // Logo/Header
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.analytics,
                  title: 'Thống kê',
                  route: '/analytics',
                  isActive: widget.currentRoute == '/analytics',
                ),
                _buildMenuItem(
                  icon: Icons.people,
                  title: 'Quản lý người dùng',
                  route: '/users',
                  isActive: widget.currentRoute == '/users',
                ),
                _buildMenuItem(
                  icon: Icons.account_circle,
                  title: 'Quản lý tài khoản',
                  route: '/accounts',
                  isActive: widget.currentRoute == '/accounts',
                ),
                _buildMenuItem(
                  icon: Icons.calendar_today,
                  title: 'Quản lý lịch hẹn',
                  route: '/appointments',
                  isActive: widget.currentRoute == '/appointments',
                ),
                _buildMenuItem(
                  icon: Icons.receipt,
                  title: 'Quản lý hóa đơn',
                  route: '/invoices',
                  isActive: widget.currentRoute == '/invoices',
                ),
                _buildMenuItem(
                  icon: Icons.medical_services,
                  title: 'Hồ sơ y tế',
                  route: '/medical-records',
                  isActive: widget.currentRoute == '/medical-records',
                ),
                _buildMenuItem(
                  icon: Icons.home,
                  title: 'Quản lý chuồng',
                  route: '/kennels',
                  isActive: widget.currentRoute == '/kennels',
                ),
                _buildMenuItem(
                  icon: Icons.inventory,
                  title: 'Quản lý kho thuốc',
                  route: '/inventory',
                  isActive: widget.currentRoute == '/inventory',
                ),
              ],
            ),
          ),

          // Collapse button
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isCollapsed = !_isCollapsed;
                });
              },
              icon: Icon(
                _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.go(route),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(8),
              border:
                  isActive
                      ? Border.all(color: Colors.white.withOpacity(0.3))
                      : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.white70,
                  size: 20,
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
