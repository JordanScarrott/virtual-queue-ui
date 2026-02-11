import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/queue_provider.dart';

class ActiveTicketScreen extends StatefulWidget {
  final int position;
  final String businessId;
  final String userId;

  const ActiveTicketScreen({
    super.key,
    required this.position,
    required this.businessId,
    required this.userId,
  });

  @override
  State<ActiveTicketScreen> createState() => _ActiveTicketScreenState();
}

class _ActiveTicketScreenState extends State<ActiveTicketScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consume provider for real-time updates
    final provider = context.watch<QueueProvider>();
    final position = provider.status?.userPosition ?? widget.position;
    final waitTime = provider.status?.userEstimatedWaitMinutes ?? (position * 5); // Fallback: 5 min per person

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code_scanner, size: 28, color: Color(0xFF1B120D)),
                      SizedBox(width: 8),
                      Text(
                        'SNAPSCAN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Color(0xFF1B120D),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF1B120D)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Ticket Content
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing Rings
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final double initialDelay = index * 0.5;
                      double value = (_pulseController.value + initialDelay) % 1.0;
                      double scale = 1.0 + (value * 0.5); // Scale from 1.0 to 1.5
                      double opacity = (1.0 - value) * 0.5; // Fade out

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFEC5413).withValues(alpha: opacity),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      position > 0 ? position.toString().padLeft(2, '0') : '--', // Fallback when position is unknown
                      style: const TextStyle(
                        fontSize: 140,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFEC5413),
                        height: 1.0,
                        letterSpacing: -5.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC5413).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEC5413).withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Color(0xFFEC5413)),
                          SizedBox(width: 8),
                          Text(
                            'YOUR TURN SOON',
                            style: TextStyle(
                              color: Color(0xFFEC5413),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Estimated Wait',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF8A817C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$waitTime min',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B120D),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Additional Details Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.storefront,
                      label: 'Location',
                      value: 'Main Branch',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.group,
                      label: 'Ahead',
                      value: '${position > 0 ? position - 1 : 0} People',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Slider to Leave
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Slide to leave queue',
                            style: TextStyle(
                              color: Color(0xFF8A817C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.logout, size: 16, color: Color(0xFF8A817C)),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 64,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 28),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: const Color(0xFFEC5413),
                        overlayColor: Colors.transparent,
                      ),
                      child: Slider(
                        value: _sliderValue,
                        onChanged: (value) {
                          setState(() {
                            _sliderValue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          if (value > 0.9) {
                            // Trigger leave
                            context.read<QueueProvider>().leaveQueue();
                            // Provider state change will trigger AuthWrapper rebuild and navigation
                          } else {
                            // Reset
                            setState(() {
                              _sliderValue = 0.0;
                            });
                          }
                        },
                      ),
                    ),
                    // Custom Thumb Icon Overlay (since Slider doesn't support icon easily without custom shape)
                    IgnorePointer(
                      child: Padding(
                         padding: EdgeInsets.only(left: (_sliderValue * (MediaQuery.of(context).size.width - 48 - 64)).clamp(0, double.infinity) + 4),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent, // Handled by slider thumb
                          ),
                          child: const Center(
                            child: Icon(Icons.chevron_right, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 16),
             Center(
              child: Text(
                'Ticket ID: #${widget.userId.substring(0, 4).toUpperCase()}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFEC5413)),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A817C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B120D),
            ),
          ),
        ],
      ),
    );
  }
}
