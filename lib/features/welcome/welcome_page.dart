import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import '../auth/log_in_page.dart';
import '../auth/sign_up_page.dart';

class _FeatureData {
  final String title;
  final String body;
  const _FeatureData({required this.title, required this.body});
}

const List<_FeatureData> _features = [
  _FeatureData(
    title: 'Learn in Context',
    body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Vivamus lacinia odio vitae vestibulum donec.',
  ),
  _FeatureData(
    title: 'AI-Powered Practice',
    body: 'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
        'Ut enim ad minim veniam quis nostrud.',
  ),
  _FeatureData(
    title: 'Track Your Progress',
    body: 'Duis aute irure dolor in reprehenderit in voluptate velit esse '
        'cillum dolore eu fugiat nulla pariatur.',
  ),
];

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late VideoPlayerController _videoController;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showSignUp = false;

  @override
  void initState() {
    super.initState();
    // Place your video file at assets/videos/welcome_bg.mp4 before running.
    _videoController = VideoPlayerController.asset(
      'assets/videos/welcome_bg.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.setLooping(true);
          _videoController.setVolume(0);
          _videoController.play();
        }
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoBackground(),
          Container(color: Colors.black.withValues(alpha: 0.45)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _showSignUp
                      ? IconButton(
                          key: const ValueKey('back'),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => setState(() => _showSignUp = false),
                        )
                      : const SizedBox(key: ValueKey('no-back')),
                ),
                const Spacer(flex: 2),
                if (!_showSignUp) ...[
                  _buildCarousel(),
                  const SizedBox(height: 16),
                  _PageIndicator(
                    count: _features.length,
                    currentIndex: _currentPage,
                  ),
                ],
                const Spacer(),
                _buildButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (_videoController.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController.value.size.width,
          height: _videoController.value.size.height,
          child: VideoPlayer(_videoController),
        ),
      );
    }
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.context://login-callback/',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _features.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) => _FeatureCard(data: _features[index]),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showSignUp ? _buildSignUpButtons() : _buildWelcomeButtons(),
      ),
    );
  }

  Widget _buildWelcomeButtons() {
    return Column(
      key: const ValueKey('welcome-buttons'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _showSignUp = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogInPage()),
          ),
          child: const Text(
            'I already have an account',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButtons() {
    return Column(
      key: const ValueKey('signup-buttons'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GooglePlaceholder(),
              SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignUpPage()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline, size: 20),
              SizedBox(width: 12),
              Text(
                'Continue with Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(color: Colors.white54, fontSize: 12),
            children: [
              TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Terms of Service.',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder — swap this Container for the real Google logo asset when ready.
class _GooglePlaceholder extends StatelessWidget {
  const _GooglePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }
}
