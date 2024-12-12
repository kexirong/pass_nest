import 'package:get/get.dart';
import '../models/account/change_record.dart';
import '../services/db/data_provider.dart';

class ChangeRecordSController extends GetxController {
  final _records = <ChangeRecord>[];
  final _dataProvider = Get.find<DataProviderService>();

  List<ChangeRecord> get records => _records;

  Future<void> loadData() async {
    _records.addAll(await _dataProvider.getChangeRecords());
  }
}
