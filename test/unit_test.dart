import 'package:flutter_test/flutter_test.dart';
import 'package:red_duck/features/queue/domain/entities/queue_status.dart';

void main() {
  test('QueueStatus props are correct', () {
    const status1 = QueueStatus(status: 'waiting', position: 1);
    const status2 = QueueStatus(status: 'waiting', position: 1);

    expect(status1, status2);
  });
}
