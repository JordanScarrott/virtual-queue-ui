import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/dio_client.dart';
import '../bloc/queue_bloc.dart';
import 'join_queue_screen.dart';
import 'active_ticket_screen.dart';
import 'summoned_screen.dart';

class JoinQueuePage extends StatefulWidget {
  const JoinQueuePage({super.key});

  @override
  State<JoinQueuePage> createState() => _JoinQueuePageState();
}

class _JoinQueuePageState extends State<JoinQueuePage> {

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final networkClient = context.read<NetworkClient>();
        bool useLocalhost = networkClient.dio.options.baseUrl.contains('localhost');

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Network Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Use Localhost'),
                    subtitle: Text(useLocalhost ? 'localhost:8080' : 'Device IP'),
                    value: useLocalhost,
                    onChanged: (value) {
                      setState(() {
                        useLocalhost = value;
                      });
                      networkClient.toggleBaseUrl(useLocalhost: value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QueueBloc, QueueState>(
      listener: (context, state) {
        if (state is QueueError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is QueueCreated) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Queue "${state.businessId}" created successfully!')),
          );
        } else if (state is QueueLeft) {
          // Stay on Join screen, maybe show message
        }
      },
      child: BlocBuilder<QueueBloc, QueueState>(
        builder: (context, state) {
          if (state is QueueJoined) {
            // Determine if summoned
            // Assuming position 0 or status 'ready' means summoned.
            // The logic can be adjusted based on actual backend behavior.
            final isSummoned = state.position <= 0 || state.status.toLowerCase() == 'ready';

            if (isSummoned) {
              return SummonedScreen(userId: state.userId);
            } else {
              return ActiveTicketScreen(
                position: state.position,
                businessId: state.businessId,
                userId: state.userId,
              );
            }
          } else if (state is QueueLoading) {
             return const Scaffold(
               body: Center(child: CircularProgressIndicator()),
             );
          }

          // Default: Join Queue Screen
          return JoinQueueScreen(
            onSettingsPressed: () => _showSettingsDialog(context),
          );
        },
      ),
    );
  }
}
