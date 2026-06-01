import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';
import '../services/hive_service.dart';

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find();

  static const int totalPages = 3;
  static const int lastPageIndex = totalPages - 1;

  final pageController = PageController();
  final currentPage = 0.obs;

  bool get isLastPage => currentPage.value == lastPageIndex;

  void onPageChanged(int index) => currentPage.value = index;

  void nextPage() {
    if (currentPage.value >= lastPageIndex) return;
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void skip() {
    pageController.animateToPage(
      lastPageIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> complete() async {
    await HiveService.to.markOnboardingComplete();
    Get.offAllNamed(Routes.home);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
