import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import '../admin/CustomerManagementScreen.dart';
import '../screens/GoldSchemeScreen.dart';
import '../screens/HomeScreen.dart';
import '../screens/MySubscriptionScreen.dart';
import '../screens/SettingScreen.dart';
import '../screens/auth/LoginScreen.dart';
import '../screens/auth/ProfileScreen.dart';
import '../screens/auth/RegisterScreen.dart';

class CustomDrawer extends StatelessWidget {
  final BuildContext parentContext;

  CustomDrawer({required this.parentContext});

  final supabase = Supabase.instance.client;
  final storage = FlutterSecureStorage();

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await storage.delete(key: 'session');
    Navigator.pushReplacement(
      parentContext,
      MaterialPageRoute(builder: (context) => HomeScreen(title: 'Home')),
    );
  }

  Future<String?> getUserRole() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await supabase
        .from('user_roles')
        .select('roles(id, name)')
        .eq('user_id', userId)
        .maybeSingle();

    return response != null ? response['roles']['name'] as String? : null;
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Drawer(
      child: FutureBuilder<String?>(
        future: getUserRole(),
        builder: (context, snapshot) {
          final role = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.userMetadata?['name'] ?? "Guest"),
                accountEmail: Text(user?.email ?? "No Email"),
                currentAccountPicture: CircleAvatar(child: Icon(Icons.person, size: 40)),
              ),

              // Common for all logged-in users
              if (user != null) ...[
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(parentContext, MaterialPageRoute(builder: (context) => HomeScreen(title: 'Home')));
                  },
                ),
              ],

              // Role-based rendering
              if (role == 'admin') ...[
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Customers Management'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        parentContext,
                        MaterialPageRoute(builder: (context) => CustomerManagementScreen(title: 'Customers Management'))
                    );
                  },
                ),

              ] else if (role == 'customer') ...[
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.monetization_on_outlined),
                  title: Text('Gold Scheme'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => GoldSchemeScreen(title: 'Gold Scheme'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.monetization_on_outlined),
                  title: Text('My Subscriptions'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => MySubscriptionScreen(title: 'My Subscriptions'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(title: 'Profile'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => SettingScreen(title: 'Settings'),
                      ),
                    );
                  },
                ),
              ],

              // Logout option for authenticated users
              if (user != null) ...[
                Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: signOut,
                ),
              ] else ...[
                // Guest users: Login & Register
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login'),
                  onTap: () {
                    Navigator.pushReplacement(
                      parentContext,
                      MaterialPageRoute(builder: (context) => LoginScreen(title: 'Login')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.app_registration),
                  title: Text('Register'),
                  onTap: () {
                    Navigator.pushReplacement(
                      parentContext,
                      MaterialPageRoute(builder: (context) => RegisterScreen(title: 'Register')),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}