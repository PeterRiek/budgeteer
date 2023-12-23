import 'dart:convert';
import 'dart:io';

import 'package:budgeteer/model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'tab_account.dart';
import 'tab_chart.dart';
import 'tab_transactions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const TabScreenTransactions(),
    const TabScreenChart(),
    const TabScreenAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ssid_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}

class DataManager {
    static Future<List<Transaction>> loadData(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$filename';
    File file = File(filePath);
    String data = await file.readAsString();
    final List<dynamic> jsonData = json.decode(data);
    return jsonData.map((item) => Transaction.fromJson(item)).toList();
  }

  static Future<void> saveData(String filename, List<Transaction> transactions) async {
    final List<Map<String, dynamic>> jsonList =
        transactions.map((item) => item.toJson()).toList();
    final String jsonData = json.encode(jsonList);
    final directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$filename';
    print('Saved data\n$jsonData\n[in file: $filePath].');
    await File(filePath).writeAsString(jsonData);
  }
}