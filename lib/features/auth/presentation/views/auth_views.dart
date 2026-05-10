import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';
import '../../../../core/network/token_refresher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _controller = Get.find<AuthController>();

  LogoutReason? _initialReason;
  bool _reasonShown = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = _controller.state.value;
    if (state is Unauthenticated) {
      _initialReason = state.reason;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _messageFor(LogoutReason? reason) {
    if (reason == null || _reasonShown) return null;
    switch (reason) {
      case LogoutReason.refreshExpired:
        return 'unauthorized_reason_expired'.tr;
      case LogoutReason.refreshRejected:
        return 'unauthorized_reason_rejected'.tr;
      case LogoutReason.securityRevoked:
        return 'unauthorized_reason_revoked'.tr;
      case LogoutReason.userInitiated:
        return 'logout_success'.tr;
    }
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _reasonShown = true);
    try {
      await _controller.login(_emailController.text, _passwordController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'login_failed'.tr}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login_button'.tr)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Obx(() {
            final message = _messageFor(_initialReason);

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'welcome_back'.tr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'gmail_label'.tr,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'gmail_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'password_label'.tr,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'password_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_controller.isProcessing.value)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _onLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'login_button'.tr,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('or_login_with'.tr),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialBtn(
                        onTap: () => _controller.loginWithGoogle(),
                        iconPath: 'assets/svg/google.svg',
                      ),
                      _buildSocialBtn(
                        onTap: () => _controller.loginWithFacebook(),
                        iconPath: 'assets/svg/facebook.svg',
                      ),
                      _buildSocialBtn(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('apple_login_not_implemented'.tr),
                            ),
                          );
                        },
                        iconPath: 'assets/svg/apple.svg',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSocialBtn({
    required VoidCallback onTap,
    required String iconPath,
  }) {
    return InkWell(
      onTap: _controller.isProcessing.value ? null : onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SvgPicture.asset(iconPath, height: 32, width: 32),
      ),
    );
  }
}
