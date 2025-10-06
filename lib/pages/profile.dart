import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 57,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          // Handle profile picture change
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Software Developer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Profile Stats
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Applied', '23'),
                _buildStatItem('Reviewed', '18'),
                _buildStatItem('Contacted', '5'),
              ],
            ),
          ),

          const Divider(),

          // Profile Options
          _buildSection(
            'Account',
            [
              _buildListTile(
                Icons.person_outline,
                'Edit Profile',
                onTap: () => _navigateToEditProfile(context),
              ),
              _buildListTile(
                Icons.description_outlined,
                'My Resume',
                onTap: () => _navigateToResume(context),
              ),
              _buildListTile(
                Icons.work_history_outlined,
                'Application History',
                onTap: () => _navigateToApplicationHistory(context),
              ),
            ],
          ),

          _buildSection(
            'Settings',
            [
              _buildListTile(
                Icons.notifications_outlined,
                'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              _buildListTile(
                Icons.dark_mode_outlined,
                'Dark Mode',
                trailing: Switch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
              ),
              _buildListTile(
                Icons.language_outlined,
                'Language',
                subtitle: 'English',
                onTap: () => _showLanguageDialog(context),
              ),
            ],
          ),

          _buildSection(
            'About',
            [
              _buildListTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                onTap: () => _navigateToPrivacyPolicy(context),
              ),
              _buildListTile(
                Icons.article_outlined,
                'Terms of Service',
                onTap: () => _navigateToTerms(context),
              ),
              _buildListTile(
                Icons.help_outline,
                'Help & Support',
                onTap: () => _navigateToSupport(context),
              ),
              _buildListTile(
                Icons.info_outline,
                'About App',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildListTile(
      IconData icon,
      String title, {
        String? subtitle,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : null),
      onTap: onTap,
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile - Coming Soon')),
    );
  }

  void _navigateToResume(BuildContext context) {
    // Navigate to resume page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My Resume - Coming Soon')),
    );
  }

  void _navigateToApplicationHistory(BuildContext context) {
    // Navigate to application history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application History - Coming Soon')),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('French'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    // Navigate to privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy - Coming Soon')),
    );
  }

  void _navigateToTerms(BuildContext context) {
    // Navigate to terms
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service - Coming Soon')),
    );
  }

  void _navigateToSupport(BuildContext context) {
    // Navigate to support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support - Coming Soon')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Jobs App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.work),
      children: const [
        Text('A modern job search application built with Flutter.'),
      ],
    );
  }
}