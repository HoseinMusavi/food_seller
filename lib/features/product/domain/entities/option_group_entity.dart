// lib/features/product/domain/entities/option_group_entity.dart
import 'package:equatable/equatable.dart';
import 'option_entity.dart';

class OptionGroupEntity extends Equatable {
  final int id;
  final int storeId;
  final String name;
  final List<OptionEntity> options;

  const OptionGroupEntity({
    required this.id,
    required this.storeId,
    required this.name,
    this.options = const [],
  });

  @override
  List<Object?> get props => [id, storeId, name, options];
}