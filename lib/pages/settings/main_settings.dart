import 'package:flutter/material.dart';
import '../../utils/file_handler.dart';

class MainSettings extends StatefulWidget {
  const MainSettings({Key? key}) : super(key: key);

  @override
  State<MainSettings> createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  Future<void> _exportEntries() async {
    final zipFile = await exportAllEntriesToZip();
    if (!mounted) return;
    if (zipFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${zipFile.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entries to export')),
      );
    }
  }

  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Account Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: const Text('Import'),
          subtitle: const Text('Import your Journal entries'),
          leading: const Icon(Icons.cloud_download),
          onTap: () {
            // Handle profile settings tap
          },
        ),
        ListTile(
          title: const Text('Export'),
          subtitle: const Text('Export your Journal entries'),
          leading: const Icon(Icons.cloud_upload),
          onTap: () {
            _exportEntries();
          },
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          subtitle: const Text('Edit your profile information'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            
          },
        ),
        const Divider(),

        // Preferences Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Dark Mode'),
          trailing: Switch(
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Location Services'),
          trailing: Switch(
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
        ),
        const Divider(),

        // Security Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Handle change password tap
          },
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: const Text('Enable Fingerprint'),
          trailing: Switch(
            value: false,
            onChanged: (value) {
              // Handle fingerprint toggle
            },
          ),
        ),
        const Divider(),

        // Other Section
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Other',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Handle about tap
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Handle log out tap
          },
        ),
      ],
    );
  
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Settings'),
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.download),
    //         onPressed: _exportEntries,
    //       ),
    //     ],
    //   ),
    //   backgroundColor: Theme.of(context).colorScheme.tertiary,
    //   body: const Center(
    //     child: Text('This is the Settings screen'),
    //   ),
    // );
  }
}