import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Employee {
  final String id;
  final String name;
  final String email;
  final String role;
  final String username;
  final int totalWorkDays;
  final int attendedDays;
  final List<int> attendedDates;
  final List<int> missedDates;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.username = '',
    this.totalWorkDays = 45,
    this.attendedDays = 40,
    this.attendedDates = const [1, 2, 3, 4, 6, 7, 10, 14, 15, 21, 22, 28, 29],
    this.missedDates = const [8, 11, 19],
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email, 'role': role, 'username': username,
    'totalWorkDays': totalWorkDays, 'attendedDays': attendedDays,
    'attendedDates': attendedDates, 'missedDates': missedDates,
  };

  factory Employee.fromMap(Map<String, dynamic> map) => Employee(
    id: map['id'], 
    name: map['name'], 
    email: map['email'], 
    role: map['role'],
    username: map['username'] ?? '',
    totalWorkDays: map['totalWorkDays'] ?? 45,
    attendedDays: map['attendedDays'] ?? 40,
    attendedDates: List<int>.from(map['attendedDates'] ?? []),
    missedDates: List<int>.from(map['missedDates'] ?? []),
  );
}

class Plant {
  final String id;
  final String name;
  final String code;
  final String category;
  final DateTime updatedAt;

  Plant({
    required this.id, 
    required this.name, 
    required this.code, 
    required this.category, 
    required this.updatedAt
  });

  Map<String, dynamic> toMap() => {
    'id': id, 
    'name': name, 
    'code': code, 
    'category': category, 
    'updatedAt': updatedAt.toIso8601String()
  };

  factory Plant.fromMap(Map<String, dynamic> map) => Plant(
    id: map['id'], 
    name: map['name'], 
    code: map['code'], 
    category: map['category'], 
    updatedAt: DateTime.parse(map['updatedAt'])
  );
}

class Dataset {
  final String fileName;
  final DateTime uploadDate;
  final int samples;

  Dataset({required this.fileName, required this.uploadDate, required this.samples});

  Map<String, dynamic> toMap() => {
    'fileName': fileName, 
    'uploadDate': uploadDate.toIso8601String(), 
    'samples': samples
  };

  factory Dataset.fromMap(Map<String, dynamic> map) => Dataset(
    fileName: map['fileName'], 
    uploadDate: DateTime.parse(map['uploadDate']), 
    samples: map['samples']
  );
}

class ClassificationRecord {
  final String name;
  final double accuracyValue;
  final DateTime timestamp;
  final String imageUrl;
  final double processingTime;
  final String userId;

  ClassificationRecord({
    required this.name,
    required this.accuracyValue,
    required this.timestamp,
    required this.imageUrl,
    required this.userId,
    this.processingTime = 1.2,
  });

  String get accuracy => '${(accuracyValue * 100).toStringAsFixed(1)}%';
  String get date => DateFormat('yyyy-MM-dd • hh:mm a').format(timestamp);

  Map<String, dynamic> toMap() => {
    'name': name,
    'accuracyValue': accuracyValue,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
    'processingTime': processingTime,
    'userId': userId,
  };

  factory ClassificationRecord.fromMap(Map<String, dynamic> map) => ClassificationRecord(
    name: map['name'],
    accuracyValue: (map['accuracyValue'] as num).toDouble(),
    timestamp: DateTime.parse(map['timestamp']),
    imageUrl: map['imageUrl'],
    processingTime: (map['processingTime'] as num? ?? 1.2).toDouble(),
    userId: map['userId'] as String,
  );
}

class Activity {
  final String text;
  final DateTime timestamp;

  Activity({required this.text, required this.timestamp});

  Map<String, dynamic> toMap() => {'text': text, 'time': timestamp.toIso8601String()};
  factory Activity.fromMap(Map<String, dynamic> map) => Activity(
    text: map['text'], 
    timestamp: DateTime.parse(map['time']),
  );
}

class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal() {
    loadData();
  }

  String currentUser = "Mahmoud Massoud";
  String currentUserRole = "Admin";

  bool _isDarkMode = false;
  String _language = 'English';
  bool _classificationAlerts = true;
  bool _reportNotifications = true;
  bool _systemUpdates = false;

  List<Employee> _employees = [
    Employee(id: 'E001', name: 'Ahmed Ali', email: 'ahmed.ali@company.com', role: 'Plant Analyst', username: 'ahmed'),
    Employee(id: 'E002', name: 'Sarah Ali', email: 'sarah.ali@company.com', role: 'Supervisor', username: 'sarah'),
  ];

  List<Plant> _plants = [
    Plant(id: 'P001', name: 'Monstera Deliciosa', code: 'MD-01', category: 'Tropical', updatedAt: DateTime.now()),
  ];

  List<Dataset> _datasets = [];

  List<ClassificationRecord> _records = [];
  List<Activity> _activities = [
    Activity(text: 'System Initialized', timestamp: DateTime.now())
  ];
  Map<String, String> _profileImages = {};

  List<Employee> get employees => _employees;
  List<Plant> get plants => _plants;
  List<Dataset> get datasets => _datasets;
  List<ClassificationRecord> get records => _records;
  List<ClassificationRecord> get userRecords =>
      _records.where((r) => r.userId == currentUser).toList();
  List<Activity> get activities => _activities;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get classificationAlerts => _classificationAlerts;
  bool get reportNotifications => _reportNotifications;
  bool get systemUpdates => _systemUpdates;

  // --- Calculations ---
  int get totalScansThisMonth {
    final now = DateTime.now();
    return _records.where((r) => r.timestamp.month == now.month && r.timestamp.year == now.year).length;
  }

  double get averageAccuracy {
    if (_records.isEmpty) return 0.0;
    double sum = _records.fold(0, (prev, element) => prev + element.accuracyValue);
    return (sum / _records.length) * 100;
  }

  double get avgProcessingTime {
    if (_records.isEmpty) return 0.0;
    double sum = _records.fold(0, (prev, element) => prev + element.processingTime);
    return sum / _records.length;
  }

  double get errorRate {
    if (_records.isEmpty) return 0.0;
    int errors = _records.where((r) => r.accuracyValue < 0.85).length;
    return (errors / _records.length) * 100;
  }

  List<int> get dailyClassificationsLast7Days {
    final now = DateTime.now();
    List<int> counts = List.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      counts[i] = _records.where((r) => 
        r.timestamp.day == day.day && 
        r.timestamp.month == day.month && 
        r.timestamp.year == day.year
      ).length;
    }
    return counts;
  }

  List<Map<String, dynamic>> get weeklyPerformanceData {
    final now = DateTime.now();
    List<Map<String, dynamic>> data = List.generate(4, (i) => {'count': 0, 'accuracy': 0.0});
    
    for (var record in _records) {
      if (record.timestamp.month == now.month && record.timestamp.year == now.year) {
        int week = ((record.timestamp.day - 1) / 7).floor();
        if (week < 4) {
          data[week]['count'] = (data[week]['count'] as int) + 1;
          data[week]['accuracy'] = (data[week]['accuracy'] as double) + record.accuracyValue;
        }
      }
    }

    for (var weekData in data) {
      if (weekData['count'] > 0) {
        weekData['accuracy'] = (weekData['accuracy'] as double) / weekData['count'];
      }
    }
    return data;
  }

  List<Map<String, dynamic>> get topPlantsData {
    Map<String, int> counts = {};
    for (var record in _records) {
      counts[record.name] = (counts[record.name] ?? 0) + 1;
    }
    var sortedEntries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(3).map((e) => {'name': e.key, 'count': e.value, 'trend': '+${(e.value * 2) % 15}%'}).toList();
  }

  Map<String, double> get plantDistributionData {
    if (_records.isEmpty) return {};
    Map<String, int> counts = {};
    for (var record in _records) {
      counts[record.name] = (counts[record.name] ?? 0) + 1;
    }
    int total = _records.length;
    return counts.map((key, value) => MapEntry(key, value / total));
  }

  // --- Management Logic ---

  void markAttendance(String username) {
    final index = _employees.indexWhere((e) => e.username.toLowerCase() == username.toLowerCase());
    if (index != -1) {
      final emp = _employees[index];
      final today = DateTime.now().day;
      if (!emp.attendedDates.contains(today)) {
        _employees[index] = Employee(
          id: emp.id, 
          name: emp.name, 
          username: emp.username, 
          email: emp.email, 
          role: emp.role,
          totalWorkDays: emp.totalWorkDays,
          attendedDays: emp.attendedDays + 1,
          attendedDates: [...emp.attendedDates, today],
          missedDates: emp.missedDates.where((d) => d != today).toList(),
        );
        _addActivity('Attendance: ${emp.name} checked in');
        saveData();
        notifyListeners();
      }
    }
  }

  void addEmployee(Employee emp) {
    _employees.add(emp);
    _addActivity('Employee added: ${emp.name}');
    saveData();
    notifyListeners();
  }

  void updateEmployee(Employee emp) {
    final index = _employees.indexWhere((e) => e.id == emp.id);
    if (index != -1) {
      _employees[index] = emp;
      _addActivity('Employee updated: ${emp.name}');
      saveData();
      notifyListeners();
    }
  }

  void removeEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    saveData();
    notifyListeners();
  }

  void addPlant(Plant plant) {
    _plants.add(plant);
    _addActivity('New plant added: ${plant.name}');
    saveData();
    notifyListeners();
  }

  void updatePlant(Plant plant) {
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      _plants[index] = plant;
      _addActivity('Plant updated: ${plant.name}');
      saveData();
      notifyListeners();
    }
  }

  void removePlant(String id) {
    _plants.removeWhere((p) => p.id == id);
    saveData();
    notifyListeners();
  }

  void addDataset(Dataset dataset) {
    _datasets.insert(0, dataset);
    _addActivity('Dataset uploaded: ${dataset.fileName}');
    saveData();
    notifyListeners();
  }

  void addRecord(ClassificationRecord record) {
    final tagged = record.userId == currentUser
        ? record
        : ClassificationRecord(
            name: record.name,
            accuracyValue: record.accuracyValue,
            timestamp: record.timestamp,
            imageUrl: record.imageUrl,
            processingTime: record.processingTime,
            userId: currentUser,
          );
    _records.insert(0, tagged);
    _addActivity('Plant classified: ${tagged.name} by ${tagged.userId}');
    saveData();
    notifyListeners();
  }

  String? profileImageFor(String user) => _profileImages[user];

  Future<void> setProfileImage(String user, String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = sourcePath.split('.').last;
    final safeUser = user.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_');
    final destPath = '${dir.path}/profile_${safeUser}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(sourcePath).copy(destPath);
    final old = _profileImages[user];
    _profileImages[user] = destPath;
    if (old != null && old != destPath) {
      try { await File(old).delete(); } catch (_) {}
    }
    await saveData();
    notifyListeners();
  }

  void removeRecord(int index) {
    if (index >= 0 && index < _records.length) {
      final record = _records[index];
      _records.removeAt(index);
      _addActivity('Record removed: ${record.name}');
      saveData();
      notifyListeners();
    }
  }

  // --- Persistence ---

  void toggleDarkMode(bool value) { _isDarkMode = value; saveData(); notifyListeners(); }
  void setLanguage(String lang) { _language = lang; saveData(); notifyListeners(); }
  void setClassificationAlerts(bool value) { _classificationAlerts = value; saveData(); notifyListeners(); }
  void setReportNotifications(bool value) { _reportNotifications = value; saveData(); notifyListeners(); }
  void setSystemUpdates(bool value) { _systemUpdates = value; saveData(); notifyListeners(); }

  Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/app_storage.json');
  }

  Future<void> saveData() async {
    try {
      final file = await _getStorageFile();
      final data = {
        'employees': _employees.map((e) => e.toMap()).toList(),
        'plants': _plants.map((p) => p.toMap()).toList(),
        'datasets': _datasets.map((d) => d.toMap()).toList(),
        'records': _records.map((r) => r.toMap()).toList(),
        'activities': _activities.map((a) => a.toMap()).toList(),
        'profileImages': _profileImages,
        'settings': {
          'isDarkMode': _isDarkMode,
          'language': _language,
          'classificationAlerts': _classificationAlerts,
          'reportNotifications': _reportNotifications,
          'systemUpdates': _systemUpdates,
        }
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint("❌ Save Error: $e");
    }
  }

  Future<void> loadData() async {
    try {
      final file = await _getStorageFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);

        _employees = (data['employees'] as List).map((e) => Employee.fromMap(e)).toList();
        _plants = (data['plants'] as List).map((p) => Plant.fromMap(p)).toList();
        _datasets = (data['datasets'] as List? ?? []).map((d) => Dataset.fromMap(d)).toList();
        _records = (data['records'] as List)
            .where((r) => r is Map && r['userId'] != null)
            .map((r) => ClassificationRecord.fromMap(r))
            .toList();
        _activities = (data['activities'] as List).map((a) => Activity.fromMap(a)).toList();
        _profileImages = Map<String, String>.from(data['profileImages'] ?? {});

        if (data['settings'] != null) {
          final settings = data['settings'];
          _isDarkMode = settings['isDarkMode'] ?? false;
          _language = settings['language'] ?? 'English';
          _classificationAlerts = settings['classificationAlerts'] ?? true;
          _reportNotifications = settings['reportNotifications'] ?? true;
          _systemUpdates = settings['systemUpdates'] ?? false;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Load Error: $e");
    }
  }

  void _addActivity(String text) {
    _activities.insert(0, Activity(text: text, timestamp: DateTime.now()));
  }

  Employee? findEmployeeByUsername(String username) {
    try { return _employees.firstWhere((e) => e.username.toLowerCase() == username.toLowerCase()); } catch (_) { return null; }
  }
}
