import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/equipment_provider_provider.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _depositCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _transmissionCtrl = TextEditingController();
  final _maxSpeedCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  String _condition = 'Excellent';
  bool _isAvailable = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _depositCtrl.dispose();
    _hpCtrl.dispose();
    _weightCtrl.dispose();
    _yearCtrl.dispose();
    _transmissionCtrl.dispose();
    _maxSpeedCtrl.dispose();
    _fuelCtrl.dispose();
    _hoursCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'equipment_type': _typeCtrl.text.trim(),
      'price_per_day': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'quantity_available': int.tryParse(_quantityCtrl.text.trim()) ?? 1,
      'condition': _condition,
      'is_available': _isAvailable,
      if (_depositCtrl.text.trim().isNotEmpty)
        'deposit_amount': double.tryParse(_depositCtrl.text.trim()),
      if (_hpCtrl.text.trim().isNotEmpty) 'horsepower': _hpCtrl.text.trim(),
      if (_weightCtrl.text.trim().isNotEmpty) 'weight': _weightCtrl.text.trim(),
      if (_yearCtrl.text.trim().isNotEmpty)
        'year_of_manufacture': int.tryParse(_yearCtrl.text.trim()),
      if (_transmissionCtrl.text.trim().isNotEmpty)
        'transmission': _transmissionCtrl.text.trim(),
      if (_maxSpeedCtrl.text.trim().isNotEmpty)
        'max_speed': _maxSpeedCtrl.text.trim(),
      if (_fuelCtrl.text.trim().isNotEmpty) 'fuel_type': _fuelCtrl.text.trim(),
      if (_hoursCtrl.text.trim().isNotEmpty)
        'hours_of_use': _hoursCtrl.text.trim(),
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
      if (_instructionsCtrl.text.trim().isNotEmpty)
        'usage_instructions': _instructionsCtrl.text.trim(),
    };

    final ep = context.read<EquipmentProviderProvider>();
    final ok = await ep.createEquipment(data);

    setState(() => _isLoading = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Equipment added successfully!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ep.errorMessage ?? 'Failed to add equipment',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textDark, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Add Equipment',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Basic Information'),
                      _field(_nameCtrl, 'Machine Name *',
                          hint: 'e.g. John Deere 8R 410',
                          required: true),
                      _field(_typeCtrl, 'Equipment Type *',
                          hint: 'e.g. Heavy Tractor', required: true),
                      _field(_priceCtrl, 'Daily Rental Price (DA) *',
                          hint: '15000',
                          required: true,
                          keyboard: TextInputType.number),
                      Row(children: [
                        Expanded(
                          child: _field(_quantityCtrl, 'Quantity *',
                              hint: '1',
                              required: true,
                              keyboard: TextInputType.number),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(_depositCtrl, 'Deposit (DA)',
                              hint: '5000',
                              keyboard: TextInputType.number),
                        ),
                      ]),
                      _dropdownCondition(),
                      _availabilityToggle(),

                      const SizedBox(height: 8),
                      _SectionTitle('Technical Specifications'),
                      Row(children: [
                        Expanded(
                            child: _field(_hpCtrl, 'Horsepower',
                                hint: '410 HP')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _field(_weightCtrl, 'Weight',
                                hint: '8500 kg')),
                      ]),
                      Row(children: [
                        Expanded(
                            child: _field(_yearCtrl, 'Year',
                                hint: '2023',
                                keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _field(_fuelCtrl, 'Fuel Type',
                                hint: 'Diesel')),
                      ]),
                      Row(children: [
                        Expanded(
                            child: _field(_transmissionCtrl, 'Transmission',
                                hint: 'Automatic')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _field(_maxSpeedCtrl, 'Max Speed',
                                hint: '40 km/h')),
                      ]),
                      _field(_hoursCtrl, 'Hours of Use',
                          hint: '1200 hrs'),
                      _field(_locationCtrl, 'Location / Base',
                          hint: 'Wilaya, City'),
                      _field(_descCtrl, 'Description',
                          hint: 'General notes...', maxLines: 3),
                      _field(_instructionsCtrl, 'Usage Instructions',
                          hint: 'How to operate...', maxLines: 3),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Add to Fleet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String? hint,
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? 'This field is required' : null
            : null,
      ),
    );
  }

  Widget _dropdownCondition() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: _condition,
        decoration: const InputDecoration(labelText: 'Condition'),
        items: ['Excellent', 'Good', 'Fair']
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (v) => setState(() => _condition = v ?? 'Excellent'),
      ),
    );
  }

  Widget _availabilityToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Mark as Available',
            style: TextStyle(
                color: AppTheme.textDark, fontWeight: FontWeight.w600)),
        value: _isAvailable,
        activeColor: AppTheme.primary,
        onChanged: (v) => setState(() => _isAvailable = v),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
