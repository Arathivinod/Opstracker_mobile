import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opstracker/compliance/time_report/blocs/defaulters_bloc.dart';
import 'package:opstracker/compliance/time_report/models/defaulters_model.dart';

class TimeReportScreen extends StatelessWidget {
  const TimeReportScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DefaultersBloc(),
      child: TimeReportScreenBody(),
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

  @override
  void initState() {
    super.initState();
    _defaultersBloc = BlocProvider.of<DefaultersBloc>(context);
    // Get today's date
    DateTime now = DateTime.now();

    // Format today's date in 'yyyy-MM-dd' format
    String todayDate =
        '${now.year}-${_formatDateValue(now.month)}-${_formatDateValue(now.day)}';

    _defaultersBloc.add(FetchDefaultersEvent(
      startDate: todayDate,
      endDate: todayDate,
      buId: 51, // Replace with actual buId
    ));
  }

  String _formatDateValue(int value) {
    // Formats the date value with leading zero if it's a single digit
    return value < 10 ? '0$value' : '$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Defaulters Report'),
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
    return ListView.builder(
      itemCount: defaulters.length,
      itemBuilder: (context, index) {
        final defaulter = defaulters[index];
        return ListTile(
          title: Text(defaulter.name),
          subtitle: Text(defaulter.empId),
        );
      },
    );
  }
}
