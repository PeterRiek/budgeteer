class Data {
  List<String> accounts;
  List<Transaction> transactions;

  Data({
    required this.accounts,
    required this.transactions,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      accounts: List<String>.from(json['accounts']),
      transactions: (json['transactions'] as List<dynamic>)
          .map((item) => Transaction.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accounts': accounts,
      'transactions':
          transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }
}

class Transaction {
  String account;
  double amount;
  String title;
  String description;
  List<String> tags;
  String date;

  Transaction({
    required this.account,
    required this.amount,
    required this.title,
    required this.description,
    required this.tags,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      account: json['account'],
      amount: json['amount'],
      title: json['title'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'title': title,
      'description': description,
      'tags': tags,
      'date': date,
    };
  }
}
