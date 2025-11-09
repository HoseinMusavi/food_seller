// lib/features/product/domain/entities/option_entity.dart
import 'package:equatable/equatable.dart';

class OptionEntity extends Equatable {
  final int id;
  final int optionGroupId;
  final String name;
  final double priceDelta;

  const OptionEntity({
    required this.id,
    required this.optionGroupId,
    required this.name,
    required this.priceDelta,
  });

  @override
  List<Object?> get props => [id, optionGroupId, name, priceDelta];
}