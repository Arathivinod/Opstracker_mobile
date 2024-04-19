import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opstracker/compliance/time_report/models/defaulters_model.dart';
import 'package:opstracker/constants/api_constants.dart';

class DefaultersService {
  Future<List<Defaulter>> fetchDefaulters(
      {required String startDate,
      required String endDate,
      required int buId}) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.defaultersReport}'),
      body: json
          .encode({"startDate": startDate, "endDate": endDate, "buId": buId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJBVVRIRU5USUNBVElPTiAmIEFVVEhPUklaQVRJT04iLCJPUkctSUQiOjEsImlzcyI6Imh0dHA6Ly93d3cua3Jvbm9zLmlkYy50YXJlbnRvLmNvbSIsIlVTRVItSUQiOjExNDQsImV4cCI6MTcxMzQ0MjM0OCwiaWF0IjoxNzEzMTgzMTQ4LCJST0xFLUlEIjoxfQ.ps9-0QiqKwwB3o3J3Y6h9Ry_smsGIH8iBLW9chOHP0I'
      },
    );

    // Print a message indicating whether the response is received or not
    if (response.statusCode == 200) {
      print('Response received successfully.');
      print(response.body);
    } else {
      print('Failed to receive response. Status code: ${response.statusCode}');
    }

    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body)['responseData'];
      print(responseData);
      List<Defaulter> defaulters =
          responseData.map((data) => Defaulter.fromJson(data)).toList();
      return defaulters;
    } else {
      throw Exception('Failed to load defaulters');
    }
  }
}
