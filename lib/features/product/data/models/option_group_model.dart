// lib/features/product/data/models/option_group_model.dart
import 'package:food_seller/features/product/data/models/option_model.dart';
import 'package:food_seller/features/product/domain/entities/option_group_entity.dart';

class OptionGroupModel extends OptionGroupEntity {
  const OptionGroupModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.options,
  });

  factory OptionGroupModel.fromJson(Map<String, dynamic> json) {
    // گزینه‌های تودرتو (nested) را پارس می‌کند
    final optionsList = (json['options'] as List<dynamic>?)
            ?.map((optionJson) =>
                OptionModel.fromJson(optionJson as Map<String, dynamic>))
            .toList() ??
        []; // اگر لیستی وجود نداشت، لیست خالی برگردان

    return OptionGroupModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      options: optionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'options': options.map((opt) => (opt as OptionModel).toJson()).toList(),
    };
  }
}