// lib/screens/my_reports_screen.dart

import 'package:flutter/material.dart';
import '../api/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _apiService.getMyReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rapports'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          // --- Cas 1: Chargement ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- Cas 2: Erreur ---
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          // --- Cas 3: Succès ---
          if (snapshot.hasData) {
            final reports = snapshot.data!;
            if (reports.isEmpty) {
              return const Center(
                child: Text(
                  'Vous n\'avez encore soumis aucun rapport.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            // Affiche la liste des rapports
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  leading: const Icon(Icons.location_pin, color: Colors.teal),
                  title: Text('Rapport du ${report['created_at']}'), // Simplifié pour l'exemple
                  subtitle: Text('Status: ${report['status']}'),
                  trailing: Icon(
                    report['status'] == 'Resolved' ? Icons.check_circle : Icons.hourglass_top,
                    color: report['status'] == 'Resolved' ? Colors.green : Colors.orange,
                  ),
                );
              },
            );
          }
          // Cas par défaut
          return const Center(child: Text('Aucune donnée à afficher.'));
        },
      ),
    );
  }
}