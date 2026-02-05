import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/Inbox/service/MailService.dart';


import '../service/AuthService.dart';



class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool loading = true;
  String? error;
  List mails = [];

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    final token = await AuthService.instance.signIn();

    if (token == null) {
      setState(() {
        error = 'Login failed';
        loading = false;
      });
      return;
    }

    try {
      final data = await MailService.getInbox(token);
      setState(() {
        mails = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: ListView.builder(
        itemCount: mails.length,
        itemBuilder: (context, index) {
          final mail = mails[index];
          return ListTile(
            title: Text(mail['subject'] ?? '(No subject)'),
            subtitle: Text(
              mail['from']['emailAddress']['address'] ?? '',
            ),
          );
        },
      ),
    );
  }
}
