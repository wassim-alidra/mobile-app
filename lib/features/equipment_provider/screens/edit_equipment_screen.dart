import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../models/equipment_model.dart';
import '../providers/equipment_provider_provider.dart';

class EditEquipmentScreen extends StatefulWidget {
  final EquipmentModel equipment;
  const EditEquipmentScreen({super.key, required this.equipment});

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _depositCtrl;
  late final TextEditingController _hpCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _transmissionCtrl;
  late final TextEditingController _maxSpeedCtrl;
  late final TextEditingController _fuelCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instructionsCtrl;
  late String _condition;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    final e = widget.equipment;
    _nameCtrl = TextEditingController(text: e.name);
    _typeCtrl = TextEditingController(text: e.equipmentType);
    _priceCtrl =
        TextEditingController(text: e.pricePerDay.toStringAsFixed(0));
    _quantityCtrl =
        TextEditingController(text: e.quantityAvailable.toString());
    _depositCtrl = TextEditingController(
        text: e.depositAmount?.toStringAsFixed(0) ?? '');
    _hpCtrl = TextEditingController(text: e.horsepower ?? '');
    _weightCtrl = TextEditingController(text: e.weight ?? '');
    _yearCtrl =
        TextEditingController(text: e.yearOfManufacture?.toString() ?? '');
    _transmissionCtrl = TextEditingController(text: e.transmission ?? '');
    _maxSpeedCtrl = TextEditingController(text: e.maxSpeed ?? '');
    _fuelCtrl = TextEditingController(text: e.fuelType ?? '');
    _hoursCtrl = TextEditingController(text: e.hoursOfUse ?? '');
    _locationCtrl = TextEditingController(text: e.location ?? '');
    _descCtrl = TextEditingController(text: e.description ?? '');
    _instructionsCtrl =
        TextEditingController(text: e.usageInstructions ?? '');
    _condition = e.condition.isNotEmpty ? e.condition : 'Excellent';
    _isAvailable = e.isAvailable;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _typeCtrl.dispose(); _priceCtrl.dispose();
    _quantityCtrl.dispose(); _depositCtrl.dispose(); _hpCtrl.dispose();
    _weightCtrl.dispose(); _yearCtrl.dispose(); _transmissionCtrl.dispose();
    _maxSpeedCtrl.dispose(); _fuelCtrl.dispose(); _hoursCtrl.dispose();
    _locationCtrl.dispose(); _descCtrl.dispose(); _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = <String, dynamic>{
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
    final ok = await ep.updateEquipment(widget.equipment.id, data);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            ok ? 'Equipment updated!' : ep.errorMessage ?? 'Failed',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: ok ? AppTheme.primary : Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
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
                  const Text('Edit Equipment',
                      style: TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
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
                      _field(_nameCtrl, 'Machine Name *', required: true),
                      _field(_typeCtrl, 'Equipment Type *', required: true),
                      _field(_priceCtrl, 'Daily Rental Price (DA) *',
                          required: true,
                          keyboard: TextInputType.number),
                      Row(children: [
                        Expanded(child: _field(_quantityCtrl, 'Quantity *',
                            required: true, keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_depositCtrl, 'Deposit (DA)',
                            keyboard: TextInputType.number)),
                      ]),
                      _dropdownCondition(),
                      _availabilityToggle(),
                      const SizedBox(height: 4),
                      _SectionTitle('Technical Specifications'),
                      Row(children: [
                        Expanded(child: _field(_hpCtrl, 'Horsepower')),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_weightCtrl, 'Weight')),
                      ]),
                      Row(children: [
                        Expanded(child: _field(_yearCtrl, 'Year',
                            keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_fuelCtrl, 'Fuel Type')),
                      ]),
                      Row(children: [
                        Expanded(child: _field(_transmissionCtrl, 'Transmission')),
                        const SizedBox(width: 12),
                        Expanded(child: _field(_maxSpeedCtrl, 'Max Speed')),
                      ]),
                      _field(_hoursCtrl, 'Hours of Use'),
                      _field(_locationCtrl, 'Location'),
                      _field(_descCtrl, 'Description', maxLines: 3),
                      _field(_instructionsCtrl, 'Usage Instructions',
                          maxLines: 3),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Save Changes',
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

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false,
      TextInputType keyboard = TextInputType.text,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  Widget _dropdownCondition() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: ['Excellent', 'Good', 'Fair'].contains(_condition)
            ? _condition
            : 'Excellent',
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
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6)),
    );
  }
}
