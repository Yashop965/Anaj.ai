import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? "User");
    _emailController = TextEditingController(text: user?.email ?? "");
    _phoneController = TextEditingController(text: "+91 98765 43210");
    _locationController = TextEditingController(text: "Maharashtra, India");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        subtitle: Text("प्रोफाइल"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile updated successfully")),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "User",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user?.email ?? "user@email.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Form
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _buildProfileField(
                    label: "Full Name",
                    controller: _nameController,
                    icon: Icons.person,
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 16),

                  // Email
                  _buildProfileField(
                    label: "Email",
                    controller: _emailController,
                    icon: Icons.email,
                    enabled: false,
                  ),
                  SizedBox(height: 16),

                  // Phone
                  _buildProfileField(
                    label: "Phone Number",
                    controller: _phoneController,
                    icon: Icons.phone,
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 16),

                  // Location
                  _buildProfileField(
                    label: "Location",
                    controller: _locationController,
                    icon: Icons.location_on,
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 32),

                  // Stats Section
                  _buildStatsSection(),
                  SizedBox(height: 32),

                  // Settings & Options
                  _buildSettingsSection(),
                  SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerColor,
                      ),
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginView()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Statistics",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("24", "Scans"),
                _buildStatItem("18", "Healthy"),
                _buildStatItem("6", "Issues"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Manage notifications",
            onTap: () {},
          ),
          Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.security,
            title: "Privacy & Security",
            subtitle: "Change password",
            onTap: () {},
          ),
          Divider(height: 1),
          _buildSettingsTile(
            icon: Icons.info,
            title: "About",
            subtitle: "Version 1.0.0",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
