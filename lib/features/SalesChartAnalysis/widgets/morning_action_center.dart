import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/widgets/today_beat_card.dart';

import '../model/SalesChartDashboardModel.dart';
import 'handshake_request_card.dart';

class MorningActionCenter extends StatelessWidget {
  final TodayBeatAssigned? beat;
  final Future<void> Function()? onHandshakeSubmitted;

  const MorningActionCenter({
    super.key,
    this.beat,
    this.onHandshakeSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TodayBeatCard(
          beat: beat,
        ),
        const SizedBox(height: 18),
        HandshakeRequestCard(
          beat: beat,
          onSubmitted: onHandshakeSubmitted,
        ),
      ],
    );
  }
}
