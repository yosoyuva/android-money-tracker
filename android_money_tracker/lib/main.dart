import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Money Goal Tracker')),
        body: MoneyGoalTracker(),
      ),
    );
  }
}

class MoneyGoalTracker extends StatefulWidget {
  @override
  _MoneyGoalTrackerState createState() => _MoneyGoalTrackerState();
}

class _MoneyGoalTrackerState extends State<MoneyGoalTracker> {
  // Implementation will go here
  double goal = 1000.0;
  double currentAmount = 0.0;
  TextEditingController amountController = TextEditingController();
  TextEditingController goalController = TextEditingController();//

  bool _isDialogShown = false; // Add this variable to track if the dialog has been shown

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDialogShown) {
      _isDialogShown = true;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _showGoalDialog();
      });

    }
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set your goal'),
          content: TextField(
            controller: goalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter goal amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                double? newGoal = double.tryParse(goalController.text);
                if (newGoal != null && newGoal > 0.0) {
                  setState(() {
                    goal = newGoal;
                  });
                 Navigator.of(context).pop();
                }
              },
              child: Text('Set goal'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    Color progressColor = Color.lerp(Colors.red, Colors.green, currentAmount / goal)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        VerticalProgressBar(
          value: currentAmount / goal,
          backgroundColor: Colors.grey,
          progressColor: progressColor,
        ),
        SizedBox(height: 20),
        Text('Current progress: \$${currentAmount.toStringAsFixed(2)} / \$${goal.toStringAsFixed(2)}'),
        SizedBox(height: 20),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter amount',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            double newAmount = double.tryParse(amountController.text) ?? 0.0;
            setState(() {
              currentAmount += newAmount;
              if (currentAmount > goal) {
                currentAmount = goal; /// add something like a reward if I exceed goal
              }
            });
            amountController.clear(); // Clear the text in the amountController
          },
          child: Text('Add amount'),
        ),
      ],
    );
  }

}

class VerticalProgressBar extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color progressColor;

  VerticalProgressBar({required this.value, required this.backgroundColor, required this.progressColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 300,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 50,
              height: 300 * value,
              color: progressColor,
            ),
          ),
          Container(
            width: 50,
            height: 300,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.5),
              border: Border.all(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
