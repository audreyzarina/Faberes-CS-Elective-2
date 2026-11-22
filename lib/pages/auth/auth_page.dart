import 'package:material_ui/material_ui.dart';

import 'login_page.dart';
import 'signup_page.dart';

/// Switches between the login and sign-up pages without pushing routes.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _showLogin
          ? LoginPage(
              key: const ValueKey('login'),
              onSwitch: () => setState(() => _showLogin = false),
            )
          : SignUpPage(
              key: const ValueKey('signup'),
              onSwitch: () => setState(() => _showLogin = true),
            ),
    );
  }
}
