import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/queue_bloc.dart';

class QueueStatusPage extends StatelessWidget {
  const QueueStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<QueueBloc, QueueState>(
      listener: (context, state) {
        if (state is QueueLeft) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Queue Status'),
          automaticallyImplyLeading: false, // Don't show back button automatically
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Leave Queue',
              onPressed: () {
                 // We can rely on state here, but passing args is also fine if we had them.
                 // Since we are in QueueJoined state, the bloc will use the state values.
                 context.read<QueueBloc>().add(const LeaveQueue());
              },
            ),
          ],
        ),
        body: Center(
          child: BlocBuilder<QueueBloc, QueueState>(
            builder: (context, state) {
              if (state is QueueJoined) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Position',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${state.position}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(state.status),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<QueueBloc>().add(LeaveQueue(
                            businessId: state.businessId,
                            userId: state.userId
                          ));
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Leave Queue'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is QueueError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is QueueLoading) {
                 return const CircularProgressIndicator();
              }

               return const Center(child: Text('Waiting for status update...'));
            },
          ),
        ),
      ),
    );
  }
}
