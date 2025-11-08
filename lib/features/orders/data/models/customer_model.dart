// lib/features/orders/data/models/customer_model.dart
import 'package:equatable/equatable.dart';

// ما در اینجا به Entity کامل نیاز نداریم، فقط یک کلاس ساده برای پارس کردن
class CustomerModel extends Equatable {
  final String? fullName;
  final String? phone;
  // (می‌توان فیلدهای دیگر را در صورت نیاز اضافه کرد)

  const CustomerModel({this.fullName, this.phone});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
    );
  }

  @override
  List<Object?> get props => [fullName, phone];
}