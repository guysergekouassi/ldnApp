import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/evangile_model.dart';

class AelfApiService {
  static const String _baseUrl = 'https://api.aelf.org/v1';

  Future<List<MesseLecture>> getMesseDuJour() async {
    try {
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final url = Uri.parse('$_baseUrl/messes/$date/romain');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data != null && data['messes'] != null && data['messes'].isNotEmpty) {
          final messe = data['messes'][0];
          
          if (messe['lectures'] != null) {
            final lectures = messe['lectures'] as List;
            return lectures.map((l) => MesseLecture.fromAelf(l)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération de la messe: $e');
      return [];
    }
  }
}
