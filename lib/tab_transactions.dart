import 'package:flutter/material.dart';

import 'main.dart';
import 'model.dart';

const dataFilename = 'data.json';

class TabScreenTransactions extends StatefulWidget {
  const TabScreenTransactions({super.key});

  @override
  State<TabScreenTransactions> createState() => _TabScreenTransactionsState();
}

class _TabScreenTransactionsState extends State<TabScreenTransactions> {
  /* */
  List<Transaction> _transactions = [];

  Future<void> _loadData() async {
    _transactions = await DataManager.loadTransactions(dataFilename);
    setState(() {});
  }

  Future<void> _saveData() async {
    await DataManager.saveTransactions(dataFilename, _transactions);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions Overview'),
      ),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return GestureDetector(
            child: Card(
              child: ListTile(
                title: Text(transaction.title),
                subtitle: Text(transaction.description),
              ),
            ),
            onTap: () {
              _editTransaction(index);
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 100,
        height: 60,
        child: FloatingActionButton(
          onPressed: _addTransaction,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  _addTransaction() async {
    showDialog(
      context: context,
      builder: (context) {
        return AddTransactionDialog(
          onSave: (transaction) {
            setState(() {
              _transactions.add(transaction);
            });
            _saveData();
          },
        );
      },
    );
  }

  _editTransaction(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return EditTransactionDialog(
          transaction: _transactions[index],
          onSave: (transaction) {
            setState(() {
              _transactions[index] = transaction;
            });
            _saveData();
          },
          onDelete: () {
            setState(() {
              _transactions.removeAt(index);
            });
            _saveData();
          },
        );
      },
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(Transaction) onSave;

  const AddTransactionDialog({Key? key, required this.onSave})
      : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController tagsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedAccount = 'Bargeld'; // TODO: default

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Transaction'),
      content: Container(
        width: 300,
        height: 350,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
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
                      onChanged: (String? selectedAccount) {
                        setState(() {
                          _selectedAccount = selectedAccount!;
                        });
                      },
                      items: [
                        // TODO: load list
                        DropdownMenuItem(
                          value: 'VR Giro',
                          child: Text('VR Giro'),
                        ),
                        DropdownMenuItem(
                          value: 'DKB Tagesgeld',
                          child: Text('DKB Tagesgeld'),
                        ),
                        DropdownMenuItem(
                          value: 'DKB Giro',
                          child: Text('DKB Giro'),
                        ),
                        DropdownMenuItem(
                          value: 'PayPal',
                          child: Text('PayPal'),
                        ),
                        DropdownMenuItem(
                          value: 'Bargeld',
                          child: Text('Bargeld'),
                        ),
                        DropdownMenuItem(
                          value: 'ABCDEFGHIJKLMNOP',
                          child: Text('ABCDEFGHIJKLMN'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Date: ${'${_selectedDate.toLocal()}'.split(' ')[0]}'),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(Transaction(
              account: _selectedAccount,
              amount: double.tryParse(amountController.text) ?? 0,
              title: titleController.text,
              description: descriptionController.text,
              tags:
                  tagsController.text.split(',').map((e) => e.trim()).toList(),
              date: DateTime.now().toString(),
            ));
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction) onSave;
  final Function() onDelete;

  const EditTransactionDialog({
    Key? key,
    required this.transaction,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController amountController;
  late TextEditingController tagsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.transaction.title);
    descriptionController =
        TextEditingController(text: widget.transaction.description);
    amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    tagsController =
        TextEditingController(text: widget.transaction.tags.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Transaction'),
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            controller: tagsController,
            decoration: InputDecoration(labelText: 'Tags (comma-separated)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(Transaction(
              account: widget.transaction.account,
              amount: double.tryParse(amountController.text) ?? 0,
              title: titleController.text,
              description: descriptionController.text,
              tags:
                  tagsController.text.split(',').map((e) => e.trim()).toList(),
              date: widget.transaction.date,
            ));
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () {
            widget.onDelete();
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Delete'),
        ),
      ],
    );
  }
}
