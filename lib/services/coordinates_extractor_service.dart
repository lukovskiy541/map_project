import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiCoordinatesExtractor {
  final String _apiKey;
  final String _apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  GeminiCoordinatesExtractor({required String apiKey}) : _apiKey = apiKey;

  Future<List<(String? name, String? location, int? quantity)>> extractThreats(
      String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiEndpoint?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
Parse air raid threats and their locations from the alert message: "$message".

Rules:
1. Extract threat type (convert to lowercase):
   - "бпла" for БпЛА, дрон, БПЛА, etc.
   - "ракета" for ракета, ракети, etc.
   - "балістика" for балістична ракета, etc.
   - "калібр" for калібр, калібри, etc.
2. Extract city/town names exactly as written
3. Parse quantity: any number before "х" or explicit count
4. Default quantity to 1 if not specified

Output format (JSON array):
{
"threats": [
  {
    "name": "бпла" | "ракета" | "балістика" | "калібр" | null,
    "location": string,
    "quantity": number | null
  }
]
}

If no threats found, return: {"threats": []}.'''
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        print('API Error: ${response.body}');
        throw Exception('Failed to get response from Gemini API');
      }

      final jsonResponse = jsonDecode(response.body);

      // Validate response structure
      if (!jsonResponse.containsKey('candidates') ||
          jsonResponse['candidates'].isEmpty ||
          !jsonResponse['candidates'][0].containsKey('content') ||
          !jsonResponse['candidates'][0]['content'].containsKey('parts') ||
          jsonResponse['candidates'][0]['content']['parts'].isEmpty) {
        throw Exception('Invalid API response structure');
      }

      final content =
          jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      print(content);
      // Extract the JSON part from the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        return [];
      }

      final parsedJson = jsonDecode(jsonMatch.group(0)!);
      if (!parsedJson.containsKey('threats')) {
        return [];
      }

      // Convert each threat to a tuple with validation
      return (parsedJson['threats'] as List)
          .map<(String? name, String? location, int? quantity)>((threat) {
            // Validate threat object structure
            if (threat is! Map<String, dynamic>) {
              return (null, null, null);
            }

            return (
              (threat['name'] as String?)?.toLowerCase(),
              threat['location'] as String?,
              threat['quantity'] is int
                  ? threat['quantity']
                  : threat['quantity'] is String
                      ? int.tryParse(threat['quantity'])
                      : null,
            );
          })
          .where((threat) =>
              threat.$1 != null || threat.$2 != null || threat.$3 != null)
          .toList();
    } catch (e) {
      print('Error extracting threats: $e');
      return [];
    }
  }
}
