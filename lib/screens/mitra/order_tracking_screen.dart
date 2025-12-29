import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacings.dart';
import '../../core/theme/app_radius.dart';
import '../../core/utils/result.dart';
import '../../core/widgets/app_card.dart';
import '../../repositories/tracking_repository.dart';
import '../../models/order.dart';
import '../../models/order_tracking.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _trackingRepository = TrackingRepository();
  GoogleMapController? _mapController;
  OrderTracking? _tracking;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _fetchTracking();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchTracking();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchTracking() async {
    if (!mounted) return;

    setState(() {
      if (_tracking == null) {
        _isLoading = true;
      }
      _error = null;
    });

    final result = await _trackingRepository.getOrderTracking(widget.order.id);

    if (!mounted) return;

    result
        .onSuccess((tracking) {
          setState(() {
            _tracking = tracking;
            _isLoading = false;
            _updateMapMarkers();
          });
        })
        .onFailure((failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        });
  }

  void _updateMapMarkers() {
    if (_tracking == null) return;

    _markers.clear();
    _polylines.clear();

    // Add driver marker if available
    if (_tracking!.hasDriverLocation) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            _tracking!.driverLatitude!,
            _tracking!.driverLongitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Driver: ${_tracking!.driverName ?? "Unknown"}',
            snippet: 'Lokasi saat ini',
          ),
        ),
      );
    }

    // Add destination marker if available
    if (_tracking!.hasDestinationLocation) {
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            _tracking!.destinationLatitude!,
            _tracking!.destinationLongitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Tujuan',
            snippet: _tracking!.destinationAddress,
          ),
        ),
      );
    }

    // Draw polyline between driver and destination if both available
    if (_tracking!.hasDriverLocation && _tracking!.hasDestinationLocation) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_tracking!.driverLatitude!, _tracking!.driverLongitude!),
            LatLng(
              _tracking!.destinationLatitude!,
              _tracking!.destinationLongitude!,
            ),
          ],
          color: AppColors.primary,
          width: 4,
        ),
      );

      // Move camera to show both markers
      _moveCameraToShowBothMarkers();
    }
  }

  void _moveCameraToShowBothMarkers() {
    if (_mapController == null || _tracking == null) return;
    if (!_tracking!.hasDriverLocation || !_tracking!.hasDestinationLocation) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(
        _tracking!.driverLatitude! < _tracking!.destinationLatitude!
            ? _tracking!.driverLatitude!
            : _tracking!.destinationLatitude!,
        _tracking!.driverLongitude! < _tracking!.destinationLongitude!
            ? _tracking!.driverLongitude!
            : _tracking!.destinationLongitude!,
      ),
      northeast: LatLng(
        _tracking!.driverLatitude! > _tracking!.destinationLatitude!
            ? _tracking!.driverLatitude!
            : _tracking!.destinationLatitude!,
        _tracking!.driverLongitude! > _tracking!.destinationLongitude!
            ? _tracking!.driverLongitude!
            : _tracking!.destinationLongitude!,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _callDriver() async {
    if (_tracking?.driverPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon driver tidak tersedia'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final uri = Uri.parse('tel:${_tracking!.driverPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka aplikasi telepon'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange[700]!;
      case 'confirmed':
        return Colors.blue[700]!;
      case 'on_delivery':
        return Colors.purple[700]!;
      case 'completed':
        return Colors.green[700]!;
      case 'cancelled':
        return Colors.red[700]!;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lacak Pengiriman', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _fetchTracking,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _tracking == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _tracking == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacings.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppSpacings.md),
                    Text(
                      _error!,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacings.md),
                    ElevatedButton.icon(
                      onPressed: _fetchTracking,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _tracking == null
          ? const Center(child: Text('Data tidak tersedia'))
          : Column(
              children: [
                // Map Section
                Expanded(flex: 3, child: _buildMapSection()),
                // Info Section
                Expanded(flex: 2, child: _buildInfoSection()),
              ],
            ),
    );
  }

  Widget _buildMapSection() {
    if (!_tracking!.hasDriverLocation && !_tracking!.hasDestinationLocation) {
      return Container(
        color: AppColors.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacings.md),
              Text(
                'Lokasi tidak tersedia',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final initialPosition = _tracking!.hasDriverLocation
        ? LatLng(_tracking!.driverLatitude!, _tracking!.driverLongitude!)
        : LatLng(
            _tracking!.destinationLatitude!,
            _tracking!.destinationLongitude!,
          );

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 14),
      markers: _markers,
      polylines: _polylines,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        _moveCameraToShowBothMarkers();
      },
    );
  }

  Widget _buildInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacings.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrderInfoCard(),
          const SizedBox(height: AppSpacings.sm),
          if (_tracking!.driverName != null) ...[
            _buildDriverInfoCard(),
            const SizedBox(height: AppSpacings.sm),
          ],
          _buildDistanceInfoCard(),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    final statusColor = _getStatusColor(_tracking!.status);

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacings.sm),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tracking!.orderCode,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tracking!.statusDisplay,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tracking!.driverName!,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_tracking!.driverPhone != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _tracking!.driverPhone!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_tracking!.driverPhone != null)
            IconButton(
              onPressed: _callDriver,
              icon: const Icon(Icons.phone),
              color: AppColors.primary,
              tooltip: 'Hubungi Driver',
            ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfoCard() {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacings.xs),
                    Text(
                      'Jarak',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _tracking!.formattedDistance,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.border),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacings.xs),
                    Text(
                      'Estimasi',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _tracking!.formattedEstimatedTime,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
