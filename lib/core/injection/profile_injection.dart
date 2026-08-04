import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:get_it/get_it.dart';

void initProfile() {
  final sl = GetIt.instance;

  sl.registerFactory(
    () => ProfileBloc(updateUser: sl<UpdateUser>(), imagePickerService: sl()),
  );
}
