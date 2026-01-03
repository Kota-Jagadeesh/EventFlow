import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/services.dart';

class DetailsScreen extends StatefulWidget {
  final String studentId;
  const DetailsScreen({super.key, required this.studentId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    //successs animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );

    //fde animation for  the content
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    //pulsee animation for thaa success icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> sendToBackend() async {
    //replace this with your actual gooogle apps script web app url
    const String scriptUrl =
        "https://script.google.com/macros/s/AKfycbwN9tiwr8BhYZJWCPOr0ZfMA7J3CIWWy_aUE4yD0bo61Sbad_vwK_4tfcFe_rgFv4J6NQ/exec";

    try {
      final response = await http
          .post(Uri.parse("$scriptUrl?studentId=${widget.studentId}"))
          .timeout(const Duration(seconds: 10));

      String result = response.body;
      bool isSuccess = result.contains("Success");
      bool isCheckIn = result.contains("Check-In");

      _successController.forward();

      //feedback based on success/failure
      if (isSuccess) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.vibrate();
      }

      return {
        'message': result,
        'isSuccess': isSuccess,
        'isCheckIn': isCheckIn,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      HapticFeedback.vibrate();
      return {
        'message': "Network error. Please check your connection and try again.",
        'isSuccess': false,
        'isCheckIn': false,
        'timestamp': DateTime.now(),
      };
    }
  }

  String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: sendToBackend(),
            builder: (context, snapshot) {
              //loadingg State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Processing...",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Verifying student ID",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              //result State
              final data = snapshot.data!;
              final isSuccess = data['isSuccess'] as bool;
              final isCheckIn = data['isCheckIn'] as bool;
              final message = data['message'] as String;
              final timestamp = data['timestamp'] as DateTime;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //animated success/error icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isSuccess ? _pulseAnimation.value : 1.0,
                              child: Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isSuccess
                                        ? [
                                            const Color(0xFF00D9FF),
                                            const Color(0xFF6C63FF),
                                          ]
                                        : [
                                            const Color(0xFFFF6B6B),
                                            const Color(0xFFEE5A6F),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isSuccess
                                                  ? const Color(0xFF6C63FF)
                                                  : const Color(0xFFFF6B6B))
                                              .withOpacity(0.6),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isSuccess
                                      ? (isCheckIn
                                            ? Icons.login_rounded
                                            : Icons.logout_rounded)
                                      : Icons.error_outline_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),

                      //animated status card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  //status bbadge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSuccess
                                            ? (isCheckIn
                                                  ? [
                                                      const Color(0xFF00D9FF),
                                                      const Color(0xFF6C63FF),
                                                    ]
                                                  : [
                                                      const Color(0xFFFF6B6B),
                                                      const Color(0xFFEE5A6F),
                                                    ])
                                            : [
                                                const Color(0xFF666666),
                                                const Color(0xFF444444),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (isSuccess
                                                      ? (isCheckIn
                                                            ? const Color(
                                                                0xFF00D9FF,
                                                              )
                                                            : const Color(
                                                                0xFFFF6B6B,
                                                              ))
                                                      : Colors.grey)
                                                  .withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      isSuccess
                                          ? (isCheckIn
                                                ? "✓ CHECK-IN"
                                                : "✓ CHECK-OUT")
                                          : "✗ FAILED",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  //messge
                                  Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  //animated divider
                                  Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),

                                  //detils section
                                  _buildDetailRow(
                                    icon: Icons.badge_outlined,
                                    label: "Student ID",
                                    value: widget.studentId,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildDetailRow(
                                    icon: Icons.access_time_rounded,
                                    label: "Time",
                                    value: _formatTime(timestamp),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildDetailRow(
                                    icon: Icons.calendar_today_rounded,
                                    label: "Date",
                                    value: _formatDate(timestamp),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildDetailRow(
                                    icon: isSuccess
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    label: "Status",
                                    value: isSuccess ? "Success" : "Failed",
                                    valueColor: isSuccess
                                        ? const Color(0xFF00D9FF)
                                        : const Color(0xFFFF6B6B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      //continue buttonon with gradient
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6C63FF,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "SCAN NEXT",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
