import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: Colors.amber[600],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/after_noon.png"),
            fit: BoxFit.cover, // Adjust as needed
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onSubmitted: (value) => Navigator.pop(context, value),
                decoration: const InputDecoration(
                  hintText: 'Enter a location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.search),
                onPressed: () {
                  String location = _searchController.text;
                  Navigator.pop(context, location);
                },
                label: const Text('Search', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
