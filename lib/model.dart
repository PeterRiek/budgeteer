
class ListItem {
  final String title;
  final String subtitle;

  ListItem({required this.title, required this.subtitle});

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(title: json['title'], subtitle: json['subtitle']);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
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
