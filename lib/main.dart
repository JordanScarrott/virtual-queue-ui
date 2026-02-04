import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_client.dart';
import 'features/queue/data/repositories/queue_repository_impl.dart';
import 'features/queue/domain/repositories/queue_repository.dart';
import 'features/queue/presentation/bloc/queue_bloc.dart';
import 'features/queue/presentation/pages/join_queue_page.dart';
import 'services/realtime_client.dart';

void main() {
  runApp(const RedDuckApp());
}

class RedDuckApp extends StatefulWidget {
  const RedDuckApp({super.key});

  @override
  State<RedDuckApp> createState() => _RedDuckAppState();
}

class _RedDuckAppState extends State<RedDuckApp> {
  final NetworkClient _networkClient = NetworkClient(useLocalhost: true);
  final RealtimeClient _realtimeClient = RealtimeClient();

  @override
  void initState() {
    super.initState();
    _realtimeClient.connect();
  }

  @override
  void dispose() {
    _realtimeClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NetworkClient>.value(value: _networkClient),
        RepositoryProvider<RealtimeClient>.value(value: _realtimeClient),
        RepositoryProvider<QueueRepository>(
          create: (context) => QueueRepositoryImpl(
            networkClient: context.read<NetworkClient>(),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => QueueBloc(
          repository: context.read<QueueRepository>(),
          realtimeClient: context.read<RealtimeClient>(),
        ),
        child: MaterialApp(
          title: 'Red Duck',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
            useMaterial3: true,
          ),
          home: const JoinQueuePage(),
        ),
      ),
    );
  }
}
