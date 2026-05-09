import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'main_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  
  void _handleExport(String format) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF06402B))),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report successfully exported as $format'),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListenableBuilder(
        listenable: AppData(),
        builder: (context, _) {
          final appData = AppData();
          
          return Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid (2x2)
                      _buildStatsGrid(appData, isDark),
                      const SizedBox(height: 32),

                      // Charts Row
                      _buildChartsRow(appData, isDark),
                      const SizedBox(height: 32),

                      // Top Classified Plants
                      _buildSectionTitle(context, 'Top Classified Plants', 'Most frequent detections'),
                      const SizedBox(height: 16),
                      _buildTopPlantsList(appData, isDark),
                      
                      const SizedBox(height: 32),

                      // Distribution & Export
                      _buildSectionTitle(context, 'Plant Distribution', 'Diversity overview'),
                      const SizedBox(height: 16),
                      _buildPlantDistribution(appData, isDark),

                      const SizedBox(height: 32),
                      _buildSectionTitle(context, 'Export Reports', 'Download actual data'),
                      const SizedBox(height: 16),
                      _buildExportSection(context, isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                MainScreen.of(context)?.setIndex(0);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withAlpha(30), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Reports', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Live Analytics & insights', style: TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppData appData, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Total Classifications', 
          '${appData.records.length}', 
          '+${appData.totalScansThisMonth} this month', 
          Icons.trending_up_rounded,
          isDark,
        ),
        _buildStatCard(
          'Avg. Confidence', 
          '${appData.averageAccuracy.toStringAsFixed(1)}%', 
          'High accuracy', 
          Icons.trending_up_rounded,
          isDark,
        ),
        _buildStatCard(
          'Active Users', 
          '${appData.employees.length + 1}', // +1 for Admin
          'Employees live', 
          null,
          isDark,
        ),
        _buildStatCard(
          'Processing Time', 
          '${appData.avgProcessingTime.toStringAsFixed(1)}s', 
          'Optimized performance', 
          Icons.trending_up_rounded,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String trend, IconData? trendIcon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (trendIcon != null) ...[
                Icon(trendIcon, size: 10, color: Colors.green),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  trend, 
                  style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(AppData appData, bool isDark) {
    return Column(
      children: [
        // Daily Classifications (Line style)
        _buildChartCard(
          'Daily Classifications', 
          'Last 7 Days', 
          _buildLineChart(appData.dailyClassificationsLast7Days, isDark),
          isDark
        ),
        const SizedBox(height: 24),
        // Weekly Performance (Grouped bar)
        _buildChartCard(
          'Weekly Performance', 
          'Monthly metrics', 
          _buildGroupedBarChart(appData.weeklyPerformanceData, isDark),
          isDark
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 5), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<int> data, bool isDark) {
    int maxVal = data.isEmpty ? 10 : data.reduce((a, b) => a > b ? a : b);
    if (maxVal < 5) maxVal = 10;
    
    return CustomPaint(
      size: Size.infinite,
      painter: LineChartPainter(data: data, maxVal: maxVal, isDark: isDark),
    );
  }

  Widget _buildGroupedBarChart(List<Map<String, dynamic>> data, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        double countHeight = (data[i]['count'] / 50) * 150; // Max count ~50
        double accHeight = (data[i]['accuracy'] * 150); 
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: countHeight.clamp(5, 150),
                  decoration: BoxDecoration(color: const Color(0xFF06402B), borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: accHeight.clamp(5, 150),
                  decoration: BoxDecoration(color: const Color(0xFF81C784), borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('W${i+1}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        );
      }),
    );
  }

  Widget _buildTopPlantsList(AppData appData, bool isDark) {
    final topPlants = appData.topPlantsData;
    if (topPlants.isEmpty) return const Center(child: Text('Not enough data'));

    return Column(
      children: List.generate(topPlants.length, (i) {
        final plant = topPlants[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFB9D4C7).withAlpha(isDark ? 30 : 60),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFF06402B), shape: BoxShape.circle),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  plant['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text('${plant['count']} classifications', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(width: 10),
              Text(plant['trend'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPlantDistribution(AppData appData, bool isDark) {
    final distribution = appData.plantDistributionData;
    if (distribution.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(28)),
      child: Center(
        child: CustomPaint(
          size: const Size(150, 150),
          painter: PieChartPainter(data: distribution),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildExportSection(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildExportButton('PDF', Icons.picture_as_pdf_outlined, isDark, () => _handleExport('PDF'))),
        const SizedBox(width: 12),
        Expanded(child: _buildExportButton('CSV', Icons.table_chart_outlined, isDark, () => _handleExport('CSV'))),
        const SizedBox(width: 12),
        Expanded(child: _buildExportButton('Excel', Icons.grid_on_outlined, isDark, () => _handleExport('Excel'))),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon, bool isDark, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<int> data;
  final int maxVal;
  final bool isDark;

  LineChartPainter({required this.data, required this.maxVal, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = const Color(0xFF06402B)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF06402B)
      ..style = PaintingStyle.fill;

    final double stepX = size.width / (data.length - 1);
    final Path path = Path();

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height - (data[i] / maxVal * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    double startAngle = -math.pi / 2;
    final List<Color> colors = [const Color(0xFF06402B), const Color(0xFF388E3C), const Color(0xFF81C784), const Color(0xFFA5D6A7)];

    int i = 0;
    data.forEach((key, value) {
      final sweepAngle = value * 2 * math.pi;
      final paint = Paint()..color = colors[i % colors.length]..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      
      // Label text
      final double labelAngle = startAngle + sweepAngle / 2;
      final labelOffset = Offset(
        center.dx + (radius + 20) * math.cos(labelAngle),
        center.dy + (radius + 20) * math.sin(labelAngle),
      );
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$key ${(value * 100).toInt()}%',
          style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(canvas, labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));
      
      startAngle += sweepAngle;
      i++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
