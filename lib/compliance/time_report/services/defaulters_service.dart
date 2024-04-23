import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:opstracker/compliance/time_report/models/defaulters_model.dart';
import 'package:opstracker/constants/api_constants.dart';

class DefaultersService {
  Future<Map<String, Map<String, dynamic>>> fetchDefaulters(
      {required String startDate,
      required String endDate,
      required int buId}) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.defaultersReport}'),
      body: json.encode({
        "startDate": startDate,
        "endDate": endDate,
        "buId": buId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJBVVRIRU5USUNBVElPTiAmIEFVVEhPUklaQVRJT04iLCJPUkctSUQiOjEsImlzcyI6Imh0dHA6Ly93d3cua3Jvbm9zLmlkYy50YXJlbnRvLmNvbSIsIlVTRVItSUQiOjExNDQsImV4cCI6MTcxNDExNDkxNSwiaWF0IjoxNzEzODU1NzE1LCJST0xFLUlEIjoxfQ.y897ZLPolIPfAsN_LhaENIU1xpW0ooWvyK6Q0jA03w8'
      },
    );

    if (response.statusCode == 200) {
      // Extract responseData from the response data
      List<dynamic> responseData = json.decode(response.body)['responseData'];

      // Create a map to store missed dates for each userName
      Map<String, Map<String, dynamic>> missedDatesMap = {};

      // Iterate through each item in responseData
      for (var data in responseData) {
        String userName = data['name'];
        String workDateString = data['workDate'];
        String empId = data['empId'];

        // Parse workDate string to DateTime object
        DateTime workDate = DateTime.parse(workDateString);
        // Create a Defaulter object

        // Add workDate to the list associated with the userName
        if (!missedDatesMap.containsKey(userName)) {
          // Add new entry for userName
          missedDatesMap[userName] = {
            'empId': empId,
            'missedDates': [workDate]
          };
        } else {
          // Append missed date to existing userName entry
          missedDatesMap[userName]!['missedDates'].add(workDate);
        }
      }

      // Return the map containing missed dates and empId for each userName
      return missedDatesMap;
    } else {
      // Throw an exception if failed to load defaulters
      throw Exception('Failed to load defaulters');
    }
  }
}
