import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF6F5F2),
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: _SettingsHeader(user: user, isDark: isDark),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Governance ───────────────────────────────────────────
                _SectionHeader(title: 'Governance', delay: 100, isDark: isDark),
                const Gap(10),
                _SettingsTile(
                  icon: Icons.group_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Committee Members',
                  subtitle: 'Manage board and committee details',
                  onTap: () {},
                  isDark: isDark,
                  delay: 120,
                ),
                _SettingsTile(
                  icon: Icons.shield_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Role Permissions',
                  subtitle: 'Configure access for committee roles',
                  onTap: () {},
                  isDark: isDark,
                  delay: 150,
                ),

                const Gap(24),

                // ── Operations ───────────────────────────────────────────
                _SectionHeader(
                    title: 'Operations', delay: 180, isDark: isDark),
                const Gap(10),
                _SettingsTile(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.primary,
                  title: 'Operational Hours',
                  subtitle: 'Mon-Sat, 09:00 AM - 07:00 PM',
                  onTap: () {},
                  isDark: isDark,
                  delay: 200,
                ),
                _SettingsTile(
                  icon: Icons.event_busy_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: 'Holiday Calendar',
                  subtitle: 'Manage public and local holidays',
                  onTap: () {},
                  isDark: isDark,
                  delay: 230,
                ),

                const Gap(24),

                // ── Security ─────────────────────────────────────────────
                _SectionHeader(title: 'Security', delay: 260, isDark: isDark),
                const Gap(10),
                _SettingsTile(
                  icon: Icons.lock_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Change Password',
                  subtitle: 'Update your security credentials',
                  onTap: () {},
                  isDark: isDark,
                  delay: 280,
                ),

                const Gap(24),

                // ── Communication ─────────────────────────────────────────
                _SectionHeader(
                    title: 'Communication', delay: 310, isDark: isDark),
                const Gap(10),
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Push & Email Alerts',
                  subtitle: 'Customize what you hear about',
                  onTap: () {},
                  isDark: isDark,
                  delay: 330,
                ),

                const Gap(24),

                // ── Support & Legal ───────────────────────────────────────
                _SectionHeader(
                    title: 'Support & Legal', delay: 360, isDark: isDark),
                const Gap(10),
                _SettingsTile(
                  icon: Icons.contact_support_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Help & Support',
                  subtitle: 'Tickets, FAQs, and Chat',
                  onTap: () {},
                  isDark: isDark,
                  delay: 380,
                ),
                _SettingsTile(
                  icon: Icons.policy_rounded,
                  iconColor: AppColors.primary,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () {},
                  isDark: isDark,
                  delay: 410,
                ),
                _SettingsTile(
                  icon: Icons.gavel_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Terms of Service',
                  subtitle: 'Legal agreement of usage',
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () {},
                  isDark: isDark,
                  delay: 440,
                ),

                const Gap(24),

                // ── Logout ────────────────────────────────────────────────
                _LogoutButton(ref: ref, context: context)
                    .animate()
                    .fadeIn(delay: 480.ms),

                const Gap(16),

                // ── Version ───────────────────────────────────────────────
                Center(
                  child: Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const Gap(8),
              ]),
            ),
          ),
        ],
      ),

      // ── Bottom Nav (same as Dashboard) ────────────────────────────────────
      bottomNavigationBar: _BottomNav(isDark: isDark),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _SettingsHeader({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.settings_rounded,
                    color: Colors.white, size: 24),
              ),
              const Gap(12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organization Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'DevGruha Partners',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Gap(20),

          // Org profile card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.home_work_rounded,
                      color: Colors.white, size: 28),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shree Ram Mandir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        user?.phone?.isNotEmpty == true
                            ? user!.phone!
                            : user?.email?.isNotEmpty == true
                                ? user!.email!
                                : 'Partner',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Real Estate Solutions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: Colors.white70, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int delay;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.delay,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                letterSpacing: 0.5,
              ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms);
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final int delay;
  final IconData trailingIcon;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    required this.delay,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const Gap(14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                // Trailing
                Icon(
                  trailingIcon,
                  size: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 350.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext context;

  const _LogoutButton({required this.ref, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) context.go(AppConstants.loginRoute);
        },
      ),
    );
  }
}

// ── Bottom Nav (matches Dashboard) ────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final bool isDark;
  const _BottomNav({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  active: false,
                  isDark: isDark,
                  onTap: () => context.go(AppConstants.dashboardRoute)),
              _NavItem(
                  icon: Icons.event_note_rounded,
                  label: 'Bookings',
                  active: false,
                  isDark: isDark,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.design_services_rounded,
                  label: 'Services',
                  active: false,
                  isDark: isDark,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.group_rounded,
                  label: 'Members',
                  active: false,
                  isDark: isDark,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  active: true,
                  isDark: isDark,
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.primary
        : (isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withOpacity(0.12) : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
