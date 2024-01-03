import 'package:budgeteer/main.dart';
import 'package:budgeteer/model.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

const dataFilename = 'dt.json';


class Util {
  static void showPopupMessage(BuildContext context, String message) {
    // Display a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // Adjust the duration as needed
      ),
    );
  }
}

class TabScreenAccounts extends StatefulWidget {
  const TabScreenAccounts({Key? key}) : super(key: key);

  @override
  State<TabScreenAccounts> createState() => _TabScreenAccountsState();
}

class _TabScreenAccountsState extends State<TabScreenAccounts> {
  List<String> _accountList = [];
  Map<String, double> _accountBalances = {};

  Future<void> _loadBalances() async {
    for (var account in _accountList) {
      _accountBalances[account] =
          await DataManager.getAccountBalance(dataFilename, account);
    }
  }

  Future<void> _loadAccounts() async {
    _accountList = await DataManager.loadAccounts(dataFilename);
    _loadBalances();
    setState(() {});
  }

  Future<void> _saveAccounts() async {
    await DataManager.saveAccounts(dataFilename, _accountList);
  }

  void _addAccount() async {
    showDialog(
        context: context,
        builder: (context) {
          return AddAccountDialog(onSave: (account) {
            if (_accountList.contains(account)) {
              Util.showPopupMessage(context, 'An account with that name already exists!');
              return -1;
            }
            setState(() {
              _accountList.add(account);
            });
            _saveAccounts();
          });
        });
  }

  void _editAccount(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return EditAccountDialog(
          account: _accountList[index],
          onSave: (account) {
            if (_accountList.contains(account)) {
              Util.showPopupMessage(context, 'An account with that name already exists!');
              return;
            }
            setState(() {
              _accountList[index] = account;
            });
            _saveAccounts();
          },
          onDelete: () {
            setState(() {
              _accountList.removeAt(index);
            });
            _saveAccounts();
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Accounts Overview'),
        ),
        body: ListView.builder(
          itemCount: _accountList.length,
          itemBuilder: (context, index) {
            final account = _accountList[index];
            return GestureDetector(
              onTap: () => _editAccount(index),
              child: Card(
                child: ListTile(
                  title: Text(account),
                  subtitle: Text(
                    '${(_accountBalances[account] ?? 0.0).toStringAsFixed(2)} €',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: (_accountBalances[account] ?? 0.0) < 0
                          ? Colors.red
                          : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: SizedBox(
          child: FloatingActionButton(
            onPressed: _addAccount,
            child: const Icon(Icons.add),
          ),
        ));
  }
}

class AddAccountDialog extends StatefulWidget {
  final Function(String) onSave;

  const AddAccountDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  late TextEditingController accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Account'),
      content: Container(
        width: 300,
        height: 200,
        child: TextField(
          controller: accountNameController,
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
            widget.onSave(accountNameController.text);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class EditAccountDialog extends StatefulWidget {
  final String account;
  final Function(String) onSave;
  final Function() onDelete;

  const EditAccountDialog({
    Key? key,
    required this.account,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  late TextEditingController accountNameController;

  @override
  void initState() {
    super.initState();
    accountNameController = TextEditingController(text: widget.account);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Account'),
      content: Container(
        width: 300,
        height: 200,
        child: TextField(
          controller: accountNameController,
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
            widget.onSave(accountNameController.text);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class DuplicateDialog extends StatelessWidget {
  const DuplicateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Understood.'))
      ],
    );
  }
}
