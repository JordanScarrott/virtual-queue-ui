import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/dio_client.dart';
import '../bloc/queue_bloc.dart';
import 'queue_status_page.dart';

class JoinQueuePage extends StatefulWidget {
  const JoinQueuePage({super.key});

  @override
  State<JoinQueuePage> createState() => _JoinQueuePageState();
}

class _JoinQueuePageState extends State<JoinQueuePage> {
  final _businessIdController = TextEditingController();
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = const Uuid().v4();
  }

  @override
  void dispose() {
    _businessIdController.dispose();
    super.dispose();
  }

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

  void _showQueueInfoDialog(BuildContext context, Map<String, dynamic> info) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Queue Info'),
          content: SingleChildScrollView(
            child: Text(info.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Duck - Queue Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Network Settings',
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: BlocListener<QueueBloc, QueueState>(
        listener: (context, state) {
          if (state is QueueJoined) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QueueStatusPage()),
            );
          } else if (state is QueueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is QueueCreated) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Queue "${state.businessId}" created successfully!')),
            );
          } else if (state is QueueInfoLoaded) {
            _showQueueInfoDialog(context, state.queueInfo);
          } else if (state is QueueLeft) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Left queue successfully')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _businessIdController,
                decoration: const InputDecoration(
                  labelText: 'Business ID',
                  border: OutlineInputBorder(),
                  hintText: 'Enter Business ID',
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<QueueBloc, QueueState>(
                builder: (context, state) {
                  if (state is QueueLoading) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    children: [
                       SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final businessId = _businessIdController.text;
                            if (businessId.isNotEmpty) {
                              context.read<QueueBloc>().add(
                                    JoinQueue(
                                      businessId: businessId,
                                      userId: _userId,
                                    ),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('Join Queue'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final businessId = _businessIdController.text;
                                if (businessId.isNotEmpty) {
                                  context.read<QueueBloc>().add(
                                    CreateQueue(businessId),
                                  );
                                }
                              },
                               style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('Create Queue'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final businessId = _businessIdController.text;
                                if (businessId.isNotEmpty) {
                                  context.read<QueueBloc>().add(
                                    CheckQueue(businessId),
                                  );
                                }
                              },
                               style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('Check Status'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            final businessId = _businessIdController.text;
                            if (businessId.isNotEmpty) {
                              context.read<QueueBloc>().add(
                                    LeaveQueue(
                                      businessId: businessId,
                                      userId: _userId,
                                    ),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter Business ID')),
                              );
                            }
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Leave Queue (with current User ID)'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
