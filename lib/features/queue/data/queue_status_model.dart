class QueueStatus {
  final String businessId;
  final int queueLength;
  final int estimatedWaitMinutes;
  final int userPosition;
  final int userEstimatedWaitMinutes;
  final Media media;

  QueueStatus({
    required this.businessId,
    required this.queueLength,
    required this.estimatedWaitMinutes,
    this.userPosition = 0, // Backend does not yet support this
    this.userEstimatedWaitMinutes = 0, // Backend does not yet support this
    required this.media,
  });

  factory QueueStatus.fromJson(Map<String, dynamic> json) {
    return QueueStatus(
      businessId: json['business_id'] ?? '',
      queueLength: json['queue_length'] ?? 0,
      estimatedWaitMinutes: json['estimated_wait_minutes'] ?? 0,
      userPosition: json['user_position'] ?? 0,
      userEstimatedWaitMinutes: json['user_estimated_wait_minutes'] ?? 0,
      media: Media.fromJson(json['media'] ?? {}),
    );
  }
}

class Media {
  final String logoUrl;
  final String headerUrl;

  Media({required this.logoUrl, required this.headerUrl});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      logoUrl: json['logo_url'] ?? '',
      headerUrl: json['header_url'] ?? '',
    );
  }
}
