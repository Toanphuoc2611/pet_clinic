import 'package:ung_dung_thu_y/dto/address/Province.dart';
import 'package:ung_dung_thu_y/dto/address/district.dart';
import 'package:ung_dung_thu_y/dto/address/ward.dart';
import 'package:ung_dung_thu_y/remote/address/address_api_client.dart';

class AddressRepository {
  final AddressApiClient addressApiClient;
  AddressRepository(this.addressApiClient);

  Future<List<Province>> getProvinces() async {
    return await addressApiClient.getProvinces();
  }

  Future<List<District>> getDistricts(int provinceId) async {
    return await addressApiClient.getDistricts(provinceId);
  }

  Future<List<Ward>> getWards(int districtId) async {
    return await addressApiClient.getWards(districtId);
  }
}
