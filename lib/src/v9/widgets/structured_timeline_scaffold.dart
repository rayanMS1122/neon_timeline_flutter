import 'package:flutter/material.dart';

class StructuredTimelineScaffold extends StatelessWidget {
  const StructuredTimelineScaffold({
    required this.body,
    this.appBar,
    this.header,
    this.weekStrip,
    this.metrics,
    this.floatingAction,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.endFloat,
    this.safeArea = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget? header;
  final Widget? weekStrip;
  final Widget? metrics;
  final Widget body;
  final Widget? floatingAction;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: <Widget>[
        if (header != null) header!,
        if (weekStrip != null) weekStrip!,
        if (metrics != null) metrics!,
        Expanded(child: body),
      ],
    );
    if (safeArea) content = SafeArea(top: false, child: content);
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: content,
      floatingActionButton: floatingAction,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
