import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:flutter/material.dart';

class MainTest extends StatefulWidget {
  const MainTest({Key? key}) : super(key: key);

  @override
  State<MainTest> createState() => _MainTestState();
}

class _MainTestState extends State<MainTest> {
  @override
  Widget build(BuildContext context) {
    return SfDateRangePicker();
  }
}