import 'package:flutter/material.dart';

class RegisterLostScreen extends StatefulWidget {
  const RegisterLostScreen({super.key});

  @override
  State<RegisterLostScreen> createState() => _RegisterLostScreenState();
}

class _RegisterLostScreenState extends State<RegisterLostScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String? identity;
  String location = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Lost Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name of Item'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter item name' : null,
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter description' : null,
                onSaved: (v) => description = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Identity Number (if applicable)',
                ),
                onSaved: (v) => identity = v,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location (where lost)',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter location' : null,
                onSaved: (v) => location = v!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Send data to backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lost item registered!')),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
