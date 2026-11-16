import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/checkout/domain/delivery_address.dart';
import 'package:basketly/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:basketly/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A saved address as a card with "Edit", or the form to enter one.
class AddressSection extends StatelessWidget {
  const AddressSection({super.key, required this.checkout});

  final CheckoutState checkout;

  @override
  Widget build(BuildContext context) {
    final address = checkout.address;

    if (checkout.showAddressForm) {
      return _AddressForm(initial: address);
    }

    return Container(
      padding: const EdgeInsets.all(BkSpace.md),
      decoration: const BoxDecoration(color: BkColors.surface, borderRadius: BkRadius.card),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: BkColors.soft, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.location_on_outlined, color: BkColors.plum),
          ),
          const SizedBox(width: BkSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deliver to ${address!.fullName}', style: BkText.bodyStrong),
                Text(address.oneLine, style: BkText.small),
                Text(address.phone, style: BkText.tiny),
              ],
            ),
          ),
          TextButton(
            onPressed: context.read<CheckoutCubit>().editAddress,
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({this.initial});

  final DeliveryAddress? initial;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.fullName);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _line = TextEditingController(text: widget.initial?.line);
  late final _city = TextEditingController(text: widget.initial?.city ?? 'Lahore');

  @override
  void dispose() {
    for (final c in [_name, _phone, _line, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<CheckoutCubit>().useAddress(DeliveryAddress(
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          line: _line.text.trim(),
          city: _city.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BkSpace.lg),
      decoration: const BoxDecoration(color: BkColors.surface, borderRadius: BkRadius.card),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Delivery address', style: BkText.heading),
            const SizedBox(height: BkSpace.md),
            _field(_name, 'Full name', AddressRules.name, hints: [AutofillHints.name]),
            _field(_phone, 'Phone', AddressRules.phone,
                keyboard: TextInputType.phone, hints: [AutofillHints.telephoneNumber]),
            _field(_line, 'House, street, area', AddressRules.line,
                hints: [AutofillHints.streetAddressLine1]),
            _field(_city, 'City', AddressRules.city, hints: [AutofillHints.addressCity]),
            const SizedBox(height: BkSpace.sm),
            FilledButton.tonal(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: BkColors.soft,
                foregroundColor: BkColors.plum,
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
              ),
              child: const Text('Use this address'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    FormFieldValidator<String> validator, {
    TextInputType? keyboard,
    List<String>? hints,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BkSpace.md),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboard,
        autofillHints: hints,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: BkColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
