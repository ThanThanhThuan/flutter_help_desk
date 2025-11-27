// lib/screens/create_ticket_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';
import '../providers/app_providers.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'Technical';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Technical', 'Billing', 'General']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content / Description',
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final ticket = Ticket(
        id: '', // Firestore auto-id handled in repo usually, or ignore here
        date: DateTime.now(),
        customerName: 'Customer A', // Hardcoded per requirement
        category: _category,
        title: _titleController.text,
        content: _contentController.text,
        status: 'Open',
      );

      ref.read(ticketControllerProvider.notifier).createTicket(ticket);
      Navigator.pop(context);
    }
  }
}
