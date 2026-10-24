enum ReportReason { spam, abuse, harassment, nudity, other }

extension ReportReasonX on ReportReason {
  String get label => switch (this) {
        ReportReason.spam => 'Spam',
        ReportReason.abuse => 'Gaali / abuse',
        ReportReason.harassment => 'Harassment',
        ReportReason.nudity => 'Inappropriate content',
        ReportReason.other => 'Kuch aur',
      };
}
