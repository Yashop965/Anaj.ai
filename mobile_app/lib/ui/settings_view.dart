import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _offlineMode = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        subtitle: Text("सेटिंग्स"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // General Settings
            _buildSectionHeader("General"),
            _buildSettingsTile(
              title: "Language",
              subtitle: _selectedLanguage,
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: ['English', 'Hindi', 'Marathi']
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "Theme",
              subtitle: _selectedTheme,
              trailing: DropdownButton<String>(
                value: _selectedTheme,
                items: ['Light', 'Dark', 'System']
                    .map((theme) => DropdownMenuItem(
                          value: theme,
                          child: Text(theme),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
            ),

            // Notification Settings
            _buildSectionHeader("Notifications"),
            _buildSwitchTile(
              title: "Enable Notifications",
              subtitle: "Get updates about crop health",
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "Notification Frequency",
              subtitle: "Daily at 8:00 AM",
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),

            // Privacy & Location
            _buildSectionHeader("Privacy & Location"),
            _buildSwitchTile(
              title: "Location Permission",
              subtitle: "Allow access to your location",
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "Privacy Policy",
              subtitle: "Read our privacy policy",
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),

            // Offline & Data
            _buildSectionHeader("Data & Storage"),
            _buildSwitchTile(
              title: "Offline Mode",
              subtitle: "Work without internet",
              value: _offlineMode,
              onChanged: (value) {
                setState(() {
                  _offlineMode = value;
                });
              },
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "Clear Cache",
              subtitle: "Free up storage space",
              trailing: ElevatedButton(
                onPressed: () {
                  _showClearCacheDialog();
                },
                child: Text("Clear"),
              ),
              onTap: () {},
            ),

            // AI & Model Settings
            _buildSectionHeader("AI Model"),
            _buildSettingsTile(
              title: "Use Local AI Model",
              subtitle: "Faster, offline processing",
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "Download Models",
              subtitle: "Download latest AI models",
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Models already up to date")),
                );
              },
            ),

            // About & Help
            _buildSectionHeader("About & Support"),
            _buildSettingsTile(
              title: "App Version",
              subtitle: "Version 1.0.0",
              trailing: Icon(Icons.info),
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "Contact Support",
              subtitle: "Get help from our team",
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            Divider(indent: 16, endIndent: 16),
            _buildSettingsTile(
              title: "About Anaj.ai",
              subtitle: "Learn more about us",
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear Cache"),
        content: Text("Are you sure you want to clear the cache? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Cache cleared successfully")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            child: Text("Clear"),
          ),
        ],
      ),
    );
  }
}
