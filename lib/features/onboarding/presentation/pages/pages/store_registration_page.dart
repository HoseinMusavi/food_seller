// lib/features/onboarding/presentation/pages/store_registration_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/utils/lat_lng.dart';
import 'package:food_seller/features/onboarding/domain/usecases/create_store_usecase.dart';
import 'package:food_seller/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:food_seller/features/onboarding/presentation/pages/map_selection_page.dart';

class StoreRegistrationPage extends StatefulWidget {
  const StoreRegistrationPage({super.key});

  @override
  State<StoreRegistrationPage> createState() => _StoreRegistrationPageState();
}

class _StoreRegistrationPageState extends State<StoreRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cuisineController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  void _onSelectLocation() async {
    // رفتن به صفحه نقشه و دریافت نتیجه
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const MapSelectionPage()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('لطفا موقعیت مکانی فروشگاه را روی نقشه انتخاب کنید.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final params = CreateStoreParams(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        cuisineType: _cuisineController.text.trim(),
        deliveryTimeEstimate: _deliveryTimeController.text.trim(),
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );

      context.read<OnboardingCubit>().registerStore(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت فروشگاه (قدم ۱ از ۱)'),
      ),
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          // (حالت موفقیت توسط AuthWrapper مدیریت می‌شود)
        },
        builder: (context, state) {
          final isRegistering = state is OnboardingStoreRegistering;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اطلاعات فروشگاه خود را وارد کنید',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'نام فروشگاه'),
                    validator: (v) => v!.isEmpty ? 'نام الزامی است' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'آدرس متنی'),
                    validator: (v) => v!.isEmpty ? 'آدرس الزامی است' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cuisineController,
                    decoration: const InputDecoration(
                        labelText: 'نوع غذا (مثال: ایرانی، فست‌فود، ایتالیایی)'),
                    validator: (v) => v!.isEmpty ? 'نوع غذا الزامی است' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deliveryTimeController,
                    decoration: const InputDecoration(
                        labelText: 'زمان تخمینی ارسال (مثال: ۳۰ - ۴۵ دقیقه)'),
                    validator: (v) => v!.isEmpty ? 'زمان الزامی است' : null,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    icon: Icon(_selectedLocation == null
                        ? Icons.map_outlined
                        : Icons.check_circle_outline),
                    label: Text(_selectedLocation == null
                        ? 'انتخاب موقعیت مکانی روی نقشه'
                        : 'موقعیت مکانی انتخاب شد'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: _selectedLocation == null
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: _selectedLocation == null
                            ? Theme.of(context).colorScheme.outline
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: isRegistering ? null : _onSelectLocation,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isRegistering ? null : _submitForm,
                    child: isRegistering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تکمیل ثبت‌نام و ایجاد فروشگاه'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}