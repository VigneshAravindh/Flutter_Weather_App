import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/pages/home_page.dart';

void main() {
  group('Homepage State Tests', () {
    test('Fetch Weather Data', () async {
      HomepageState homepageState = HomepageState();

      // Replace these coordinates with valid ones for testing
      double latitude = 28.7;
      double longitude = 77.1;

      await homepageState.fetchWeatherData(latitude, longitude);

      print('Actual Value load: ${homepageState.isLoading}\n');
      print('Expected Value load: true\n');
      expect(homepageState.isLoading, true);

      print('Actual Value error: ${homepageState.errorMessage}\n');
      print('Expected Value error: ' '\n');
      expect(homepageState.errorMessage, '');

      print('Actual Value weather: ${homepageState.weather}\n');
      print('Expected Value weather: null\n');
      expect(homepageState.weather, null); // Use the getter here
    });

    test('Fetch Weather by Search', () async {
      HomepageState homepageState = HomepageState();

      // Replace this with a valid location for testing
      String location = 'Delhi';

      await homepageState.fetchWeatherBySearch(location);

      print('Actual Value load: ${homepageState.isLoading}\n');
      print('Expected Value load: true\n');

      expect(homepageState.isLoading, true);

      print('Actual Value error: ${homepageState.errorMessage}\n');
      print('Expected Value error: ' '\n');
      expect(homepageState.errorMessage, '');

      print('Actual Value weather: ${homepageState.weather}\n');
      print('Expected Value weather: null\n');
      expect(homepageState.weather, null); // Use the getter here
    });
  });
}
