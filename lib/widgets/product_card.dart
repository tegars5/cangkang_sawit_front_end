import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Reusable product card widget
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: _buildImage(),
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),

                    // Stock status
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 14,
                          color: _getStockColor(),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStockColor(),
                              fontWeight: product.isLowStock
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),

                        // Low stock badge
                        if (product.isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Action buttons for admin
                    if (showActions) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (onEdit != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ),
                          if (onEdit != null && onDelete != null)
                            const SizedBox(width: 8),
                          if (onDelete != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text(
                                  'Hapus',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                  side: const BorderSide(color: AppTheme.error),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (product.primaryImage != null) {
      return CachedNetworkImage(
        imageUrl: product.primaryImage!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey[500]),
              const SizedBox(height: 4),
              Text(
                'Gambar error',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // No image placeholder
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey[500]),
    );
  }

  Color _getStockColor() {
    if (product.isOutOfStock) return AppTheme.error;
    if (product.isLowStock) return AppTheme.warning;
    return AppTheme.success;
  }
}
