// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial());

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    emit(AuthLoading());
    final result = await signupUseCase(
      SignupParams(email: email, password: password, fullName: fullName),
    );
    result.fold(
      (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> signOut() async {
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthInitial()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'An unknown error occurred';
  }
}