import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final success = await ref.read(authStateProvider.notifier).signInWithGoogle();
    if (!success && mounted) {
      final authState = ref.read(authStateProvider);
      if (authState.error != null) {
        _showErrorSnackBar(authState.error!);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        _showErrorSnackBar(next.error!);
        Future.delayed(const Duration(milliseconds: 100), () {
          ref.read(authStateProvider.notifier).clearError();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/CLD.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cloud_queue, size: 80, color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary, letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Masuk dengan akun Google untuk\nmengakses penyimpanan cloud Anda.',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                const Expanded(child: Divider(color: AppColors.border)),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.cloud_outlined, color: AppColors.primary, size: 20),
                                ),
                                const Expanded(child: Divider(color: AppColors.border)),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: authState.isLoading ? null : _signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: AppColors.border, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        height: 20, width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 24, height: 24,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                                            child: const Center(
                                              child: Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4285F4))),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Masuk dengan Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Dengan masuk, Anda menyetujui\nSyarat & Ketentuan dan Kebijakan Privasi.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}