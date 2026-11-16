import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_spacing.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:basketly/features/checkout/domain/payment.dart';
import 'package:flutter/material.dart';

class PaymentSection extends StatelessWidget {
  const PaymentSection({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.cardFormKey,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;
  final GlobalKey<FormState> cardFormKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Option(
          title: 'Cash on delivery',
          subtitle: 'Pay the rider when your order arrives',
          icon: Icons.payments_outlined,
          selected: selected == PaymentMethod.cashOnDelivery,
          onTap: () => onSelected(PaymentMethod.cashOnDelivery),
        ),
        const SizedBox(height: BkSpace.sm),
        _Option(
          title: 'Card',
          subtitle: 'Demo: try 4242 4242 4242 4242',
          icon: Icons.credit_card_rounded,
          badge: 'Demo',
          selected: selected == PaymentMethod.demoCard,
          onTap: () => onSelected(PaymentMethod.demoCard),
          // The form is only built while Card is chosen.
          child: selected == PaymentMethod.demoCard ? _DemoCardForm(formKey: cardFormKey) : null,
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
    this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Material(
        color: BkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BkRadius.card,
          side: BorderSide(color: selected ? BkColors.plum : Colors.transparent, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BkSpace.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: selected ? BkColors.plum : BkColors.muted,
                    ),
                    const SizedBox(width: BkSpace.md),
                    Icon(icon, color: BkColors.ink, size: 20),
                    const SizedBox(width: BkSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: BkText.bodyStrong),
                          Text(subtitle, style: BkText.tiny),
                        ],
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEBC6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6A4300)),
                        ),
                      ),
                  ],
                ),
                ?child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoCardForm extends StatelessWidget {
  const _DemoCardForm({required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    InputDecoration field(String label, [String? hint]) => InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: BkColors.background,
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        );

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: BkSpace.lg),
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 23,
              autofillHints: const [AutofillHints.creditCardNumber],
              decoration: field('Card number', '4242 4242 4242 4242'),
              validator: CardRules.number,
            ),
            const SizedBox(height: BkSpace.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.datetime,
                    maxLength: 7,
                    decoration: field('Expiry', 'MM/YY'),
                    validator: (v) => CardRules.expiry(v),
                  ),
                ),
                const SizedBox(width: BkSpace.md),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: field('CVC'),
                    validator: CardRules.cvc,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
