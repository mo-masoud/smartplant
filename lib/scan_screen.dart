import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'preview_screen.dart';
import 'result_screen.dart';
import 'app_data.dart';

enum ScanStep {
  methodSelection,
  choice,
  camera,
  preview,
  result,
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  ScanStep _currentStep = ScanStep.methodSelection;
  CameraController? _controller;
  XFile? _imageFile;
  bool _isCameraInitialized = false;
  bool _isFromCamera = false;
  final ImagePicker _picker = ImagePicker();
  ScanStep _previousChoiceStep = ScanStep.methodSelection;

  // The classifier model picked from the cards on the Classify Plant page.
  // [_selectedModel] is sent as the `model` key to /predict; [_selectedModelLabel]
  // is shown as the title on the choice and preview screens. Defaults to VGG19.
  String _selectedModel = 'keras';
  String _selectedModelLabel = 'VGG19 (Standard)';

  void _selectModel(String apiValue, String label) {
    setState(() {
      _selectedModel = apiValue;
      _selectedModelLabel = label;
      _currentStep = ScanStep.choice;
    });
  }

  // عنوان السيرفر الافتراضي
  String _serverIp = "192.168.1.14";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverIp = prefs.getString('server_ip') ?? "192.168.1.14";
    });
  }

  Future<void> _saveIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
    setState(() {
      _serverIp = ip;
    });
  }

  void _showIpConfigDialog() {
    final controller = TextEditingController(text: _serverIp);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Configuration'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Server IP Address',
            hintText: 'e.g. 192.168.1.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveIp(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized)
      return;
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  bool _isChoiceStep(ScanStep step) => step == ScanStep.choice;

  Future<void> _requestPermissionAndStart() async {
    final originStep = _currentStep;
    var status = await Permission.camera.request();
    if (status.isGranted) {
      await _initCameraFlow();
      if (cameras.isNotEmpty) {
        // Keep the original choice screen as the back target; don't overwrite
        // it when re-scanning from the preview ("Scan Again").
        if (_isChoiceStep(originStep)) {
          _previousChoiceStep = originStep;
        }
        _changeStep(ScanStep.camera);
      }
    }
  }

  Future<void> _initCameraFlow() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) await _initializeCameraController(cameras[0]);
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _initializeCameraController(
    CameraDescription cameraDescription,
  ) async {
    await _controller?.dispose();
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
      if (mounted)
        setState(() {
          _isCameraInitialized = true;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _isCameraInitialized = false;
        });
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _imageFile = file;
        _isFromCamera = true;
        _currentStep = ScanStep.preview;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final originStep = _currentStep;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _isFromCamera = false;
          // Remember which choice screen we came from for the preview's
          // back button; ignore re-picks made from the preview itself.
          if (_isChoiceStep(originStep)) {
            _previousChoiceStep = originStep;
          }
          _currentStep = ScanStep.preview;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _changeStep(ScanStep step) {
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _handleClassificationSubmit() async {
    if (_imageFile == null) return;

    try {
      var url = Uri.parse("http://95.179.253.41:8080/api/predict");

      var request = http.MultipartRequest('POST', url);
      request.fields['model'] = _selectedModel;
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        final String plantName = result['plant']?.toString() ?? 'Unknown Plant';
        final double confidence =
            (result['confidence'] as num?)?.toDouble() ?? 0.0;
        final double pTime =
            (result['processing_time'] as num?)?.toDouble() ?? 1.2;

        final record = ClassificationRecord(
          name: plantName,
          accuracyValue: confidence,
          timestamp: DateTime.now(),
          imageUrl: _imageFile!.path,
          processingTime: pTime,
          userId: AppData().currentUser,
        );

        AppData().addRecord(record);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Detected: $plantName (${(confidence * 100).toStringAsFixed(1)}%)',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _changeStep(ScanStep.result);
      } else {
        debugPrint('Server error ${response.statusCode}: ${response.body}');
        String detail = response.body.trim();
        try {
          final decoded = jsonDecode(detail);
          if (decoded is Map) {
            detail = (decoded['detail'] ?? decoded['error'] ?? decoded['message'] ?? detail).toString();
          }
        } catch (_) {}
        if (detail.isEmpty) detail = 'No response body';
        throw Exception('Server ${response.statusCode}: $detail');
      }
    } catch (e) {
      debugPrint('Classification error: $e');
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _changeStep(ScanStep.preview);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (_currentStep) {
      case ScanStep.methodSelection:
        return _buildMethodSelectionView(
          isDark,
          theme,
          key: const ValueKey('methodSelection'),
        );
      case ScanStep.choice:
        return _buildChoiceView(
          key: const ValueKey('choice'),
          title: _selectedModelLabel,
          subtitle: 'Scan or Upload',
          showGallery: true,
          isDark: isDark,
          theme: theme,
        );
      case ScanStep.camera:
        return _buildCameraView(key: const ValueKey('camera'));
      case ScanStep.preview:
        return PreviewScreen(
          key: const ValueKey('preview'),
          imageFile: _imageFile!,
          isFromCamera: _isFromCamera,
          title: _selectedModelLabel,
          onSelectDifferent: _isFromCamera
              ? _requestPermissionAndStart
              : _pickImageFromGallery,
          onBack: () => _changeStep(_previousChoiceStep),
          onSubmit: _handleClassificationSubmit,
        );
      case ScanStep.result:
        return ResultScreen(
          key: const ValueKey('result'),
          imageFile: _imageFile!,
          onNewScan: () => _changeStep(ScanStep.methodSelection),
          onBack: () => _changeStep(ScanStep.preview),
        );
    }
  }

  Widget _buildMethodSelectionView(bool isDark, ThemeData theme, {Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: theme.scaffoldBackgroundColor,
      // زر مخفي في شريط المهام العلوي لضبط الـ IP
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_ethernet,
              color: isDark ? Colors.white30 : Colors.black12,
            ),
            onPressed: _showIpConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classify Plant',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? Colors.greenAccent
                          : const Color(0xFF06402B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select the environment method to start classification',
                    style: TextStyle(fontSize: 16, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildHeroMethodCard(
                    theme,
                    isDark,
                    icon: Icons.psychology_outlined,
                    title: 'VGG19 (Standard)',
                    desc: 'Laboratory or indoor conditions.',
                    color: const Color(0xFF06402B),
                    onTap: () => _selectModel('keras', 'VGG19 (Standard)'),
                  ),
                  const SizedBox(height: 20),
                  _buildHeroMethodCard(
                    theme,
                    isDark,
                    icon: Icons.forest_outlined,
                    title: 'Unified Plant Mode',
                    desc: 'Natural environments or outdoor.',
                    color: const Color(0xFF2E7D32),
                    onTap: () => _selectModel('nemotron', 'Unified Plant Mode'),
                  ),
                  const SizedBox(height: 20),
                  _buildHeroMethodCard(
                    theme,
                    isDark,
                    icon: Icons.videocam_outlined,
                    title: 'Data-efficient Image Transformer',
                    desc: 'Continuous camera feed analysis.',
                    color: const Color(0xFF1B5E20),
                    onTap: () =>
                        _selectModel('nemotron-vl', 'Data-efficient Image Transformer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroMethodCard(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.greenAccent : color).withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.greenAccent : color,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.hintColor.withAlpha(100),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceView({
    required Key key,
    required String title,
    required String subtitle,
    required bool showGallery,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Scaffold(
      key: key,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildChoiceHeader(title, subtitle, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Choose your preferred method to\ncapture plant images',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildActionCard(
                    theme,
                    isDark,
                    icon: Icons.camera_alt_outlined,
                    title: 'Scan Using Camera',
                    subtitle: 'Live plant detection and analysis',
                    isPrimary: true,
                    onTap: _requestPermissionAndStart,
                  ),
                  if (showGallery) ...[
                    const SizedBox(height: 20),
                    _buildActionCard(
                      theme,
                      isDark,
                      icon: Icons.file_upload_outlined,
                      title: 'Upload From Files',
                      subtitle: 'Select image from your device',
                      isPrimary: false,
                      onTap: _pickImageFromGallery,
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildTipsCard(theme, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceHeader(String title, String subtitle, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _changeStep(ScanStep.methodSelection),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? const Color(0xFF042016) : const Color(0xFF06402B))
              : theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 8),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withAlpha(20)
                    : (isDark ? Colors.greenAccent : const Color(0xFF06402B))
                          .withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.greenAccent : const Color(0xFF06402B)),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : theme.textTheme.bodyLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isPrimary ? Colors.white70 : theme.hintColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme, bool isDark) {
    final accentColor = isDark ? Colors.greenAccent : const Color(0xFF06402B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.layers_outlined, color: accentColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Tips for Best Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTipItem(
            'Ensure the plant leaf is clear and well-lit',
            accentColor,
            theme,
          ),
          _buildTipItem('Avoid shadows and reflections', accentColor, theme),
          _buildTipItem(
            'Capture the entire leaf structure',
            accentColor,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView({Key? key}) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isCameraInitialized && _controller != null)
            Center(child: CameraPreview(_controller!)),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => _changeStep(_previousChoiceStep),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
