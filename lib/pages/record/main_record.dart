import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MainRecord extends StatefulWidget {
  const MainRecord({super.key});

  @override
  _MainRecordState createState() => _MainRecordState();
}

class _MainRecordState extends State<MainRecord> {
  final String titleText = 'Record Your Day';
  final String buttonText1 = 'Single Turn Mode';
  final String buttonText2 = 'Create a New Entry (Multi-Turn Mode)';

  DateTime _selectedDate = DateTime.now();
  bool _showDatePicker = false;

  void _toggleDatePicker() {
    setState(() {
      _showDatePicker = !_showDatePicker;
    });
  }

  void _onDateSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedDate = args.value;
      _showDatePicker = false; // Hide the date picker after selection
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(_selectedDate);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Record for: ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _toggleDatePicker,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      child: Text(
                        formattedDate == DateFormat('MMMM dd, yyyy').format(DateTime.now())
                            ? 'Today'
                            : formattedDate,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                  
                ),
                
                
                if (_showDatePicker)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: SfDateRangePicker(
                        initialSelectedDate: _selectedDate,
                        selectionMode: DateRangePickerSelectionMode.single,
                        onSelectionChanged: _onDateSelectionChanged,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          todayTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                        ),
                        headerStyle: DateRangePickerHeaderStyle(
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                        selectionTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        selectionColor: Theme.of(context).colorScheme.primary,
                        showNavigationArrow: true,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/recorder/st/start',
                        arguments: _selectedDate,
                      );
                    },
                    child: Text(buttonText1),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/recorder/mt/start',
                        arguments: _selectedDate,
                      );
                    },
                    child: Text(buttonText2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
