import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/queue/data/queue_repository.dart';
import 'features/queue/providers/queue_provider.dart';
import 'features/queue/presentation/pages/join_queue_screen.dart';
import 'features/queue/presentation/pages/active_ticket_screen.dart';

void main() {
  runApp(const RedDuckApp());
}

class RedDuckApp extends StatelessWidget {
  const RedDuckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QueueProvider(QueueRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Red Duck',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEC5413)),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<QueueProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.status == null && !provider.inQueue) {
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (provider.inQueue) {
           // Even if status is null (e.g. backend offline), show ticket screen with basic info if possible
           // or show loading/error. For now, assume we can show ticket.
           // Fallback for missing status fields handles the nulls.
          return ActiveTicketScreen(
            position: provider.status?.userPosition ?? 0,
            businessId: provider.businessId!,
            userId: provider.guestId!,
          );
        }
        
        return JoinQueueScreen(
          onSettingsPressed: () {
            // TODO: Settings
          },
        );
      },
    );
  }
}
