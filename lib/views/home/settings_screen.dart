// lib/views/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_screen.dart';
import '../../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false; // Changed to false for white theme
  bool _autoPlayEnabled = true;
  bool _highQualityAudio = false;
  String _selectedLanguage = 'English';
  double _cacheSize = 150.0; // MB

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Japanese',
    'Korean',
    'Chinese',
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundLight,
        cardColor: Colors.grey[100],
        dividerColor: Colors.grey[300],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.grey[600]),
        ),
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryMaroon,
          secondary: AppColors.accentPink,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          title: const Text('Settings'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildUserProfileCard(),
            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkModeEnabled,
              onChanged: (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: _showLanguageSelector,
            ),

            // Playback Section
            _buildSectionHeader('Playback'),
            _buildSwitchTile(
              icon: Icons.play_circle_outline,
              title: 'Autoplay',
              value: _autoPlayEnabled,
              onChanged: (value) => setState(() => _autoPlayEnabled = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.high_quality_outlined,
              title: 'High Quality Streaming',
              value: _highQualityAudio,
              onChanged: (value) => setState(() => _highQualityAudio = value),
            ),

            // Storage Section
            _buildSectionHeader('Storage'),
            _buildSliderTile(
              icon: Icons.storage_outlined,
              title: 'Cache Size',
              value: _cacheSize,
              min: 0,
              max: 500,
              onChanged: (value) => setState(() => _cacheSize = value),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.cleaning_services_outlined,
              title: 'Clear Cache',
              onTap: _clearCache,
            ),

            // Account Section
            _buildSectionHeader('Account'),
            _buildListTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => _showSnackBar('Edit Profile feature coming soon'),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.security_outlined,
              title: 'Privacy Settings',
              onTap: () => _showSnackBar('Privacy settings coming soon'),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.help_outline,
              title: 'Help',
              onTap: () => _showSnackBar('Help center coming soon'),
            ),
            _buildDivider(),
            _buildListTile(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              onTap: _handleSignOut,
              textColor: Colors.red,
            ),

            // App Info
            _buildSectionHeader('About'),
            _buildListTile(
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryMaroon,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[300],
      indent: 56,
    );
  }

  Widget _buildUserProfileCard() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage: authViewModel.userPhotoURL.isNotEmpty
                    ? NetworkImage(authViewModel.userPhotoURL)
                    : null,
                child: authViewModel.userPhotoURL.isEmpty
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authViewModel.userDisplayName,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authViewModel.userEmail,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[500]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      secondary: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: Colors.black87),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryMaroon,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black87),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600]),
      )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[500],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Colors.black87),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.black87)),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: AppColors.primaryMaroon,
            inactiveColor: Colors.grey[300],
          ),
          Text(
            '${value.round()} MB',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[100],
        title: Text(
          'Log out?',
          style: TextStyle(color: Colors.black87),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMaroon,
              foregroundColor: Colors.white,
            ),
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Language',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._languages.map((language) => ListTile(
            title: Text(
              language,
              style: TextStyle(
                color: _selectedLanguage == language
                    ? AppColors.primaryMaroon
                    : Colors.black87,
              ),
            ),
            trailing: _selectedLanguage == language
                ? Icon(Icons.check, color: AppColors.primaryMaroon)
                : null,
            onTap: () {
              setState(() => _selectedLanguage = language);
              Navigator.pop(context);
              _showSnackBar('Language changed to $language');
            },
          )),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[100],
        title: Text(
          'Clear Cache',
          style: TextStyle(color: Colors.black87),
        ),
        content: Text(
          'This will clear ${_cacheSize.round()} MB of cached data.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _cacheSize = 0.0);
              _showSnackBar('Cache cleared successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMaroon,
              foregroundColor: Colors.white,
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}