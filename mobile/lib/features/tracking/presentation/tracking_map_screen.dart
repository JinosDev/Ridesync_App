import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/tracking_provider.dart';

class TrackingMapScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const TrackingMapScreen({super.key, required this.scheduleId});
  @override
  ConsumerState<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends ConsumerState<TrackingMapScreen> {
  GoogleMapController? _mapController;
  Marker? _busMarker;

  // TODO: resolve busId from scheduleId via scheduleDetailProvider
  String get busId => 'BUS001'; // placeholder

  @override
  Widget build(BuildContext context) {
    final locationAsync   = ref.watch(trackingProvider(busId));
    final tripStatusAsync = ref.watch(tripStatusProvider(widget.scheduleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(6.9271, 79.8612), zoom: 13),
            markers: _busMarker != null ? {_busMarker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (c) => _mapController = c,
          ),

          // ETA Banner
          tripStatusAsync.when(
            data: (status) => status.isNotEmpty
                ? Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      color: AppColors.primary.withOpacity(0.9),
                      padding: const EdgeInsets.all(AppDimensions.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Stop: ${status['currentStop'] ?? '-'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          if (status['eta'] != null)
                            Text('ETA: ${DateFormatter.formatEtaMs(status['eta'] as int)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Stale Signal Warning
          locationAsync.when(
            data: (location) {
              _updateMarker(location);
              return location.isStale
                  ? Positioned(
                      bottom: 80, left: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        decoration: BoxDecoration(color: AppColors.gpsStale, borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
                        child: const Row(children: [
                          Icon(Icons.signal_wifi_statusbar_connected_no_internet_4, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Location signal lost', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    )
                  : const SizedBox.shrink();
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Tracking unavailable')),
          ),
        ],
      ),
    );
  }

  void _updateMarker(BusLocation location) {
    final newPos = LatLng(location.lat, location.lng);
    setState(() {
      _busMarker = Marker(
        markerId: const MarkerId('bus'),
        position: newPos,
        rotation: location.heading,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'Bus', snippet: '${location.speed.toStringAsFixed(1)} km/h'),
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
  }
}
