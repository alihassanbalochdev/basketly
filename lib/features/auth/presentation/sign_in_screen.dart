import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/core/widgets/round_icon_button.dart';
import 'package:basketly/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:basketly/features/basket/presentation/widgets/basket_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<SignInCubit>().submit(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SignInCubit>().state;
    final creating = state.creatingAccount;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(BkSpace.xl),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                ),
              ),
              const SizedBox(height: BkSpace.xxl),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: BkColors.plum, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const BasketIcon(fill: 0.6, size: 36),
              ),
              const SizedBox(height: BkSpace.xl),
              Text(creating ? 'Create your account' : 'Sign in to Basketly', style: BkText.title),
              const SizedBox(height: BkSpace.sm),
              const Text('Your basket is kept while you sign in.', style: BkText.small),
              const SizedBox(height: BkSpace.xxl),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: _field('Email'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter your email address' : null,
              ),
              const SizedBox(height: BkSpace.md),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofillHints: [creating ? AutofillHints.newPassword : AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: _field('Password'),
                validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
              ),
              if (state.error case final error?) ...[
                const SizedBox(height: BkSpace.md),
                Text(error, style: BkText.small.copyWith(color: const Color(0xFFB3261E))),
              ],
              if (state.info case final info?) ...[
                const SizedBox(height: BkSpace.md),
                Text(info, style: BkText.small.copyWith(color: BkColors.plum)),
              ],
              const SizedBox(height: BkSpace.xl),
              FilledButton(
                onPressed: state.submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: BkColors.plum,
                  minimumSize: const Size.fromHeight(56),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: state.submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(creating ? 'Create account' : 'Sign in'),
              ),
              const SizedBox(height: BkSpace.sm),
              TextButton(
                onPressed: state.submitting ? null : context.read<SignInCubit>().toggleMode,
                child: Text(creating ? 'I already have an account' : 'New here? Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _field(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: BkColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );
}
