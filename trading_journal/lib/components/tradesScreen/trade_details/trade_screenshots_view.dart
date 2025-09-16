import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trading_journal/models/trade.dart';

class TradeScreenshotsView extends StatefulWidget {
  final Trade trade;
  const TradeScreenshotsView({required this.trade, super.key});

  @override
  State<TradeScreenshotsView> createState() => _TradeScreenshotsViewState();
}

class _TradeScreenshotsViewState extends State<TradeScreenshotsView> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trade.screenshots.isEmpty) {
      return _buildEmptyState(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  tooltip: 'Previous',
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      : null,
                ),
                Expanded(
                  flex: 3, // 3 out of 4 parts, ~75%
                  child: SizedBox(
                    height:
                        constraints.maxHeight *
                        0.9, // Use 80% of available height
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.trade.screenshots.length,
                      itemBuilder: (context, index) {
                        final screenshotData = widget.trade.screenshots[index];
                        final filePath = screenshotData['path']!;
                        final timeframe = screenshotData['timeframe']!;
                        return _buildScreenshotCard(
                          filePath,
                          timeframe,
                          context,
                          constraints.maxHeight *
                              0.9, // Pass the height to the card
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  tooltip: 'Next',
                  onPressed: _currentPage < widget.trade.screenshots.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      : null,
                ),
              ],
            ),
            if (widget.trade.screenshots.length > 1)
              _buildPageIndicator(widget.trade.screenshots.length),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No screenshots attached to this trade.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add visual context to your trade for better review.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotCard(
    String filePath,
    String timeframe,
    BuildContext context,
    double height, // Added height parameter
  ) {
    final file = File(filePath);
    final theme = Theme.of(context);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.data!) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: height, // Use the provided height
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 8),
                    Text('Image not found', style: theme.textTheme.bodySmall),
                    Text('($timeframe)', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          );
        }
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            height: height, // Use the provided height
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  file,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading image',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Chip(
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
                    label: Text(
                      timeframe,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        );
      }),
    );
  }
}
