import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CsvParser {
  static Future<List<Map<String, dynamic>>> loadCsv(String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final lines = LineSplitter.split(csvString).toList();
    if (lines.length < 4)
      return []; // Needs at least 3 header lines + 1 data line

    final bodypartsRow = lines[1].split(','); // Second header line (bodyparts)
    final coordsRow = lines[2].split(','); // Third header line (coords)

    final List<String> newHeaders = [];
    // The first column is 'scorer' or frame index, let's call it 'frame_id'
    newHeaders.add(bodypartsRow[0]); // This should be 'scorer'

    // Generate combined headers like 'Nose_x', 'Nose_y', 'Nose_likelihood' etc.
    // Start from index 1 for actual data columns
    for (int i = 1; i < bodypartsRow.length; i++) {
      // Ensure that both rows have corresponding entries
      if (i < coordsRow.length) {
        newHeaders.add('${bodypartsRow[i]}_${coordsRow[i]}');
      } else {
        // Handle cases where coordsRow might be shorter than bodypartsRow
        newHeaders.add('${bodypartsRow[i]}_unknown'); // Fallback or warning
      }
    }

    // Parse data rows starting from the 4th line (index 3)
    return lines.skip(3).map((line) {
      final values = line.split(',');
      // Ensure value count matches header count to prevent errors
      if (values.length != newHeaders.length) {
        print(
          'Warning: Column count mismatch. Expected ${newHeaders.length}, got ${values.length} in line: $line',
        );
        // You might want to skip this line or handle the error differently
        return <String, dynamic>{}; // Return an empty map with explicit type
      }
      return Map<String, dynamic>.fromIterables(newHeaders, values);
    }).toList();
  }
}
