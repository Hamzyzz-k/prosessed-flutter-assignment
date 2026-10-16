import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/l10n/l10n.dart';
import 'package:shopsphere/core/theme/app_spacing.dart';
import 'package:shopsphere/core/widgets/brand_mark.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_user.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _demoUsername = 'emilys';
  static const _demoPassword = 'emilyspass';

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  var _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    unawaited(
      context.read<LoginCubit>().submit(
        username: _username.text,
        password: _password.text,
      ),
    );
  }

  void _fillDemo() {
    _username.text = _demoUsername;
    _password.text = _demoPassword;
    _formKey.currentState?.validate();
    context.read<LoginCubit>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sessionExpired = context.select<AuthCubit, bool>(
      (c) => switch (c.state) {
        Unauthenticated(:final sessionExpired) => sessionExpired,
        _ => false,
      },
    );

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (a, b) => b.status == LoginStatus.success,
      listener: (context, state) =>
          context.read<AuthCubit>().signedIn(state.user!),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Insets.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) {
                    final busy = state.isSubmitting;
                    return Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: BrandMark()),
                            Gaps.xl,
                            Text(
                              l10n.loginTitle,
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            Gaps.xs,
                            Text(
                              l10n.loginSubtitle,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Gaps.xl,
                            if (state.failure != null)
                              _Notice(text: state.failure!.describe(l10n))
                            else if (sessionExpired)
                              _Notice(text: l10n.errorSessionExpired),
                            TextFormField(
                              controller: _username,
                              enabled: !busy,
                              autofillHints: const [AutofillHints.username],
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.usernameLabel,
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                ),
                              ),
                              onChanged: (_) =>
                                  context.read<LoginCubit>().clearError(),
                              validator: (value) =>
                                  switch (CredentialRules.username(value)) {
                                    null => null,
                                    CredentialError.required =>
                                      l10n.usernameRequired,
                                    CredentialError.tooShort =>
                                      l10n.fieldTooShort(
                                        CredentialRules.minUsernameLength,
                                      ),
                                  },
                            ),
                            Gaps.lg,
                            TextFormField(
                              controller: _password,
                              enabled: !busy,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: l10n.passwordLabel,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  tooltip: _obscure
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              onChanged: (_) =>
                                  context.read<LoginCubit>().clearError(),
                              validator: (value) =>
                                  switch (CredentialRules.password(value)) {
                                    null => null,
                                    CredentialError.required =>
                                      l10n.passwordRequired,
                                    CredentialError.tooShort =>
                                      l10n.fieldTooShort(
                                        CredentialRules.minPasswordLength,
                                      ),
                                  },
                            ),
                            Gaps.xl,
                            FilledButton(
                              onPressed: busy ? null : _submit,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: busy
                                    ? const SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(l10n.signIn),
                              ),
                            ),
                            Gaps.sm,
                            TextButton.icon(
                              onPressed: busy ? null : _fillDemo,
                              icon: const Icon(Icons.bolt_rounded),
                              label: Text(l10n.useDemoAccount),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A soft red notice above the form (wrong password, session expired...).
class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.lg),
      child: Semantics(
        liveRegion: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Insets.md),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: scheme.onErrorContainer,
                ),
                Gaps.md,
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
