import 'package:flutter/material.dart';
import 'package:showtok/constants/api_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('설정', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // 🔹 설정 항목 박스
            _buildSectionCard([
              _buildSettingItem(Icons.language, '언어'),
              _buildSettingItem(Icons.dark_mode, '다크 모드'),
              _buildSettingItem(Icons.interests, '관심 키워드 설정'),
              _buildSettingItem(Icons.notifications, '알림 설정'),
              _buildSettingItem(Icons.delete_sweep, '캐시 삭제'),
            ]),

            const SizedBox(height: 16),

            // 🔹 약관 관련 박스
            _buildSectionCard([
              _buildSettingItem(Icons.privacy_tip, '약관 및 개인정보 처리 동의', () {
                _showDialog(context, '약관 및 개인정보 처리 동의', '''
앱을 이용함으로써 사용자님은 본 서비스의 이용약관 및 개인정보 수집·이용에 동의하게 됩니다. 수집된 정보는 더 나은 서비스 제공을 위해 활용됩니다. 
자세한 사항은 고객센터 또는 홈페이지를 참고해주세요.
''');
              }),
              _buildSettingItem(Icons.shield, '개인정보 처리방침', () {
                _showDialog(context, '개인정보 처리방침', '''
우리는 사용자 개인정보를 소중히 보호하며, 수집한 정보는 오직 서비스 제공 목적에 한해서만 사용됩니다. 
본 방침은 관련 법령에 따라 변경될 수 있으며, 최신 내용은 앱 내에서 확인 가능합니다.
''');
              }),
            ]),
          ],
        ),
      ),
    );
  }

  // 🔧 카드 박스 UI
  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // 🔧 설정 항목 UI
  Widget _buildSettingItem(IconData icon, String text, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }

  // 🔧 팝업 다이얼로그
  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
