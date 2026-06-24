import 'package:flutter/material.dart';
import 'app_data.dart';
import 'widgets/pressable.dart';

class DataMgmtScreen extends StatefulWidget {
  const DataMgmtScreen({super.key});

  @override
  State<DataMgmtScreen> createState() => _DataMgmtScreenState();
}

class _DataMgmtScreenState extends State<DataMgmtScreen> {
  String _selectedTab = 'Plants';

  void _showPlantForm({Plant? existingPlant}) {
    final nameController = TextEditingController(text: existingPlant?.name ?? '');
    final codeController = TextEditingController(text: existingPlant?.code ?? '');
    final categoryController = TextEditingController(text: existingPlant?.category ?? 'Tropical');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingPlant == null ? 'Add New Plant' : 'Edit Plant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Plant Name')),
              TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Plant Code')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
            ],
          ),
        ),
        actions: [
          Pressable(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
          Pressable(
            child: TextButton(
              onPressed: () {
                if (nameController.text.isEmpty || codeController.text.isEmpty) return;

                final plant = Plant(
                  id: existingPlant?.id ?? 'P${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
                  name: nameController.text,
                  code: codeController.text,
                  category: categoryController.text,
                  updatedAt: DateTime.now(),
                );

                if (existingPlant == null) {
                  AppData().addPlant(plant);
                } else {
                  AppData().updatePlant(plant);
                }
                Navigator.pop(context);
              },
              child: Text(existingPlant == null ? 'Add' : 'Update'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if user is Admin
    if (AppData().currentUserRole != "Admin") {
      return const Scaffold(body: Center(child: Text("Access Denied: Admins Only")));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 5), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTabItem('Plants', theme, isDark),
                        _buildTabItem('Dataset', theme, isDark),
                        _buildTabItem('Employees', theme, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ListenableBuilder(
                    listenable: AppData(),
                    builder: (context, _) {
                      if (_selectedTab == 'Plants') return _buildPlantsTab(theme, isDark);
                      if (_selectedTab == 'Dataset') return _buildDatasetTab(theme, isDark);
                      if (_selectedTab == 'Employees') return _buildEmployeesTab(theme, isDark);
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Data Management', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Admin controls', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, ThemeData theme, bool isDark) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: Pressable(
        child: GestureDetector(
          onTap: () => setState(() => _selectedTab = title),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF06402B) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: isSelected ? Colors.white : theme.hintColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantsTab(ThemeData theme, bool isDark) {
    final plants = AppData().plants;
    return Column(
      children: [
        Pressable(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPlantForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add), SizedBox(width: 8), Text('Add New Plant', style: TextStyle(fontWeight: FontWeight.bold))]),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildListContainer(
          theme, 
          isDark, 
          Icons.storage_rounded, 
          'Plant Database', 
          plants.isEmpty 
            ? const Center(child: Text('No plants found')) 
            : Column(
                children: plants.map((p) => _buildPlantItem(p, theme, isDark, isLast: p == plants.last)).toList()
              )
        ),
      ],
    );
  }

  Widget _buildPlantItem(Plant plant, ThemeData theme, bool isDark, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plant.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 4),
                  Text('${plant.code} • ${plant.category}', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                ]),
              ),
              _buildActionButtons(() => _showPlantForm(existingPlant: plant), () => _showDeleteDialog(context, 'Plant', plant.name, () => AppData().removePlant(plant.id)), isDark),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 20, endIndent: 20, color: theme.dividerColor.withAlpha(50)),
      ],
    );
  }

  Widget _buildDatasetTab(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Dataset', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(color: isDark ? Colors.white.withAlpha(5) : const Color(0xFFF5F7F6), borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withAlpha(50))),
                child: const Column(children: [Icon(Icons.file_upload_outlined, size: 32), SizedBox(height: 16), Text('Click to Browse Files')]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeesTab(ThemeData theme, bool isDark) {
    final employees = AppData().employees;
    return Column(
      children: [
        _buildListContainer(
          theme, 
          isDark, 
          Icons.people_outline_rounded, 
          'Employee List', 
          employees.isEmpty 
            ? const Center(child: Text('No employees found')) 
            : Column(
                children: employees.map((e) => _buildEmployeeItem(e, theme, isDark, isLast: e == employees.last)).toList()
              )
        ),
      ],
    );
  }

  Widget _buildEmployeeItem(Employee emp, ThemeData theme, bool isDark, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(emp.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                Text(emp.role, style: TextStyle(color: theme.hintColor, fontSize: 13)),
              ])),
              _buildActionButtons(() {}, () => _showDeleteDialog(context, 'Employee', emp.name, () => AppData().removeEmployee(emp.id)), isDark),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 20, endIndent: 20, color: theme.dividerColor.withAlpha(50)),
      ],
    );
  }

  Widget _buildListContainer(ThemeData theme, bool isDark, IconData icon, String title, Widget child) {
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 5), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [Icon(icon, color: isDark ? Colors.greenAccent : const Color(0xFF06402B)), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
        Divider(height: 1, color: theme.dividerColor.withAlpha(50)),
        child,
      ]),
    );
  }

  Widget _buildActionButtons(VoidCallback onEdit, VoidCallback onDelete, bool isDark) {
    return Row(children: [
      Pressable(child: GestureDetector(onTap: onEdit, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF06402B), shape: BoxShape.circle), child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18)))),
      const SizedBox(width: 12),
      Pressable(child: GestureDetector(onTap: onDelete, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade100, shape: BoxShape.circle), child: Icon(Icons.delete_outline_rounded, color: isDark ? Colors.redAccent : Colors.grey, size: 18)))),
    ]);
  }

  void _showDeleteDialog(BuildContext context, String type, String name, VoidCallback onDelete) {
    showDialog(context: context, builder: (context) => AlertDialog(title: Text('Delete $type'), content: Text('Confirm delete $name?'), actions: [Pressable(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))), Pressable(child: TextButton(onPressed: () { onDelete(); Navigator.pop(context); }, child: const Text('Delete', style: TextStyle(color: Colors.red))))]));
  }
}
