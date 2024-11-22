import 'package:flutter/material.dart';
import '../../helpers/helpers.dart';
import '../models/xpass_register_models.dart';
import '../service/xpass_register_service.dart';

class ViewXpassEditRegister extends StatefulWidget {
  const ViewXpassEditRegister({super.key});
  static const routeName = '/viewxpasseditregister';

  @override
  State<ViewXpassEditRegister> createState() => _ViewXpassEditRegisterState();
}

class _ViewXpassEditRegisterState extends State<ViewXpassEditRegister> {
  late TextEditingController _licenseController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  bool _dashAdded = false;
  RegisterItem? registerItem;

  @override
  void initState() {
    super.initState();

    _licenseController = TextEditingController();
    _descriptionController = TextEditingController();
    _isActive = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the register item from the route arguments
      registerItem = ModalRoute.of(context)!.settings.arguments as RegisterItem;
      if (registerItem != null) {
        _licenseController.text = registerItem!.license;
        _descriptionController.text = registerItem!.description;
        _isActive = registerItem!.status == RegisterStatus.ACTIVE;

        _licenseController.addListener(_formatLicensePlates);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _licenseController.removeListener(_formatLicensePlates);
    _licenseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _formatLicensePlates() {
    String text = _licenseController.text.toUpperCase();
    int cursorPosition = _licenseController.selection.base.offset;

    if (text.length > 7) {
      text = text.substring(0, 7);
    }

    if (text.length == 2 && !_dashAdded) {
      text = '$text-';
      _dashAdded = true;
      cursorPosition += 1;
    } else if (text.length < 2) {
      _dashAdded = false;
    }

    _licenseController.value = TextEditingValue(
      text: text,
      selection:
          TextSelection.collapsed(offset: cursorPosition.clamp(0, text.length)),
    );
  }

  Future<void> _onSave() async {
    RegisterItem editRegisterItem = RegisterItem(
        id: registerItem!.id,
        license: _licenseController.text,
        description: _descriptionController.text,
        active: _isActive);

    try {
      Map<String, dynamic> updateRegisterResponse =
          await XpassRegisterService.updateRegister(
        editRegisterItem,
      );

      if (updateRegisterResponse['status'] == 200) {
        MyHelpers.msg(
            message: "Register updated",
            sec: 5,
            backgroundColor: Colors.lightBlueAccent);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        MyHelpers.msg(
            message: "Connectivity [50x]", backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      MyHelpers.msg(
          message: e.toString().replaceAll('Exception:', ''),
          backgroundColor: Colors.redAccent);
    }
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('License'),
            const SizedBox(height: 16),
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description'),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Checkbox(
                  value: _isActive,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                ),
                const Text('Active', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _onSave,
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 24, 96, 26),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                ElevatedButton(
                  onPressed: _onCancel,
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 180, 49, 49),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}