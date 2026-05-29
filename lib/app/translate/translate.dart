import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'app_title': 'Motion Alarm Pocket',
          'start': 'Start',
          'stop': 'Stop',
          'reset': 'Reset',
          'save': 'Save',
          'settings': 'Settings',
          'history': 'History',
          'no_history': 'No local history yet',
          'permission_needed': 'Permission needed',
          'permission_microphone_detail':
              'Microphone input is only used locally while listening for claps. No recording is saved.',
          'sensor_unavailable': 'Sensor unavailable on this device',
          'policy_note': 'Entertainment and local utility only. No impossible detection claims.',
          'ad_hint': 'Ad appears only after a result, session, or saved setup.',
        },
        'ko_KR': {
          'app_title': 'Motion Alarm Pocket',
          'start': '시작',
          'stop': '중지',
          'reset': '초기화',
          'save': '저장',
          'settings': '설정',
          'history': '기록',
          'no_history': '아직 로컬 기록이 없습니다',
          'permission_needed': '권한 필요',
          'permission_microphone_detail':
              '마이크 입력은 박수 감지 중 로컬에서만 사용하며 녹음을 저장하지 않습니다.',
          'sensor_unavailable': '이 기기에서 센서를 사용할 수 없습니다',
          'policy_note': '엔터테인먼트 및 로컬 유틸리티입니다. 불가능한 탐지 주장은 하지 않습니다.',
          'ad_hint': '광고는 결과, 세션 종료, 설정 저장 이후에만 표시됩니다.',
        },
      };
}
