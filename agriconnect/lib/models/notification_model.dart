class NotificationModel {
  final String message;
  final DateTime date;
  final String forUser;

  NotificationModel({
    required this.message,
    required this.date,
    required this.forUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'date': date.toIso8601String(),
      'forUser': forUser,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'],
      date: DateTime.parse(json['date']),
      forUser: json['forUser'],
    );
  }
}