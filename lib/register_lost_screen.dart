import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'main.dart';

class RegisterLostScreen extends StatefulWidget {
  final String itemType;
  const RegisterLostScreen({super.key, required this.itemType});

  @override
  State<RegisterLostScreen> createState() => _RegisterLostScreenState();
}

class _RegisterLostScreenState extends State<RegisterLostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String name = '', description = '', location = '';
  String? identity, category;
  File? _pickedImage;
  String? _defaultImagePath;

  static const List<String> categories = [
    'ID Card',
    'Driver License',
    'Passport',
    'Electronic Card',
    'Missing Person',
    'Lost Cat',
    'Cattle',
    'Clothing',
    'Shoes',
    'Luggage',
    'Mobile Phone',
    'Documents',
    'Keys',
    'Lost Dog',
    'Wanted Poster',
    'Wallet',
  ];

  static const Map<String, String> defaultImagePaths = {
    'ID Card': 'assets/default_id_card.png',
    'Driver License': 'assets/default_driver_license.png',
    'Passport': 'assets/default_passport.png',
    'Electronic Card': 'assets/default_electronic_card.png',
    'Missing Person': 'assets/default_missing_person.png',
    'Lost Cat': 'assets/default_cat.png',
    'Cattle': 'assets/default_livestock.png',
    'Clothing': 'assets/default_general_goods.png',
    'Shoes': 'assets/default_general_goods.png',
    'Luggage': 'assets/default_laguage.png',
    'Mobile Phone': 'assets/default_phones.png',
    'Documents': 'assets/default_documents.png',
    'Keys': 'assets/default_keys.png',
    'Lost Dog': 'assets/default_dog.png',
    'Wanted Poster': 'assets/default_wated.png',
    'Wallet': 'assets/default_wallet.png',
  };

  bool get isSensitiveCategory =>
      category == 'ID Card' ||
      category == 'Driver License' ||
      category == 'Passport' ||
      category == 'Electronic Card';

  Future<void> _pickImage() async {
    if (Platform.isWindows) {
      const typeGroup = XTypeGroup(
        label: 'images',
        extensions: ['jpg', 'jpeg', 'png'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        setState(() => _pickedImage = File(file.path));
      }
    } else {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
      if (image != null) {
        setState(() => _pickedImage = File(image.path));
      }
    }
  }

  Future<bool> _processPayment() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final lostItemsProvider = Provider.of<LostItemsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Register ${widget.itemType == 'lost' ? 'Lost' : 'Found'} Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTypeSelector(),
              _buildTextField('Name of Item', (v) => name = v ?? '',
                  validator: (v) =>
                      v?.isEmpty == true ? 'Enter item name' : null),
              _buildTextField('Description', (v) => description = v ?? '',
                  validator: (v) =>
                      v?.isEmpty == true ? 'Enter description' : null),
              _buildTextField(
                  'Identity Number (if applicable)', (v) => identity = v),
              _buildTextField(
                  'Location (where lost)', (v) => location = v ?? '',
                  validator: (v) =>
                      v?.isEmpty == true ? 'Enter location' : null),
              _buildCategoryDropdown(),
              if (_defaultImagePath != null) _buildDefaultImage(),
              if (_pickedImage != null) _buildPickedImage(),
              if (!isSensitiveCategory && _defaultImagePath != null)
                _buildUploadButton(),
              const SizedBox(height: 20),
              _buildSubmitButton(authProvider, lostItemsProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: widget.itemType,
          items: const [
            DropdownMenuItem(value: 'lost', child: Text('Lost Item')),
            DropdownMenuItem(value: 'found', child: Text('Found Item')),
          ],
          onChanged: null,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, void Function(String?) onSaved,
      {String? Function(String?)? validator}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Category'),
      value: category,
      items: categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) {
        setState(() {
          category = val;
          _pickedImage = null;
          _defaultImagePath = val != null ? defaultImagePaths[val] : null;
        });
      },
      validator: (v) => v?.isEmpty == true ? 'Select category' : null,
    );
  }

  Widget _buildDefaultImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Default Photo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Center(child: Image.asset(_defaultImagePath!, height: 100)),
        ],
      ),
    );
  }

  Widget _buildPickedImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Uploaded Photo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Center(child: Image.file(_pickedImage!, height: 100)),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.photo_camera),
        label: const Text('Upload Photo (optional)'),
        onPressed: _pickImage,
      ),
    );
  }

  Widget _buildSubmitButton(
      AuthProvider authProvider, LostItemsProvider lostItemsProvider) {
    return ElevatedButton(
      child: const Text('Submit'),
      onPressed: () => _handleSubmit(authProvider, lostItemsProvider),
    );
  }

  Future<void> _handleSubmit(
      AuthProvider authProvider, LostItemsProvider lostItemsProvider) async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (widget.itemType == 'found' && authProvider.role != 'partner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Only authorized entities can register found items.')),
      );
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Register ${widget.itemType == 'lost' ? 'Lost' : 'Found'} Item'),
        content: const Text(
          'To help keep the platform running and reward finders, there is a \$1 fee to register an item for 31 days.\n\nDo you want to proceed to payment?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed to Payment')),
        ],
      ),
    );

    if (proceed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final paid = await _processPayment();
    Navigator.pop(context);

    if (!paid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
      return;
    }

    final item = LostItem(
      id: const Uuid().v4(),
      photo: isSensitiveCategory || _pickedImage == null
          ? (_defaultImagePath ?? '')
          : '',
      name: name,
      identity: identity ?? '',
      description: description,
      location: location,
      isClaimed: false,
      category: category ?? '',
      itemType: widget.itemType,
      countryCode: authProvider.countryCode ?? 'US',
    );

    try {
      await lostItemsProvider.addItem(item, _pickedImage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${widget.itemType == 'lost' ? 'Lost' : 'Found'} item registered!')),
      );
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
