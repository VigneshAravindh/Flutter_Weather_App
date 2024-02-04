import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:location/location.dart';
import 'package:flutter_application_1/akey.dart';
import 'package:flutter_application_1/search_page.dart';
import 'package:flutter_application_1/exception.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  TextEditingController _searchController = TextEditingController();
  Weather? get weather => _weather;
  Weather? _weather;
  bool isLoading = true;
  String errorMessage = '';
  Location location = new Location(); // Add the Location object

  @override
  void initState() {
    super.initState();
    _requestLocationPermissions(); // Add location permission request
    getCurrentLocation();
  }

  Future<void> _requestLocationPermissions() async {
    // Use the location plugin's methods to request permissions
    await location.requestPermission();
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    try {
      Weather weather = await _wf.currentWeatherByLocation(latitude, longitude);
      updateWeatherState(weather, false, '');
    } catch (e) {
      handleFetchError(e);
    }
  }

  Future<void> getCurrentLocation() async {
    isLoading = true; // Set loading state to true
    try {
      LocationData locationData = await location.getLocation();
      await fetchWeatherData(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      handleFetchError(e);
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false
      });
    }
  }

  Future<void> fetchWeatherBySearch(String location) async {
    try {
      Weather weather = await _wf.currentWeatherByCityName(location);
      updateWeatherState(weather, false, '');
      _searchController.clear(); // Clear search text after fetching
    } catch (e) {
      handleFetchError(e);
    }
  }

  void updateWeatherState(Weather? weather, bool loading, String error) {
    if (mounted) {
      // Check if the widget is still in the widget tree
      setState(() {
        _weather = weather;
        isLoading = loading;
        errorMessage = error;
      });
    }
  }

  void handleFetchError(dynamic error) {
    String errorMessage;

    if (error is WeatherException) {
      errorMessage = 'Failed to fetch weather data: ${error.message},';
    } else {
      errorMessage =
          'Failed to fetch weather data. Please check your internet connection and try again.';
    }

    updateWeatherState(null, false, errorMessage);
    print('Error fetching weather: $error');
  }

  void navigateToSearchPage() async {
    try {
      final String? selectedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(),
        ),
      );

      if (selectedLocation != null) {
        fetchWeatherBySearch(selectedLocation);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to navigate to search page.';
      });
      print('Error navigating to search page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/OIP (1).jpeg'), // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          child: _buildUI(),
        ),
        appBar: AppBar(
          title: const Text(
            "Weather app",
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
          actions: [
            IconButton(
              onPressed: navigateToSearchPage,
              icon: const Icon(Icons.search),
              color: Colors.deepOrange,
            ),
          ],
        ),
      );
    } catch (e) {
      return Scaffold(
        body: Center(
          child: Text(
            'An unexpected error occurred. Please try again.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  Widget _buildUI() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontSize: 25,
              fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.my_location, color: Colors.purpleAccent),
              onPressed: getCurrentLocation,
              label: const Text("Get Current Location",
                  style:
                      TextStyle(fontSize: 16, color: Colors.deepPurpleAccent)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            Card(
              // color: Colors.amber,
              color: Colors
                  .lightBlue.shade200, // Adjust based on your background image

              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 50, 20, 35), // Ensure bottom spacing
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Optimize vertical space
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            _locationheader(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            _dateTimeinfo(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 175, // Adjust as needed
                          height: 180, // Adjust as needed
                          child: _weatherIcon(),
                        ),
                      ],
                    ),
                    _currentTemp(), // Temperature within the card
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _locationheader() {
    return Text(
      _weather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _dateTimeinfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 40, backgroundColor: Colors.white70),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
            Text(
              " ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return SizedBox(
      // Ensure icon fits within card
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevent unnecessary expansion
        children: [
          Image.network(
            "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png",
            width: 120, // Adjust as needed
            height: 90, // Adjust as needed
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Text('Error loading image');
            },
          ),
          Text(
            _weather?.weatherDescription ?? "",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
