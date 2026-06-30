import 'package:flutter/material.dart';


import 'section_card.dart';

class ApprovalRoutingCard extends StatelessWidget {
  const ApprovalRoutingCard({super.key});

  @override
  Widget build(BuildContext context) {

    return SectionCard(

      title: "Approval Workflow",

      icon: Icons.account_tree_outlined,

      child: Column(

        children: [

          _step(
            "Medical Representative",
            "You",
            true,
          ),

          _line(),

          _step(
            "Area Sales Manager",
            "Pending",
            false,
          ),

          _line(),

          _step(
            "Regional Manager",
            "Pending",
            false,
          ),

          _line(),

          _step(
            "Finance",
            "Pending",
            false,
          ),

        ],

      ),

    );

  }

  Widget _line() {

    return Container(
      margin: const EdgeInsets.only(
        left: 18,
      ),
      height: 24,
      width: 2,
      color: Colors.grey.shade300,
    );

  }

  Widget _step(
      String title,
      String subtitle,
      bool completed,
      ) {

    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        CircleAvatar(

          radius: 18,

          backgroundColor: completed
              ? Colors.green
              : Colors.grey.shade300,

          child: Icon(

            completed
                ? Icons.check
                : Icons.person,

            color: Colors.white,

            size: 18,

          ),

        ),

        const SizedBox(width: 14),

        Expanded(

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),

              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              )

            ],

          ),

        )

      ],

    );

  }

}