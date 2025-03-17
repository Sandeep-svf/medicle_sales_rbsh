import 'package:flutter/material.dart';

class Blogscreen extends StatelessWidget {
  const Blogscreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy blog data
    final List<Map<String, String>> blogPosts = [
      {
        "image": "assets/images/dummy.jpeg",
        "title": "Exploring the Beauty of Nature"
      },
      {
        "image": "assets/images/dummy.jpeg",
        "title": "The Future of AI and Technology"
      },
      {
        "image": "assets/images/dummy.jpeg",
        "title": "How to Stay Fit and Healthy"
      },
      {
        "image": "assets/images/dummy.jpeg",
        "title": "The Art of Minimalist Living"
      },
      {
        "image": "assets/images/dummy.jpeg",
        "title": "Traveling the World on a Budget"
      },
    ];

    return Scaffold(
      /*appBar: AppBar(
        title: const Text("Blog"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),*/
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          final post = blogPosts[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blog Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    post["image"]!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

                // Blog Title
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    post["title"]!,
                    style: const TextStyle(
                      fontSize: 18,

                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
