// lib/screens/ticket_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import 'create_ticket_screen.dart';
import 'chat_screen.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketListProvider);
    final userRole = ref.watch(currentUserRoleProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Sliver App Bar
          SliverAppBar(
            floating: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Help Desk ($userRole View)'),
              background: Container(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.switch_account),
                onPressed: () =>
                    ref.read(currentUserRoleProvider.notifier).toggle(),
                tooltip: 'Switch User Role',
              ),
            ],
          ),

          // 2. Sliver List (The Content)
          ticketsAsync.when(
            data: (tickets) => SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final ticket = tickets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: _buildStatusIcon(ticket.status),
                    title: Text(
                      ticket.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${ticket.category} • ${DateFormat('MM/dd').format(ticket.date)}\nCustomer: ${ticket.customerName}",
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(ticket: ticket),
                        ),
                      );
                    },
                  ),
                );
              }, childCount: tickets.length),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    Color color;
    switch (status) {
      case 'Open':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Closed':
        color = Colors.grey;
        break;
      default:
        color = Colors.blue;
    }
    return CircleAvatar(backgroundColor: color, radius: 8);
  }
}
