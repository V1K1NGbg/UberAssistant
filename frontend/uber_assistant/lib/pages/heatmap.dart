import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:csv/csv.dart';

class RideActivityHeatMapPage extends StatefulWidget {
  const RideActivityHeatMapPage({super.key});

  @override
  State<RideActivityHeatMapPage> createState() => _RideActivityHeatMapPageState();
}

class _RideActivityHeatMapPageState extends State<RideActivityHeatMapPage> {
  List<WeightedLatLng> _heatmapData = [];
  bool _isLoading = true;
  String? _errorMessage;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadHeatmapData();
  }

  Future<void> _loadHeatmapData() async {
    try {
      final csvString = await rootBundle.loadString('assets/data/heatmap.csv');
      final rows = const CsvToListConverter().convert(csvString);
      if (rows.isEmpty) {
        setState(() { _errorMessage = 'No data found in CSV'; _isLoading = false; });
        return;
      }

      final headers = rows[0].map((e) => e.toString().trim()).toList();
      final pickupLatIdx = headers.indexOf('pickup_lat');
      final pickupLonIdx = headers.indexOf('pickup_lon');
      if (pickupLatIdx == -1 || pickupLonIdx == -1) {
        setState(() { _errorMessage = 'Required columns not found'; _isLoading = false; });
        return;
      }

      final heatmapPoints = <WeightedLatLng>[];
      final locationCounts = <String, int>{};

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length <= pickupLatIdx || row.length <= pickupLonIdx) continue;
        try {
          final lat = double.parse(row[pickupLatIdx].toString());
          final lon = double.parse(row[pickupLonIdx].toString());
          final locationKey = '${lat.toStringAsFixed(4)},${lon.toStringAsFixed(4)}';
          locationCounts[locationKey] = (locationCounts[locationKey] ?? 0) + 1;
        } catch (_) { continue; }
      }

      locationCounts.forEach((key, count) {
        final coords = key.split(',');
        final lat = double.parse(coords[0]);
        final lon = double.parse(coords[1]);
        heatmapPoints.add(WeightedLatLng(LatLng(lat, lon), count.toDouble()));
      });

      setState(() {
        _heatmapData = heatmapPoints;
        _isLoading = false;
      });

      if (heatmapPoints.isNotEmpty) _centerMapOnData();
    } catch (e) {
      setState(() { _errorMessage = 'Error loading data: $e'; _isLoading = false; });
    }
  }

  void _centerMapOnData() {
    if (_heatmapData.isEmpty) return;

    double minLat = _heatmapData[0].latLng.latitude;
    double maxLat = _heatmapData[0].latLng.latitude;
    double minLon = _heatmapData[0].latLng.longitude;
    double maxLon = _heatmapData[0].latLng.longitude;

    for (final point in _heatmapData) {
      if (point.latLng.latitude < minLat) minLat = point.latLng.latitude;
      if (point.latLng.latitude > maxLat) maxLat = point.latLng.latitude;
      if (point.latLng.longitude < minLon) minLon = point.latLng.longitude;
      if (point.latLng.longitude > maxLon) maxLon = point.latLng.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(centerLat, centerLon), 8);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Activity Heat Map'),
        actions: [
          if (!_isLoading && _heatmapData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _centerMapOnData,
              tooltip: 'Center Map',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Loading heat map data...')]))
          : _errorMessage != null
          ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: Colors.red), SizedBox(height: 16), Text('$_errorMessage', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))])))
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _heatmapData.isNotEmpty ? _heatmapData[0].latLng : const LatLng(52.0, 5.0),
          initialZoom: 8,
          minZoom: 3,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
          HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: _heatmapData),
            heatMapOptions: HeatMapOptions(radius: 40, gradient: HeatMapOptions.defaultGradient, minOpacity: 0.1),
            reset: _rebuildStream,
          ),
        ],
      ),
    );
  }

  Stream<void> get _rebuildStream => Stream.value(null);
}
