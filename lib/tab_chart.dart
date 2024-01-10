import 'package:budgeteer/main.dart';
import 'dart:math';
import 'package:budgeteer/model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const dataFilename = 'dt.json';

class TabScreenChart extends StatefulWidget {
  const TabScreenChart({super.key});

  @override
  State<TabScreenChart> createState() => _TabScreenChartState();
}

class _TabScreenChartState extends State<TabScreenChart> {
  late List<String> _accountList;
  late String _selectedAccount;

  Future<void> _loadAccounts() async {
    try {
      _accountList = await DataManager.loadAccounts(dataFilename);
      _selectedAccount = _accountList.isNotEmpty ? _accountList[0] : '';

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      print('Error loading accounts: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    _accountList = [];
    _selectedAccount = '';
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chart')),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton<String>(
              padding: EdgeInsets.all(4.0),
              alignment: Alignment.center,
              underline: SizedBox(),
              value: _selectedAccount,
              items: _accountList.map((String account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value ?? 'None';
                });
              },
            ),
          ),
          SizedBox(height: 12.0),
          Expanded(
            child: AccountBalanceChart(
              accountName: _selectedAccount,
              filename: dataFilename,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountBalanceChart extends StatelessWidget {
  final String accountName;
  final String filename; // File name to store data

  AccountBalanceChart({required this.accountName, required this.filename});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: DataManager.loadTransactions(filename),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No transactions available'));
        } else {
          List<Transaction> transactions = snapshot.data!;
          List<Transaction> accountTransactions = transactions
              .where((transaction) => transaction.account == accountName)
              .toList();

          if (accountTransactions.isEmpty) {
            return Center(
                child: Text('No transactions available for this account'));
          }

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((LineBarSpot touchedSpot) {
                        var transaction =
                            accountTransactions[touchedSpot.spotIndex];
                        var date = DateTime.parse(transaction.date);
                        var amount = transaction.amount;
                        var title = transaction.title;
                        var formattedDate =
                            '${'${date.day}'.padLeft(2, '0')}.${'${date.month}'.padLeft(2, '0')}.${date.year}';
                        return LineTooltipItem(
                          '${amount.toStringAsFixed(2)} €\n$formattedDate\n$title',
                          TextStyle(),
                        );
                      }).toList();
                    },
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
                maxY: _getTopBalance(accountTransactions).isFinite
                    ? _getTopBalance(accountTransactions) * 1.25
                    : 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(accountTransactions),
                    isCurved: false,
                    dotData: FlDotData(
                      show: false,
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles:
                      AxisTitles(sideTitles: _getBottomTitles(transactions)),
                  leftTitles: AxisTitles(sideTitles: _getLeftTitles()),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  SideTitles _getLeftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 50,
      getTitlesWidget: (value, meta) {
        return Text(
          '$value €',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        );
      },
    );
  }

  SideTitles _getBottomTitles(List<Transaction> transactions) {
    return SideTitles(
      showTitles: true,
      reservedSize: 50,
      getTitlesWidget: (value, meta) {
        var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
        var text =
            '${'${date.day}'.padLeft(2, '0')}.${'${date.month}'.padLeft(2, '0')}.   ';
        return Transform.rotate(
          angle: -pi * 0.4,
          child: Text(text),
        );
      },
    );
  }

  List<FlSpot> _generateSpots(List<Transaction> transactions) {
    List<FlSpot> spots = [];
    double balance = 0;

    for (var transaction in transactions) {
      balance += transaction.amount;
      var date = DateTime.parse(transaction.date);
      spots.add(FlSpot(date.millisecondsSinceEpoch.toDouble(), balance));
    }
    return spots;
  }

  double _getTopBalance(List<Transaction> transactions) {
    double balance = 0;
    double top = double.negativeInfinity;
    for (var transaction in transactions) {
      balance += transaction.amount;
      if (balance > top) top = balance;
    }
    return top;
  }
}
