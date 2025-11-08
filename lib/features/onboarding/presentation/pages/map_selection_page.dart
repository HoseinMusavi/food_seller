// lib/features/onboarding/presentation/pages/map_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong2; // پکیج نقشه
import 'package:food_seller/core/utils/lat_lng.dart'; // کلاس ساده خودمان

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  // مختصات پیش فرض (تهران) - می‌توانید به شهر خودتان تغییر دهید
  static final latlong2.LatLng _defaultLocation =
      latlong2.LatLng(35.6892, 51.3890);

  latlong2.LatLng _currentMapCenter = _defaultLocation;
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() { _isLoadingLocation = true; });
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سرویس موقعیت خاموش است.')));
      setState(() { _isLoadingLocation = false; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('دسترسی به موقعیت رد شد.')));
        setState(() { _isLoadingLocation = false; });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('دسترسی به موقعیت برای همیشه رد شد.')));
      setState(() { _isLoadingLocation = false; });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final userLocation = latlong2.LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentMapCenter = userLocation;
          _isLoadingLocation = false;
        });
        _mapController.move(_currentMapCenter, 16.0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطا در دریافت موقعیت: $e')));
        setState(() { _isLoadingLocation = false; });
      }
    }
  }

  void _onPositionChanged(MapPosition position, bool hasGesture) {
    if (position.center != null) {
      _currentMapCenter = position.center!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انتخاب موقعیت فروشگاه'),
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _determinePosition,
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentMapCenter,
              initialZoom: 14.0,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.food_seller', // نام پکیج شما
              ),
            ],
          ),
          Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('تایید این موقعیت'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary, // سبز
              ),
              onPressed: () {
                // ما نوع latlong2 را به نوع ساده LatLng خودمان تبدیل می‌کنیم
                final selectedLatLng = LatLng(
                  latitude: _currentMapCenter.latitude,
                  longitude: _currentMapCenter.longitude,
                );
                Navigator.pop(context, selectedLatLng);
              },
            ),
          ),
        ],
      ),
    );
  }
}