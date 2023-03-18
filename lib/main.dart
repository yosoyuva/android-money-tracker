import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> _clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> main() async {
  // Clear SharedPreferences before running the app
  //await _clearSharedPreferences();

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
  double goal = 1000.0;
  double currentAmount = 0.0;
  TextEditingController amountController = TextEditingController();
  TextEditingController goalController = TextEditingController();

  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    //_loadAndHandleData();
  }

  Future<void> _loadAndHandleData() async {
    await _loadData();
    if (goal == 800.0 && currentAmount == 0.0) {
      await _showGoalDialog();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDialogShown) {
      _isDialogShown = true;
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await _loadData();
        if (goal == 800.0 && currentAmount == 0.0) {
          _showGoalDialog();
        }
      });
    }
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      goal = prefs.getDouble('goal') ?? 800.0;
      currentAmount = prefs.getDouble('currentAmount') ?? 0.0;
    });
    if (goal == 0.0) {
    _showGoalDialog();
  }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('goal', goal);
    prefs.setDouble('currentAmount', currentAmount);
    prefs.setString('goalDate', DateTime.now().toString());
  }

  Future<void> _showGoalDialog() async {
    await showDialog(
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
                  _saveData();
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Set goal'),
            ),
          ],
        );
      },
    );
    _isDialogShown = true;
  }

  void _resetAmounts() {
    setState(() {
      goal = 0.0;
      currentAmount = 0.0;
    });
    _saveData();
    _showGoalDialog();
  }

  Future<String> _getTimeLeft() async {
    Duration goalDuration = Duration(days: 30);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('goalDate')) {
      DateTime goalDate = DateTime.parse(prefs.getString('goalDate')!);
      DateTime targetDate = goalDate.add(goalDuration);
      Duration timeLeft = targetDate.difference(DateTime.now());
      return '${timeLeft.inDays} days';
    }

    return 'N/A';
  }

  Future<String> _getGoalDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('goalDate')) {
     return prefs.getString('goalDate')!;
   }
    return 'N/A';
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
        
        FutureBuilder<String>(
          future: _getGoalDate(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Goal Date: ${snapshot.data}');
            } else {
              return Text('Goal Date: N/A');
            }
          },
        ),
        FutureBuilder<String>(
          future: _getTimeLeft(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Time left: ${snapshot.data}');
            } else {
              return Text('Time left: N/A');
            }
          },
        ),


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
            _saveData();
            amountController.clear(); // Clear the text in the amountController
          },
          child: Text('Add amount'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetAmounts,
          child: Text('Reset Amounts'),
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