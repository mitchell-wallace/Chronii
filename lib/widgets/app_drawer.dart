import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'base/base_empty_state.dart';

/// Main application drawer that shows user info and app options
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final userEmail = user != null 
        ? (user.isAnonymous ? "anonymous" : user.email ?? "No email")
        : "Not logged in";
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User info at the top
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 48.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Logged in as:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          userEmail,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Expanded section with app info
            Expanded(
              child: Center(
                child: BaseEmptyState(
                  icon: Icons.access_time,
                  message: 'Chronii alpha v0.1',
                  iconSize: 48.0,
                ),
              ),
            ),
            
            // Logout button at the bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authService.signOut();
                  Navigator.pop(context); // Close drawer after logout
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
