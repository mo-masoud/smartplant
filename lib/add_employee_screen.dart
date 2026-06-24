import 'package:flutter/material.dart';
import 'app_data.dart';
import 'widgets/pressable.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employeeToEdit;
  const AddEmployeeScreen({super.key, this.employeeToEdit});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  final TextEditingController _passwordController = TextEditingController();
  late String _selectedRole;

  final Map<String, String> _rolePermissions = {
    'Admin': 'Full system access and data management',
    'Worker': 'Can scan plants and view records',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.employeeToEdit?.name ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.employeeToEdit?.username ?? '',
    );
    _selectedRole = widget.employeeToEdit?.role ?? 'Worker';
  }

  void _saveEmployee() {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (widget.employeeToEdit == null) {
      final newEmp = Employee(
        id: 'E${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
        name: _nameController.text,
        username: _usernameController.text,
        email: '${_usernameController.text.toLowerCase()}@company.com',
        role: _selectedRole,
      );
      AppData().addEmployee(newEmp);
    } else {
      final updatedEmp = Employee(
        id: widget.employeeToEdit!.id,
        name: _nameController.text,
        username: _usernameController.text,
        email: widget.employeeToEdit!.email,
        role: _selectedRole,
        totalWorkDays: widget.employeeToEdit!.totalWorkDays,
        attendedDays: widget.employeeToEdit!.attendedDays,
        attendedDates: widget.employeeToEdit!.attendedDates,
        missedDates: widget.employeeToEdit!.missedDates,
      );
      AppData().updateEmployee(updatedEmp);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 20,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pressable(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.employeeToEdit == null
                      ? 'Add New Employee'
                      : 'Edit Employee',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.employeeToEdit == null
                      ? 'Create employee account'
                      : 'Update employee details',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(28),
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
                    Text(
                      'Employee Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      'Full Name',
                      'Enter full name',
                      Icons.person_outline,
                      _nameController,
                      theme,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(
                      'Username',
                      'Login username',
                      Icons.mail_outline,
                      _usernameController,
                      theme,
                    ),
                    if (widget.employeeToEdit == null) ...[
                      const SizedBox(height: 20),
                      _buildInputField(
                        'Initial Password',
                        'Create password',
                        Icons.lock_outline,
                        _passwordController,
                        theme,
                        isPassword: true,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Employee Role',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.hintColor,
                          ),
                          items: _rolePermissions.keys.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 20,
                                    color: isDark
                                        ? Colors.greenAccent
                                        : const Color(0xFF06402B),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null)
                              setState(() => _selectedRole = newValue);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? Colors.greenAccent
                                    : const Color(0xFF06402B))
                                .withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              (isDark
                                      ? Colors.greenAccent
                                      : const Color(0xFF06402B))
                                  .withAlpha(50),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role Permissions',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.greenAccent
                                  : const Color(0xFF06402B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _rolePermissions[_selectedRole]!,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Pressable(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveEmployee,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF042016)
                                : const Color(0xFF06402B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.employeeToEdit == null
                                ? 'Create Employee Account'
                                : 'Update Employee',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Pressable(
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: theme.hintColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
    ThemeData theme, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              icon: Icon(icon, size: 20, color: theme.hintColor),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: theme.hintColor.withAlpha(150),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
