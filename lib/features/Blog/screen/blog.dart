import 'package:flutter/material.dart';

class Blogscreen extends StatelessWidget {
  const Blogscreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy blog data
    final List<Map<String, String>> blogPosts = [
      {"image": "assets/images/dummy.jpeg", "title": "Exploring Nature"},
      {"image": "assets/images/dummy.jpeg", "title": "Future of AI"},
      {"image": "assets/images/dummy.jpeg", "title": "Stay Fit & Healthy"},
      {"image": "assets/images/dummy.jpeg", "title": "Minimalist Living"},
      {"image": "assets/images/dummy.jpeg", "title": "Travel on Budget"},
      {"image": "assets/images/dummy.jpeg", "title": "Healthy Eating"},
      {"image": "assets/images/dummy.jpeg", "title": "Productivity Hacks"},
      {"image": "assets/images/dummy.jpeg", "title": "Investing Basics"},
      {"image": "assets/images/dummy.jpeg", "title": "Remote Work Tips"},
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: blogPosts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columns
            crossAxisSpacing: 8, // Space between columns
            mainAxisSpacing: 8, // Space between rows
            childAspectRatio: 0.75, // Adjust height
          ),
          itemBuilder: (context, index) {
            final post = blogPosts[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blog Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      post["image"]!,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Blog Title
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      post["title"]!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
