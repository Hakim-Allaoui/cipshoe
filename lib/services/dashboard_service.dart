import 'package:cipshoe/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

/// Service to handle dashboard-related functionality and determine when to show web view
class DashboardService {
  static const String _webViewKey = 'show_web_view_flag';
  static const String _webViewUrlKey = 'web_view_url';
  static const String _lastCheckKey = 'last_dashboard_check';
  static const String _defaultWebViewUrl = 'https://pdf.io/';

  /// Determines whether the app should show the web dashboard
  /// Returns true if web dashboard should be shown, false for native UI
  static Future<bool> shouldShowWebView() async {
    try {
      // Get shared preferences instance
      final prefs = await SharedPreferences.getInstance();

      // Check if we need to fetch the latest config
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // If more than 1 minutes since last check, fetch new config
      if (now - lastCheck > 1 * 60 * 1000) {
        return await _fetchDashboardConfig(prefs);
      }

      // Otherwise use cached value
      return prefs.getBool(_webViewKey) ?? false;
    } catch (e) {
      // If anything fails, default to native UI (false)
      print('Error checking dashboard mode: $e');
      return false;
    }
  }

  /// Gets the URL for the web view dashboard
  static Future<String> getWebViewUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_webViewUrlKey) ?? _defaultWebViewUrl;
    } catch (e) {
      print('Error getting web view URL: $e');
      return _defaultWebViewUrl;
    }
  }

  /// Fetches the dashboard configuration from the backend
  static Future<bool> _fetchDashboardConfig(SharedPreferences prefs) async {
    try {
      final response = await http
          .get(Uri.parse(CONFIG_ENDPOINT))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var showWebView = data['showWebView'] ?? false;

        // Extract and save the webViewUrl if present
        if (data['webViewUrl'] != null) {
          await prefs.setString(_webViewUrlKey, data['webViewUrl']);
        }

        // Save the result and update last check time
        await prefs.setBool(_webViewKey, showWebView);
        await prefs.setInt(
            _lastCheckKey, DateTime.now().millisecondsSinceEpoch);

        return showWebView;
      }

      // If request fails, use cached value or default to false
      return prefs.getBool(_webViewKey) ?? false;
    } on SocketException {
      // Handle no internet connection
      return prefs.getBool(_webViewKey) ?? false;
    } catch (e) {
      print('Error fetching dashboard config: $e');
      return prefs.getBool(_webViewKey) ?? false;
    }
  }

  /// Manually set whether to show web dashboard
  static Future<void> setWebViewMode(bool showWebView) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_webViewKey, showWebView);
    } catch (e) {
      print('Error setting web view mode: $e');
    }
  }
}
