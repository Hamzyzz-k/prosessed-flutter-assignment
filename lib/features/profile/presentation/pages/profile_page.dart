import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/widgets/skeleton.dart';
import 'package:shopsphere/core/widgets/status_view.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shopsphere/features/settings/domain/entities/app_settings.dart';
import 'package:shopsphere/features/settings/presentation/cubit/settings_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<ProfileCubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileTitle)),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => switch (state) {
            ProfileLoading() => const _ProfileSkeleton(),
            ProfileFailure(:final failure) => ErrorView(
              failure: failure,
              onRetry: () => context.read<ProfileCubit>().load(),
            ),
            ProfileLoaded(:final user) => RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().load(),
              child: _ProfileContent(user: user),
            ),
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final User user;

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = context.l10n;
    final auth = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final settings = context.watch<SettingsCubit>();

    return ListView(
      padding: const EdgeInsets.all(Insets.lg),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundImage: user.image.isEmpty
                          ? null
                          : CachedNetworkImageProvider(user.image),
                      child: Text(
                        user.firstName.isEmpty ? '?' : user.firstName[0],
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    Gaps.lg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            '@${user.username}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gaps.xl,
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.mail_outline_rounded),
                        title: Text(l10n.email),
                        subtitle: Text(user.email),
                      ),
                      if (user.phone != null)
                        ListTile(
                          leading: const Icon(Icons.phone_outlined),
                          title: Text(l10n.phone),
                          subtitle: Text(user.phone!),
                        ),
                      if (user.address != null)
                        ListTile(
                          leading: const Icon(Icons.home_outlined),
                          title: Text(l10n.deliverTo),
                          subtitle: Text(user.address!),
                        ),
                    ],
                  ),
                ),
                Gaps.lg,
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Insets.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appearance,
                          style: theme.textTheme.titleSmall,
                        ),
                        Gaps.sm,
                        SegmentedButton<ThemePreference>(
                          segments: [
                            ButtonSegment(
                              value: ThemePreference.system,
                              label: Text(l10n.themeSystem),
                              icon: const Icon(Icons.brightness_auto_outlined),
                            ),
                            ButtonSegment(
                              value: ThemePreference.light,
                              label: Text(l10n.themeLight),
                              icon: const Icon(Icons.light_mode_outlined),
                            ),
                            ButtonSegment(
                              value: ThemePreference.dark,
                              label: Text(l10n.themeDark),
                              icon: const Icon(Icons.dark_mode_outlined),
                            ),
                          ],
                          selected: {settings.state.theme},
                          onSelectionChanged: (value) =>
                              unawaited(settings.setTheme(value.first)),
                        ),
                        Gaps.lg,
                        Text(l10n.language, style: theme.textTheme.titleSmall),
                        Gaps.sm,
                        SegmentedButton<AppLanguage>(
                          segments: const [
                            // Each language is written in its own script.
                            ButtonSegment(
                              value: AppLanguage.english,
                              label: Text('English'),
                            ),
                            ButtonSegment(
                              value: AppLanguage.hindi,
                              label: Text('हिन्दी'),
                            ),
                          ],
                          selected: {settings.state.language},
                          onSelectionChanged: (value) =>
                              unawaited(settings.setLanguage(value.first)),
                        ),
                      ],
                    ),
                  ),
                ),
                Gaps.lg,
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.science_outlined),
                    title: Text(l10n.errorLab),
                    subtitle: Text(l10n.errorLabSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.errorLab),
                  ),
                ),
                Gaps.xl,
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.logout),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: Padding(
        padding: EdgeInsets.all(Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 72, height: 72, radius: 36),
                Gaps.lg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 20, width: 160),
                      Gaps.sm,
                      SkeletonBox(height: 14, width: 90),
                    ],
                  ),
                ),
              ],
            ),
            Gaps.xl,
            SkeletonBox(height: 160, radius: Radii.lg),
            Gaps.lg,
            SkeletonBox(height: 140, radius: Radii.lg),
          ],
        ),
      ),
    );
  }
}
