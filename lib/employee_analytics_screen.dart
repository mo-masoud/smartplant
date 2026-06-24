import 'package:flutter/material.dart';
import 'app_data.dart';
import 'widgets/pressable.dart';

class EmployeeAnalyticsScreen extends StatefulWidget {
  final Employee employee;
  const EmployeeAnalyticsScreen({super.key, required this.employee});

  @override
  State<EmployeeAnalyticsScreen> createState() => _EmployeeAnalyticsScreenState();
}

class _EmployeeAnalyticsScreenState extends State<EmployeeAnalyticsScreen> {
  bool isMonthSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Header with Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Pressable(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300.withAlpha(150),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Employee Profile Card
            _buildProfileCard(),

            const SizedBox(height: 24),

            // Performance Cards Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(child: _buildBarChartCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCircularChartCard()),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Week/Month Toggle
            _buildToggleButtons(),

            const SizedBox(height: 24),

            // Calendar Section
            _buildCalendarSection(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06402B), Color(0xFF0A5A3D)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.employee.username}'), 
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.employee.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.employee.role,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Attend',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  Text(
                    '${widget.employee.attendedDays} days / ${widget.employee.totalWorkDays} days',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 18, color: Colors.green.shade400),
              const SizedBox(width: 6),
              const Text('Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(40),
              _buildBar(60),
              _buildBar(90),
              _buildBar(100),
              _buildBar(70),
              _buildBar(50),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor) {
    return Container(
      width: 8,
      height: heightFactor * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFF06402B),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCircularChartCard() {
    double performance = (widget.employee.attendedDays / widget.employee.totalWorkDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.donut_large_rounded, size: 18, color: Colors.green.shade400),
              const SizedBox(width: 6),
              const Text('Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: performance,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFF5F7F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06402B)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(performance * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('Week', !isMonthSelected),
          ),
          Expanded(
            child: _buildToggleButton('Month', isMonthSelected),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Pressable(
      child: GestureDetector(
        onTap: () => setState(() => isMonthSelected = label == 'Month'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF06402B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Choose Date', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(width: 12),
              const Text('Mar, 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekdayText('Mon'), _WeekdayText('Tue'), _WeekdayText('Wed'), _WeekdayText('Thu'), _WeekdayText('Fri'), _WeekdayText('Sat'), _WeekdayText('Sun'),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final List<int?> days = [
      null, null, null, null, null, null, 1,
      2, 3, 4, 5, 6, 7, 8,
      9, 10, 11, 12, 13, 14, 15,
      16, 17, 18, 19, 20, 21, 22,
      23, 24, 25, 26, 27, 28, 29,
      30, 31,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: days.map((day) {
        if (day == null) return const SizedBox(width: 32, height: 32);
        
        bool isAttended = widget.employee.attendedDates.contains(day);
        bool isMissed = widget.employee.missedDates.contains(day);
        
        return Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAttended ? const Color(0xFF06402B) : (isMissed ? Colors.red.shade400 : Colors.transparent),
          ),
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: (isAttended || isMissed) ? Colors.white : Colors.black87,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekdayText extends StatelessWidget {
  final String text;
  const _WeekdayText(this.text);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
