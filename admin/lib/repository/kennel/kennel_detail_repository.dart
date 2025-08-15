import 'package:admin/dto/result_file.dart';
import 'package:admin/remote/kennel/kennel_detail_api_client.dart';
import 'package:admin/repository/auth/auth_repository.dart';

class KennelDetailRepository {
  final KennelDetailApiClient kennelDetailApiClient;
  final AuthRepository authRepository;
  KennelDetailRepository(this.authRepository, this.kennelDetailApiClient);
}
