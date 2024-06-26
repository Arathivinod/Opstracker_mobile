import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opstracker/compliance/time_report/blocs/defaulters_bloc.dart';
import 'package:opstracker/compliance/time_report/models/defaulters_model.dart';

class TimeReportScreen extends StatelessWidget {
  const TimeReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DefaultersBloc(),
      child: const TimeReportScreenBody(),
    );
  }
}

class TimeReportScreenBody extends StatefulWidget {
  const TimeReportScreenBody({Key? key}) : super(key: key);

  @override
  _TimeReportScreenBodyState createState() => _TimeReportScreenBodyState();
}

class _TimeReportScreenBodyState extends State<TimeReportScreenBody> {
  late DefaultersBloc _defaultersBloc;
  String _selectedOption = 'Today'; // Default selected option

  @override
  void initState() {
    super.initState();
    _defaultersBloc = BlocProvider.of<DefaultersBloc>(context);
    // Fetch data for the default selected option
    _fetchDataForSelectedOption();
  }

  void _fetchDataForSelectedOption() {
    // Get today's date
    DateTime now = DateTime.now();
    // Format today's date in 'yyyy-MM-dd' format
    String todayDate =
        '${now.year}-${_formatDateValue(now.month)}-${_formatDateValue(now.day)}';
    String monthStartDate = DateFormat('yyyy-MM-dd')
        .format(DateTime(DateTime.now().year, DateTime.now().month, 01));
    String mondayOfCurrentWeek =
        '${now.subtract(Duration(days: now.weekday - 1)).year}-${_formatDateValue(now.subtract(Duration(days: now.weekday - 1)).month)}-${_formatDateValue(now.subtract(Duration(days: now.weekday - 1)).day)}';

    // Based on the selected option, fetch data accordingly
    switch (_selectedOption) {
      case 'Today':
        _defaultersBloc.add(FetchDefaultersEvent(
            startDate: todayDate, endDate: todayDate, buId: 51));
        break;
      case 'Week':
        _defaultersBloc.add(FetchDefaultersEvent(
            startDate: mondayOfCurrentWeek, endDate: todayDate, buId: 51));
        break;
      case 'Month':
        _defaultersBloc.add(FetchDefaultersEvent(
            startDate: monthStartDate, endDate: todayDate, buId: 51));
        break;
    }
  }

  String _formatDateValue(int value) {
    // Formats the date value with leading zero if it's a single digit
    return value < 10 ? '0$value' : '$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Defaulters list'),
        actions: [
          DropdownButton<String>(
            value: _selectedOption,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedOption = newValue;
                });
                _fetchDataForSelectedOption(); // Fetch data when option changes
              }
            },
            items: <String>['Today', 'Week', 'Month']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: BlocBuilder<DefaultersBloc, DefaultersState>(
        builder: (context, state) {
          if (state is DefaultersLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DefaultersLoadedState) {
            return _buildDefaultersList(state.defaulters);
          } else if (state is DefaultersErrorState) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }

  Widget _buildDefaultersList(List<Defaulter> defaulters) {
    // Sort the defaulters list alphabetically by name
    defaulters.sort((a, b) => a.name.compareTo(b.name));

    return ListView.builder(
      itemCount: defaulters.length,
      itemBuilder: (context, index) {
        final defaulter = defaulters[index];
        return ListTile(
          title: Text(defaulter.name),
          subtitle: Text('Emp ID: ${defaulter.empId}'),
          onTap: () {
            _showMissedDatesBottomSheet(context, defaulter.missedDates);
          },
        );
      },
    );
  }

  void _showMissedDatesBottomSheet(
      BuildContext context, List<DateTime> missedDates) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${missedDates.length} Missed Dates',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: missedDates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        DateFormat('dd/MM/yyyy').format(missedDates[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
