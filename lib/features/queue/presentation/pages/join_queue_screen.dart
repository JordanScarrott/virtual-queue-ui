import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/queue_provider.dart';

class JoinQueueScreen extends StatefulWidget {
  final VoidCallback onSettingsPressed;

  const JoinQueueScreen({super.key, required this.onSettingsPressed});

  @override
  State<JoinQueueScreen> createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends State<JoinQueueScreen> {
  final _businessIdController = TextEditingController();

  @override
  void dispose() {
    _businessIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image Section (Top 40%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              color: Colors.grey[200], // Placeholder color
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAhGZ7vaf72kVG7ac-Y8r9ty5HyBvnBMbfYqyY2pRyLOfZybny6XlDGXc83w0G5_klALfXshu37mGb3lR-qst_uC1g7Twv3_c1x0gjJVd4JtS1CcBAsTInb_nTBlevSf2zZIOSXtqH3VZmUz1qCsc4pWe-hIzls6ETwKdsh4UAjItQurnpDEnnZZ-qZBDgFF3b8OsTCESrdygwg-Cel4V92JhyWy1esvTLNIaQGaMdQdDF372eei0H8336lm8wE9MHQZOFkFoWkgA0',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.restaurant, size: 64, color: Colors.grey));
                    },
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                      onPressed: widget.onSettingsPressed,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Card (Bottom 65% overlap)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'The Burger Joint',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1.2km • American Diner',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
  
                      // Wait Time Display - Static for now or fetch global
                      const Text(
                        'CURRENT WAIT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Consumer<QueueProvider>(
                            builder: (context, provider, _) {
                              // If we have stats, use them, else placeholder
                              return Text(
                                provider.status != null ? '${provider.status!.estimatedWaitMinutes}' : '12',
                                style: const TextStyle(
                                  fontSize: 96,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                  height: 0.9,
                                ),
                              );
                            }
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'min',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
  
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange[100]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 18, color: Colors.orange[800]),
                            const SizedBox(width: 8),
                            Text(
                              'Queue closes at 5:00 PM',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
  
                      const SizedBox(height: 32), // Spacer replaced with fixed size to allow scrolling
  
                      // Business ID Input (Added for functionality)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _businessIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter Business ID (Optional)',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
  
                      // Join Queue Button
                      Consumer<QueueProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          return SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                final businessId = _businessIdController.text.isNotEmpty
                                    ? _businessIdController.text
                                    : 'barbershop-1'; // Default updated to match known ID
  
                                context.read<QueueProvider>().joinQueue(businessId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEC5413), // Primary Orange
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFFEC5413).withValues(alpha: 0.4),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'JOIN QUEUE',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      if (context.watch<QueueProvider>().error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            context.watch<QueueProvider>().error!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                      const SizedBox(height: 16),
                      const Text(
                        'By joining, you agree to our Terms of Service',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
