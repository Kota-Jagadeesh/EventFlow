import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'details_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  bool isScanning = true;
  bool flashOn = false;
  late MobileScannerController cameraController;
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();

    //scan line animation
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    //animation forthe corners
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() => flashOn = !flashOn);
    cameraController.toggleTorch();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Scan Attendance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          //flash tooggle button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: flashOn
                  ? Colors.yellow.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                flashOn ? Icons.flash_on : Icons.flash_off,
                color: flashOn ? Colors.yellow : Colors.white,
                size: 26,
              ),
              onPressed: _toggleFlash,
              tooltip: flashOn ? 'Turn off flash' : 'Turn on flash',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          //camera view
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (isScanning) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  setState(() => isScanning = false);
                  HapticFeedback.mediumImpact();
                  final String code = barcodes.first.rawValue ?? "Unknown";

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(studentId: code),
                    ),
                  ).then((_) {
                    setState(() => isScanning = true);
                  });
                }
              }
            },
          ),

          //dark overlay with transparent center
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //scanning frame with animations
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF6C63FF), width: 3),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  //top-left corner with pulse
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 0,
                        left: 0,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                                left: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  //top-right corner with pulse
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                                right: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  //bottom-left corner with pulse
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                                left: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  //bottomm-right corner with pulse
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Positioned(
                        bottom: 0,
                        right: 0,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                                right: BorderSide(
                                  color: Color(0xFF00D9FF),
                                  width: 5,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  //animateds scan line
                  AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, child) {
                      return Positioned(
                        top: 10 + (_scanLineController.value * 270),
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF00D9FF),
                                Color(0xFF00D9FF),
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.3, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D9FF).withOpacity(0.8),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  //centre QR icon
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.3,
                          child: Icon(
                            Icons.qr_code_2,
                            size: 100 * _pulseAnimation.value,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          //instructions at bottom
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D9FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Color(0xFF00D9FF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Ready to Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Position QR code within the frame",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00D9FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Keep steady for best results",
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //scan count indicator
          Positioned(
            top: 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00D9FF).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isScanning ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: isScanning
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isScanning ? "ACTIVE" : "PAUSED",
                    style: TextStyle(
                      color: isScanning ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
