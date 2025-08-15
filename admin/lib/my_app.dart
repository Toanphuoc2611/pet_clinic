import 'package:admin/bloc/auth/auth_bloc.dart';
import 'package:admin/bloc/doctor_revenue/doctor_revenue_bloc.dart';
import 'package:admin/bloc/invoice/invoice_bloc.dart';
import 'package:admin/bloc/user/doctor/doctor_list_bloc.dart';
import 'package:admin/bloc/user/user_bloc.dart';
import 'package:admin/bloc/log_user_credit/log_user_credit_bloc.dart';
import 'package:admin/bloc/analytics/analytics_bloc.dart';
import 'package:admin/bloc/pet/pet_bloc.dart';
import 'package:admin/bloc/appointment/appointment_bloc.dart';
import 'package:admin/bloc/invoice_management/invoice_management_bloc.dart';
import 'package:admin/bloc/medical_record_management/medical_record_management_bloc.dart';
import 'package:admin/bloc/service_kennel_management/service_kennel_management_bloc.dart';
import 'package:admin/bloc/inventory_management/inventory_management_bloc.dart';
import 'package:admin/bloc/account_management/account_management_bloc.dart';
import 'package:admin/core/http/http_client.dart';
import 'package:admin/core/route/router.dart';
import 'package:admin/data/auth/local_data/auth_local_data_source.dart';
import 'package:admin/remote/api_service.dart';
import 'package:admin/remote/appointment/appointment_api_client.dart';
import 'package:admin/remote/invoice_kennel/invoice_kennel_api_client.dart';
import 'package:admin/remote/auth/auth_api_client.dart';
import 'package:admin/remote/invoice/invoice_api_client.dart';
import 'package:admin/remote/kennel/kennel_api_client.dart';
import 'package:admin/remote/kennel/kennel_detail_api_client.dart';
import 'package:admin/remote/medical_record/medical_record_api_client.dart';
import 'package:admin/remote/medication/medication_api_client.dart';
import 'package:admin/remote/pet/pet_api_client.dart';
import 'package:admin/remote/prescription/prescription_api_client.dart';
import 'package:admin/remote/user/user_api_client.dart';
import 'package:admin/remote/log_user_credit/log_user_credit_api_client.dart';
import 'package:admin/remote/service/service_api_client.dart';
import 'package:admin/remote/inventory/inventory_api_client.dart';
import 'package:admin/remote/account/account_api_client.dart';
import 'package:admin/repository/appointment/appointment_repository.dart';
import 'package:admin/repository/auth/auth_repository.dart';
import 'package:admin/repository/invoice/invoice_repository.dart';
import 'package:admin/repository/kennel/kennel_detail_repository.dart';
import 'package:admin/repository/kennel/kennel_repository.dart';
import 'package:admin/repository/medical_record/medical_record_repository.dart';
import 'package:admin/repository/medication/medication_repository.dart';
import 'package:admin/repository/pet/pet_repository.dart';
import 'package:admin/repository/inventory/inventory_repository.dart';
import 'package:admin/repository/prescription/prescription_repository.dart';
import 'package:admin/repository/service/service_repository.dart';
import 'package:admin/repository/account/account_repository.dart';
import 'package:admin/repository/user/user_repository.dart';
import 'package:admin/repository/log_user_credit/log_user_credit_repository.dart';
import 'package:admin/repository/invoice_kennel/invoice_kennel_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        RepositoryProvider<AppointmentRepository>(
          create:
              (context) => AppointmentRepository(
                AppointmentApiClient(ApiService(dio)),
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
        RepositoryProvider<LogUserCreditRepository>(
          create:
              (context) => LogUserCreditRepository(
                authRepository: context.read<AuthRepository>(),
                logUserCreditApiClient: LogUserCreditApiClient(ApiService(dio)),
              ),
        ),
        RepositoryProvider<InvoiceKennelRepository>(
          create:
              (context) => InvoiceKennelRepository(
                InvoiceKennelApiClient(ApiService(dio)),
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
        RepositoryProvider<InventoryRepository>(
          create:
              (context) => InventoryRepository(
                InventoryApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<AccountRepository>(
          create:
              (context) => AccountRepository(
                AccountApiClient(ApiService(dio)),
                context.read<AuthRepository>(),
              ),
        ),
        RepositoryProvider<MedicationRepository>(
          create:
              (context) => MedicationRepository(
                MedicationApiClient(ApiService(dio)),
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
          BlocProvider(
            create: (context) => InvoiceBloc(context.read<InvoiceRepository>()),
          ),
          BlocProvider(
            create: (context) => DoctorListBloc(context.read<UserRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    DoctorRevenueBloc(context.read<InvoiceRepository>()),
          ),
          BlocProvider(
            create:
                (context) => AnalyticsBloc(context.read<InvoiceRepository>()),
          ),
          BlocProvider(
            create: (context) => UserBloc(context.read<UserRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    LogUserCreditBloc(context.read<LogUserCreditRepository>()),
          ),
          BlocProvider(
            create: (context) => PetBloc(context.read<PetRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    AppointmentBloc(context.read<AppointmentRepository>()),
          ),
          BlocProvider(
            create:
                (context) => InvoiceManagementBloc(
                  invoiceRepository: context.read<InvoiceRepository>(),
                  invoiceKennelRepository:
                      context.read<InvoiceKennelRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => InventoryManagementBloc(
                  medicationRepository: context.read<MedicationRepository>(),
                  inventoryRepository: context.read<InventoryRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => AccountManagementBloc(
                  accountRepository: context.read<AccountRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => MedicalRecordManagementBloc(
                  medicalRecordRepository:
                      context.read<MedicalRecordRepository>(),
                  prescriptionRepository:
                      context.read<PrescriptionRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => ServiceKennelManagementBloc(
                  serviceRepository: context.read<ServiceRepository>(),
                  kennelRepository: context.read<KennelRepository>(),
                ),
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: myRouter,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
          locale: const Locale('vi', 'VN'),
        ),
      ),
    );
  }
}
