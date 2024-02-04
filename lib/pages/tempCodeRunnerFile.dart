import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:location/location.dart';
import 'package:flutter_application_1/akey.dart';
import 'package:flutter_application_1/search_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  TextEditingController _searchController = TextEditingController();

  Weather? _weather;
  bool _isLoading = true;
  String _errorMessage = '';
  Location location = new Location(); // Add the Location object

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      Weather weather = await _wf.currentWeatherByLocation(latitude, longitude);
      setState(() {
        _weather = weather;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch weather data. Please try again.';
      });
      print('Error fetching weather: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationData locationData = await location.getLocation();
      await _fetchWeatherData(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _errorMessage = 'Failed to get current location.';
      });
    }
  }

  Future<void> _fetchWeatherBySearch(String location) async {
    try {
      Weather weather = await _wf.currentWeatherByCityName(location);
      setState(() {
        _weather = weather;
        _isLoading = false;
        _errorMessage = '';
      });
      _searchController.clear(); // Clear search text after fetching
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch weather data by search.';
      });
      print('Error fetching weather by search: $e');
    }
  }

  void _navigateToSearchPage() async {
    final String? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(),
      ),
    );

    if (selectedLocation != null) {
      _fetchWeatherBySearch(selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      appBar: AppBar(
        title: const Text(
          "Weather app",
          style: TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        backgroundColor: Colors.tealAccent,
        actions: [
          IconButton(
            onPressed: _navigateToSearchPage,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildUI() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red),
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
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text("Get Current Location"),
            ),
            _locationheader(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            _dateTimeinfo(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            _weatherIcon(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            _currentTemp(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
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
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _dateTimeinfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 37,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              " ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"))),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(color: Colors.blue, fontSize: 20),
        )
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)} C",
      style: const TextStyle(
        color: Colors.brown,
        fontSize: 90,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
