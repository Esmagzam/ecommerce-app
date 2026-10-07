import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validator.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/orders_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final order = await ref.read(checkoutProvider.notifier).submitOrder(
          customerName: _nameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          shippingAddress: _addressController.text.trim(),
          note: _noteController.text.trim(),
        );

    if (mounted && order != null) {
      ref.invalidate(ordersProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Захиалга амжилттай үүслээ: #${order.number}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pushReplacement('/orders/${order.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cartState = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Захиалга баталгаажуулах'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (checkoutState.generalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          checkoutState.generalError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'Хүлээн авагчийн мэдээлэл',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _nameController,
                label: 'Хүлээн авагчийн нэр',
                hintText: 'Бат',
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                errorText: checkoutState.getFieldError('customer_name'),
                validator: (v) =>
                    Validator.required(v, 'Хүлээн авагчийн нэр оруулна уу.'),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _phoneController,
                label: 'Утасны дугаар',
                hintText: '99112233',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                errorText: checkoutState.getFieldError('customer_phone'),
                validator: Validator.phone,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _addressController,
                label: 'Хүргэлтийн хаяг',
                hintText: 'УБ, СБД, 1-р хороо...',
                maxLines: 2,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                errorText: checkoutState.getFieldError('shipping_address'),
                validator: (v) =>
                    Validator.required(v, 'Хүргэлтийн хаягаа оруулна уу.'),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _noteController,
                label: 'Нэмэлт тэмдэглэл (заавал биш)',
                hintText: 'Оройн 18 цагаас хойш хүргэх гэх мэт',
                maxLines: 2,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                errorText: checkoutState.getFieldError('note'),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Захиалгын задаргаа',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    ...cartState.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName} × ${item.quantity}',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(item.lineTotal),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Нийт төлөх дүн:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(cartState.totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Захиалга батлах (${Formatters.formatCurrency(cartState.totalAmount)})',
                isLoading: checkoutState.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
