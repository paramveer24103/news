import 'package:flutter/material.dart';

class NewsCategory {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  static const List<NewsCategory> categories = [
    NewsCategory(
      id: 'general',
      name: 'general',
      displayName: 'General',
      icon: Icons.public,
      color: Colors.blue,
    ),
    NewsCategory(
      id: 'business',
      name: 'business',
      displayName: 'Business',
      icon: Icons.business,
      color: Colors.green,
    ),
    NewsCategory(
      id: 'technology',
      name: 'technology',
      displayName: 'Technology',
      icon: Icons.computer,
      color: Colors.purple,
    ),
    NewsCategory(
      id: 'sports',
      name: 'sports',
      displayName: 'Sports',
      icon: Icons.sports_soccer,
      color: Colors.orange,
    ),
    NewsCategory(
      id: 'health',
      name: 'health',
      displayName: 'Health',
      icon: Icons.health_and_safety,
      color: Colors.red,
    ),
    NewsCategory(
      id: 'science',
      name: 'science',
      displayName: 'Science',
      icon: Icons.science,
      color: Colors.teal,
    ),
    NewsCategory(
      id: 'entertainment',
      name: 'entertainment',
      displayName: 'Entertainment',
      icon: Icons.movie,
      color: Colors.pink,
    ),
  ];

  static NewsCategory getCategoryById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => categories.first,
    );
  }
}
