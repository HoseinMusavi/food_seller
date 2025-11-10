// lib/features/settings/presentation/cubit/settings_state.dart
part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

// وضعیت اصلی: زمانی که اطلاعات فروشگاه (مثل is_open) لود شده است
class SettingsLoaded extends SettingsState {
  final StoreEntity store;
  // این فیلد برای نمایش لودر *فقط* روی دکمه Switch است
  final bool isUpdatingStatus; 

  const SettingsLoaded({
    required this.store,
    this.isUpdatingStatus = false,
  });

  SettingsLoaded copyWith({
    StoreEntity? store,
    bool? isUpdatingStatus,
  }) {
    return SettingsLoaded(
      store: store ?? this.store,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
    );
  }

  @override
  List<Object?> get props => [store, isUpdatingStatus];
}