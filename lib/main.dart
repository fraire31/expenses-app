import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './models/transaction.dart';
import './widgets/chart.dart';
import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense App',
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            fontSize: 20.0,
          ),
        ),
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showChart = false;
  final List<Transaction> _transactions = [];

  List<Transaction> get _recentTransactions {
    return _transactions.where((transaction) {
      return transaction.date.isAfter(
        DateTime.now().subtract(
          const Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTransaction = Transaction(
      DateTime.now().toString(),
      txTitle,
      txAmount,
      chosenDate,
    );

    setState(() {
      _transactions.add(newTransaction);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((transaction) => transaction.id == id);
    });
  }

  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Platform.isIOS
          ? const Color.fromRGBO(250, 250, 250, 1)
          : Colors.white,
      shape: Platform.isAndroid
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10.0),
              ),
            )
          : null,
      context: context,
      builder: (_) {
        return NewTransaction(addTransaction: _addNewTransaction);
      },
    );
  }

  Widget _topContainer(MediaQueryData mediaQuery, appBar, size) {
    return SizedBox(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          size,
      child: Chart(_recentTransactions),
    );
  }

  PreferredSizeWidget _appBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text(
              'Expense App',
              style: TextStyle(
                color: Colors.purple,
              ),
            ),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  child: const Icon(
                    CupertinoIcons.add,
                    color: Colors.purple,
                    // color: Colors.white,
                  ),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          ) as PreferredSizeWidget
        : AppBar(
            title: const Text(
              'Expense App',
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _startAddNewTransaction(context);
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final transactionListWidget = SizedBox(
      height: (mediaQuery.size.height -
              _appBar().preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(
          transactions: _transactions, deleteTransaction: _deleteTransaction),
    );

    final body = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show Chart',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Switch.adaptive(
                    activeColor: Theme.of(context).primaryColor,
                    value: _showChart,
                    onChanged: (value) {
                      setState(
                        () {
                          _showChart = value;
                        },
                      );
                    },
                  ),
                ],
              ),
            if (!isLandscape) _topContainer(mediaQuery, _appBar(), 0.3),
            const Text(
              'The chart shows expenses from the past week.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            if (!isLandscape) transactionListWidget,
            if (isLandscape)
              _showChart
                  ? _topContainer(mediaQuery, _appBar(), 0.5)
                  : transactionListWidget,
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: _appBar(),
      body: body,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                _startAddNewTransaction(context);
              },
              child: const Icon(Icons.add),
              backgroundColor: Theme.of(context).primaryColor,
            ),
    );
  }
}

// Platform.isIOS
//   ? CupertinoPageScaffold(
//       child: body,
//       navigationBar: appBar,
//     )
//   : Scaffold(
//       appBar: appBar,
//       body: body,
//       floatingActionButton: Platform.isIOS
//           ? Container()
//           : FloatingActionButton(
//               onPressed: () {
//                 _startAddNewTransaction(context);
//               },
//               child: Icon(Icons.add),
//               backgroundColor: Theme.of(context).primaryColor,
//             ),
//     );
