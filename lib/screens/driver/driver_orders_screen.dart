import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_client.dart';
import '../../models/delivery_order.dart';
import '../../core/theme/app_colors.dart';

/// Screen untuk driver manage orders dengan tracking
class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  final _apiClient = ApiClient();
  List<DeliveryOrder> _deliveryOrders = [];
  bool _isLoading = false;
  String? _error;
  bool _isTrackingActive = false;

  @override
  void initState() {
    super.initState();
    _loadDeliveryOrders();
  }

  Future<void> _loadDeliveryOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _apiClient.getDriverOrders();

      setState(() {
        _deliveryOrders = orders
            .map((json) => DeliveryOrder.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _startTracking(DeliveryOrder order) async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Izin lokasi ditolak', isError: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Izin lokasi ditolak permanen', isError: true);
        return;
      }

      setState(() {
        _isTrackingActive = true;
      });

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Send tracking data
      await _apiClient.trackDriverDelivery(
        order.id,
        position.latitude,
        position.longitude,
      );

      _showSnackBar('Lokasi berhasil diperbarui');
    } catch (e) {
      _showSnackBar('Gagal update lokasi: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isTrackingActive = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengiriman Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveryOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDeliveryOrders,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _deliveryOrders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _deliveryOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDeliveryOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_deliveryOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text('Belum ada pengiriman', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Pengiriman Anda akan muncul di sini',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deliveryOrders.length,
      itemBuilder: (context, index) {
        final order = _deliveryOrders[index];
        return _buildDeliveryCard(order);
      },
    );
  }

  Widget _buildDeliveryCard(DeliveryOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.orderCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Tujuan',
              order.destination,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.scale_outlined,
              'Berat',
              '${order.totalWeight} kg',
            ),
            if (order.pickupLocation != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.store_outlined,
                'Lokasi Pickup',
                order.pickupLocation!,
              ),
            ],
            if (order.status == 'on_the_way' || order.status == 'assigned') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTrackingActive
                      ? null
                      : () => _startTracking(order),
                  icon: _isTrackingActive
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _isTrackingActive ? 'Mengupdate...' : 'Update Lokasi',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'assigned':
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange;
        label = 'Ditugaskan';
        break;
      case 'on_the_way':
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue;
        label = 'Dalam Perjalanan';
        break;
      case 'arrived':
        backgroundColor = Colors.purple.withValues(alpha: 0.2);
        textColor = Colors.purple;
        label = 'Tiba';
        break;
      case 'completed':
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green;
        label = 'Selesai';
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
