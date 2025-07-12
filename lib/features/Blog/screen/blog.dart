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
      appBar: AppBar(
        title: const Text("Blog Posts"),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: blogPosts.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, // Each item max 250px wide
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75, // Controls height vs width
              ),
              itemBuilder: (context, index) {
                final post = blogPosts[index];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Blog Image
                      // Blog Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: SizedBox(
                          height: 180,
                          child: const FlutterLogo(size: double.infinity, style: FlutterLogoStyle.markOnly),
                        ),
                      ),


                      // Blog Title
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          post["title"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Only reserve height for one line
                        ),

                      ),
                    ],
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
