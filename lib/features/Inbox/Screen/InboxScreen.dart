import 'package:flutter/material.dart';
import '../../../services/AuthService.dart';
import '../../../services/MailService.dart';


class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<dynamic> mails = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
   /* await AuthService.initMSAL();
    token = await AuthService.signIn();
    if (token != null) {
      final fetched = await MailService.getEmails(token!);
      setState(() => mails = fetched);
    }*/
  }

  void _sendTestEmail() async {
    if (token == null) return;

    final success = await MailService.sendEmail(
      token!,
      "someone@example.com", // ← update to any Outlook email
      "Hello from Flutter",
      "This is a test email sent via Microsoft Graph API 🚀",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "✅ Email sent!" : "❌ Failed to send email")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: mails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: mails.length,
        itemBuilder: (context, index) {
          final mail = mails[index];
          return ListTile(
            title: Text(mail['subject'] ?? '(No Subject)'),
            subtitle: Text(mail['from']?['emailAddress']?['address'] ?? ''),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MailDetailScreen(mail: mail),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MailDetailScreen extends StatelessWidget {
  final dynamic mail;
  const MailDetailScreen({super.key, required this.mail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mail['subject'] ?? 'Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(mail['body']?['content'] ?? 'No content.'),
        ),
      ),
    );
  }
}




/*class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<dynamic> mails = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await AuthService.initMSAL();
    token = await AuthService.signIn();
    if (token != null) {
      final fetched = await MailService.getEmails(token!);
      setState(() => mails = fetched);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inbox")),
      body: mails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: mails.length,
        itemBuilder: (context, index) {
          final mail = mails[index];
          return ListTile(
            title: Text(mail['subject'] ?? '(No Subject)'),
            subtitle: Text(mail['from']['emailAddress']['address']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MailDetailScreen(mail: mail),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MailDetailScreen extends StatelessWidget {
  final dynamic mail;
  const MailDetailScreen({super.key, required this.mail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mail['subject'] ?? 'Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(mail['body']['content'] ?? 'No content.'),
        ),
      ),
    );
  }
}*/
