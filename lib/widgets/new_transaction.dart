import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewTransaction extends StatefulWidget {
  final Function addTransaction;
  const NewTransaction({Key? key, required this.addTransaction})
      : super(key: key);

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 350,
        color: const Color.fromRGBO(255, 255, 255, 1),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                child: child,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CupertinoButton(
                    child: const Text('done'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _presentDatePicker() {
    if (Platform.isIOS) {
      _showDialog(
        CupertinoDatePicker(
          initialDateTime: DateTime.now(),
          minimumDate: DateTime(2019),
          maximumDate: DateTime.now(),
          mode: CupertinoDatePickerMode.date,
          use24hFormat: true,
          // This is called when the user changes the date.
          onDateTimeChanged: (DateTime newDate) {
            setState(() => _selectedDate = newDate);
          },
        ),
      );
    } else {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2019),
        lastDate: DateTime.now(),
      ).then((pickedDate) {
        if (pickedDate == null) {
          return;
        }

        setState(() {
          _selectedDate = pickedDate;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              controller: _titleController,
            ),
            TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                controller: _amountController),
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date Picked: ${DateFormat.yMd().format(_selectedDate)}',
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'choose date',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (Platform.isIOS) ...[
              CupertinoButton(
                onPressed: () {
                  var title = _titleController.text;
                  var amount = double.parse(_amountController.text);
                  if (title.isEmpty || amount <= 0) return;

                  widget.addTransaction(
                    title,
                    amount,
                    _selectedDate,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Add transaction'),
              )
            ],
            if (!Platform.isIOS) ...[
              TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 25.0,
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.purple),
                ),
                child: const Text(
                  'Add Transaction ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  var title = _titleController.text;
                  var amount = double.parse(_amountController.text);
                  if (title.isEmpty || amount <= 0) return;

                  widget.addTransaction(
                    title,
                    amount,
                    _selectedDate,
                  );
                  Navigator.of(context).pop();
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}
