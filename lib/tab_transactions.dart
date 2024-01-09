import 'package:budgeteer/main.dart';
import 'package:budgeteer/model.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';


const dataFilename = 'dt.json';

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
                subtitle: Text(transaction.date.split(' ')[0]),
                trailing: Row(
                  mainAxisSize: MainAxisSize
                      .min, // NOTE: without this row would kinda overlap complete listtile
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.deepPurple[300]),
                      child: Text(transaction.account),
                    ),
                    VerticalDivider(),
                    Container(
                      width: 90,
                      alignment: Alignment.center,
                      child: Text(
                        '${transaction.amount.toStringAsFixed(2)} €',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: transaction.amount < 0 ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
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
  late TextEditingController titleController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController amountController = TextEditingController();
  late TextfieldTagsController tagsController = TextfieldTagsController();

  late DateTime _selectedDate;
  late List<String> _accountList;
  late String _selectedAccount;
  late List<String> _tagList;
  late double _tagsFieldDist;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tagsFieldDist = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    amountController = TextEditingController();
    tagsController = TextfieldTagsController();

    _selectedDate = DateTime.now();
    _selectedAccount = '';
    _accountList = [];
    _tagList = [];
    _loadAccounts();
  }

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
                      items: _accountList.map((String account) {
                        return DropdownMenuItem(
                          value: account,
                          child: Text(account),
                        );
                      }).toList(),
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
                  child: Text(
                      'Date: ${'${_selectedDate.toLocal()}'.split(' ')[0]}'),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: TextFieldTags(
                    textfieldTagsController: tagsController,
                    initialTags: _tagList,
                    textSeparators: const [' ', ','],
                    letterCase: LetterCase.normal,
                    inputfieldBuilder:
                        (context, tec, fn, error, onChanged, onSubmitted) {
                      return ((context, sc, tags, onTagDelete) {
                        return TextField(
                          controller: tec,
                          focusNode: fn,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                            isDense: true,
                            hintText:
                                tagsController.hasTags ? '' : 'Enter tag...',
                            errorText: error,
                            prefixIconConstraints: BoxConstraints(
                                maxWidth: _tagsFieldDist *
                                    (fn.hasFocus ? 0.40 : 0.57)),
                            prefixIcon: SingleChildScrollView(
                              controller: sc,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: tags.map((String tag) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Text('$tag'),
                                          onTap: () {
                                            print('$tag selected');
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel_outlined,
                                            size: 20.0,
                                          ),
                                          onTap: () {
                                            onTagDelete(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                        );
                      });
                    },
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
              tags: tagsController.getTags!,
              date: _selectedDate.toString(),
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
  late TextfieldTagsController tagsController;

  late DateTime _selectedDate;
  late List<String> _accountList;
  late String _selectedAccount;
  late List<String> _tagList;
  late double _tagsFieldDist;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tagsFieldDist = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.transaction.title);
    descriptionController =
        TextEditingController(text: widget.transaction.description);
    amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    tagsController = TextfieldTagsController();

    _selectedDate = DateTime.parse(widget.transaction.date);
    _selectedAccount = '';
    _accountList = [];
    _tagList = widget.transaction.tags;
    _loadAccounts();
  }

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
                      items: _accountList.map((String account) {
                        return DropdownMenuItem(
                          value: account,
                          child: Text(account),
                        );
                      }).toList(),
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
                  child: Text(
                      'Date: ${'${_selectedDate.toLocal()}'.split(' ')[0]}'),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: TextFieldTags(
                    textfieldTagsController: tagsController,
                    initialTags: _tagList,
                    textSeparators: const [' ', ','],
                    letterCase: LetterCase.normal,
                    inputfieldBuilder:
                        (context, tec, fn, error, onChanged, onSubmitted) {
                      return ((context, sc, tags, onTagDelete) {
                        return TextField(
                          controller: tec,
                          focusNode: fn,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(0.0),
                            isDense: true,
                            hintText:
                                tagsController.hasTags ? '' : 'Enter tag...',
                            errorText: error,
                            prefixIconConstraints: BoxConstraints(
                                maxWidth: _tagsFieldDist *
                                    (fn.hasFocus ? 0.40 : 0.57)),
                            prefixIcon: SingleChildScrollView(
                              controller: sc,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: tags.map((String tag) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Text('$tag'),
                                          onTap: () {
                                            print('$tag selected');
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel_outlined,
                                            size: 20.0,
                                          ),
                                          onTap: () {
                                            onTagDelete(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                        );
                      });
                    },
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
            widget.onDelete();
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Delete'),
        ),
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
              tags: tagsController.getTags!,
              date: _selectedDate.toString(),
            ));
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
