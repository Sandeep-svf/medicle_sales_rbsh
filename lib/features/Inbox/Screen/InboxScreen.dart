import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  //  Mock email data
  final List<Map<String, dynamic>> emails = [
    {
      'subject': 'Welcome to Outlook',
      'from': {
        'emailAddress': {'address': 'outlook-noreply@microsoft.com'}
      },
      'body': {
        'content': 'Thanks for joining Outlook. Let us help you get started!'
      }
    },
    {
      'subject': 'Meeting Reminder',
      'from': {
        'emailAddress': {'address': 'hr@yourcompany.com'}
      },
      'body': {
        'content': 'This is a reminder for your 10 AM team sync-up.'
      }
    },
    {
      'subject': 'Invoice #234567',
      'from': {
        'emailAddress': {'address': 'billing@service.com'}
      },
      'body': {
        'content': 'Please find attached the invoice for March.'
      }
    },
  ];

  InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📬 My Inbox')),
      body: ListView.builder(
        itemCount: emails.length,
        itemBuilder: (context, index) {
          final email = emails[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(email['subject'] ?? '(No Subject)'),
              subtitle: Text(email['from']['emailAddress']['address'] ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmailDetailScreen(email: email),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class EmailDetailScreen extends StatelessWidget {
  final Map<String, dynamic> email;

  const EmailDetailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final body = email['body']?['content'] ?? 'No content available';

    return Scaffold(
      appBar: AppBar(title: const Text('📧 Email Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email['subject'] ?? '(No Subject)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('From: ${email['from']['emailAddress']['address'] ?? ''}'),
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(body, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
