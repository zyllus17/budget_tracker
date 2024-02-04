import 'package:budget_tracker/model/failure_model.dart';
import 'package:budget_tracker/model/item_model.dart';
import 'package:budget_tracker/repository/budget_repository.dart';
import 'package:budget_tracker/spending_chart_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    _futureItems = BudgetRepository().getItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Budget Tracker'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _futureItems = BudgetRepository().getItems();
            setState(() {});
          },
          child: FutureBuilder<List<Item>>(
            future: _futureItems,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return SpendingChart(items: items);
                    final item = items[index - 1];
                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 2,
                          color: getCategoryColor(item.category),
                        ),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6)
                        ],
                      ),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.category} . ${DateFormat.yMd().format(item.date)}',
                        ),
                        trailing: Text(
                          '-\$${item.price.toStringAsFixed(2)}',
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                final failure = snapshot.error as Failure;
                return Center(child: Text(failure.message));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Entertainment':
      return Colors.red[400]!;
    case 'Food':
      return Colors.green[400]!;
    case 'Personal':
      return Colors.blue[400]!;
    case 'Transportation':
      return Colors.purple[400]!;
    default:
      return Colors.orange[400]!;
  }
}
