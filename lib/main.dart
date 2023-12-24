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
    const TabScreenProfile(),
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
  static Future<Data> getData(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final String filepath = '${directory.path}/$filename';
    File file = File(filepath);
    String rawdata = await file.readAsString();
    final Map<String, dynamic> jsonData = json.decode(rawdata);
    return Data.fromJson(jsonData);
  }

  static Future<List<Transaction>> loadTransactions(String filename) async {
    Data data = await getData(filename);
    return data.transactions;
  }

  static Future<void> saveData(String filename, Data data) async {
    final List<Map<String, dynamic>> jsonList =
        data.transactions.map((item) => item.toJson()).toList();

    final Map<String, dynamic> jsonData = {
      'accounts': data.accounts,
      'transactions': jsonList,
    };
    final String jsonString = json.encode(jsonData);

    final directory = await getApplicationDocumentsDirectory();
    final String filepath = '${directory.path}/$filename';
    print('Saved data\n$jsonData\n[in file: $filepath].');
    await File(filepath).writeAsString(jsonString);
  }

  static Future<void> saveTransactions(
      String filename, List<Transaction> transactions) async {
    Data data = await getData(filename);
    data.transactions = transactions;
    saveData(filename, data);
  }
}
