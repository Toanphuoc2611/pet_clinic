import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_bloc.dart';

import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/service/service_bloc.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/user_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_bloc.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart' as route;
import 'package:ung_dung_thu_y/data/auth/local_data/auth_local_data_source.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/appointment/appointment_api_client.dart';
import 'package:ung_dung_thu_y/remote/auth/auth_api_client.dart';
import 'package:ung_dung_thu_y/remote/invoice/invoice_api_client.dart';
import 'package:ung_dung_thu_y/remote/invoice_deposit/invoice_deposit_api_client.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_api_client.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_detail_api_client.dart';
import 'package:ung_dung_thu_y/remote/medical_record/medical_record_api_client.dart';
import 'package:ung_dung_thu_y/remote/pet/pet_api_client.dart';
import 'package:ung_dung_thu_y/remote/prescription/prescription_api_client.dart';
import 'package:ung_dung_thu_y/remote/service/service_api_client.dart';
import 'package:ung_dung_thu_y/remote/upload_avatar/upload_avatar_api.dart';
import 'package:ung_dung_thu_y/remote/user/user_api_client.dart';
import 'package:ung_dung_thu_y/repository/appointment/appointment_repository.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/invoice/invoice_repository.dart';
import 'package:ung_dung_thu_y/repository/invoice_deposit/invoice_deposit_repository.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_repository.dart';
import 'package:ung_dung_thu_y/repository/medical_record/medical_record_repository.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/repository/prescription/prescription_repository.dart';
import 'package:ung_dung_thu_y/repository/service/service_repository.dart';
import 'package:ung_dung_thu_y/repository/upload_avatar/upload_avatar_repository.dart';
import 'package:ung_dung_thu_y/repository/user/user_repository.dart';
import 'package:ung_dung_thu_y/repository/user_credit/user_credit_repository.dart';
import 'package:ung_dung_thu_y/remote/user_credit/user_credit_api_client.dart';

class HomeApp extends StatelessWidget {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create:
              (context) => AuthRepository(
                authApiClient: AuthApiClient(dio),
                authLocalDataSource: AuthLocalDataSource(storage),
              ),
        ),
        RepositoryProvider<UserRepository>(
          create:
              (context) => UserRepository(
                authRepository: context.read<AuthRepository>(),
                userApiClient: UserApiClient(ApiService(dio)),
              ),
        ),
        RepositoryProvider<PetRepository>(
          create:
              (context) => PetRepository(
                petApiClient: PetApiClient(ApiService(dio)),
                authRepository: context.read<AuthRepository>(),
              ),
        ),

        RepositoryProvider<UploadAvatarRepository>(
          create:
              (context) => UploadAvatarRepository(
                UploadAvatarApi(dio),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<ServiceRepository>(
          create:
              (context) => ServiceRepository(
                context.read<AuthRepository>(),
                ServiceApiClient(ApiService(dio)),
              ),
        ),
        RepositoryProvider<AppointmentRepository>(
          create:
              (context) => AppointmentRepository(
                AppointmentApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<InvoiceDepositRepository>(
          create:
              (context) => InvoiceDepositRepository(
                InvoiceDepositApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<KennelDetailRepository>(
          create:
              (context) => KennelDetailRepository(
                context.read<AuthRepository>(),
                KennelDetailApiClient(ApiService(dio)),
              ),
        ),
        RepositoryProvider<KennelRepository>(
          create:
              (context) => KennelRepository(
                KennelApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<PrescriptionRepository>(
          create:
              (context) => PrescriptionRepository(
                PrescriptionApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => InvoiceRepository(
                InvoiceApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider(
          create:
              (context) => MedicalRecordRepository(
                MedicalRecordApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<UserCreditRepository>(
          create:
              (context) => UserCreditRepository(
                UserCreditApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            // create AuthBloc to use entire app
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          // create UserBloc to use entire app
          BlocProvider(
            create: (context) => UserBloc(context.read<UserRepository>()),
          ),
          // create PetBloc to use entire app
          BlocProvider(
            create: (context) => PetBloc(context.read<PetRepository>()),
          ),

          BlocProvider(
            create:
                (context) =>
                    UploadAvatarBloc(context.read<UploadAvatarRepository>()),
          ),
          BlocProvider(
            create: (context) => ServiceBloc(context.read<ServiceRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    AppointmentBloc(context.read<AppointmentRepository>()),
          ),
          BlocProvider(
            create:
                (context) => InvoiceDepositBloc(
                  context.read<InvoiceDepositRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) =>
                    KennelDetailBloc(context.read<KennelDetailRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    PrescriptionBloc(context.read<PrescriptionRepository>()),
          ),
          BlocProvider(
            create: (context) => InvoiceBloc(context.read<InvoiceRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    RedirectVnpayBloc(context.read<InvoiceRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    MedicalRecordBloc(context.read<MedicalRecordRepository>()),
          ),
          BlocProvider(
            create:
                (context) => DoctorAppointmentBloc(
                  context.read<AppointmentRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => DoctorKennelDetailBloc(
                  context.read<KennelDetailRepository>(),
                ),
          ),
          BlocProvider(
            create: (context) => KennelBloc(context.read<KennelRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    UserCreditBloc(context.read<UserCreditRepository>()),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: route.myRouter,
        ),
      ),
    );
  }
}
