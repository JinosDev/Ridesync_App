import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ridesync_button.dart';
import '../providers/route_provider.dart';

/// Home screen — Figma "Home" frame.
/// Shows search bar, quick filters, recent routes, and promo banner.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _navIdx == 0 ? const _HomeFeed() : _PlaceholderTab(_navIdx),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: _navIdx,
          onTap: (i) => setState(() => _navIdx = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textDisabled,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number_rounded), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final int idx;
  const _PlaceholderTab(this.idx);
  static const labels = ['', 'Search', 'Bookings', 'Notifications', 'Profile'];
  @override
  Widget build(BuildContext context) => Center(child: Text(labels[idx], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textTitle)));
}

// ── Home feed content ──────────────────────────────────────────────────────────
class _HomeFeed extends ConsumerWidget {
  const _HomeFeed();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: _buildSearchBar(context)),
        SliverToBoxAdapter(child: _buildQuickActions()),
        SliverToBoxAdapter(child: _buildPromo()),
        SliverToBoxAdapter(child: _buildSectionHeader('Popular Routes', onSeeAll: () {})),
        SliverToBoxAdapter(child: _buildRouteCards(context)),
        SliverToBoxAdapter(child: _buildSectionHeader('Recent Trips', onSeeAll: () {})),
        ..._recentTrips().map((t) => SliverToBoxAdapter(child: _TripTile(data: t))),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Morning 👋', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  SizedBox(height: 2),
                  Text('John Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: const Text('JD', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/schedule-list'),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
              SizedBox(width: 10),
              Text('Search routes...', style: TextStyle(color: AppColors.textDisabled, fontSize: 14)),
              Spacer(),
              Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.search_rounded,        'Book Seat',  AppColors.primary),
      (Icons.directions_bus_rounded, 'Track Bus',  const Color(0xFF3B82F6)),
      (Icons.receipt_long_rounded,   'My Tickets', const Color(0xFF8B5CF6)),
      (Icons.calculate_outlined,     'Fare Calc',  const Color(0xFF10B981)),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) => _QuickAction(icon: a.$1, label: a.$2, color: a.$3)).toList(),
      ),
    );
  }

  Widget _buildPromo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('20% OFF Weekend Trips!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Use code: WEEKEND20', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Text('Grab Deal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          GestureDetector(
            onTap: onSeeAll,
            child: Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCards(BuildContext context) {
    final routes = [
      ('Downtown', 'North Station', 'Route 47', 'LKR 150'),
      ('Harbor View', 'City Centre', 'Route 12', 'LKR 120'),
    ];
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: routes.map((r) => _RouteCard(from: r.$1, to: r.$2, route: r.$3, fare: r.$4)).toList(),
      ),
    );
  }

  List<Map<String, String>> _recentTrips() => [
    {'from': 'Downtown', 'to': 'North Station', 'date': 'Today, 09:30 AM', 'status': 'confirmed'},
    {'from': 'Harbor View', 'to': 'City Centre', 'date': 'Yesterday, 07:00 AM', 'status': 'completed'},
  ];
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 28),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTitle)),
    ],
  );
}

class _RouteCard extends StatelessWidget {
  final String from, to, route, fare;
  const _RouteCard({required this.from, required this.to, required this.route, required this.fare});
  @override
  Widget build(BuildContext context) => Container(
    width: 200,
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(route, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                Container(width: 1, height: 28, color: AppColors.border),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: BorderRadius.circular(2))),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(from, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 20),
                Text(to, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fare, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: const Text('Book', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TripTile extends StatelessWidget {
  final Map<String, String> data;
  const _TripTile({required this.data});
  @override
  Widget build(BuildContext context) {
    final isConfirmed = data['status'] == 'confirmed';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isConfirmed ? AppColors.primary.withOpacity(0.1) : AppColors.progressTrack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_bus_rounded, color: isConfirmed ? AppColors.primary : AppColors.textDisabled, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${data['from']} → ${data['to']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(data['date']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isConfirmed ? AppColors.primary.withOpacity(0.1) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isConfirmed ? 'Confirmed' : 'Completed',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isConfirmed ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
