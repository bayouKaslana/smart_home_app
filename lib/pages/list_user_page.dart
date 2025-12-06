import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List users = [];
  bool loading = true;

  Future<void> fetchUsers() async {
    try {
      final url = Uri.parse("http://10.180.109.72:8080/api/users"); // Ganti IP
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F10),
      appBar: AppBar(
        title: const Text("List User", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : users.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada user terdaftar",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return Card(
                      color: const Color(0xff1E1E1E),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.badge, color: Colors.blueGrey),
                        title: Text(
                          u['name'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        subtitle: Text(
                          "UID: ${u['uid']}",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
