import 'package:get/get.dart';
import '../models/campaign_model.dart';
import '../services/api_service.dart';
import '../services/campaign_service.dart';

class CampaignController extends GetxController {
  final CampaignService _campaignService = CampaignService(Get.find<ApiService>());

  final RxBool isLoading = true.obs;
  final RxList<CampaignModel> campaigns = <CampaignModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    isLoading.value = true;
    try {
      final res = await _campaignService.getCampaigns();
      if (res.success && res.data != null) {
        campaigns.assignAll(res.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
