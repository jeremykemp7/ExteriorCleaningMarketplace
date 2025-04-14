import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({
    super.key,
    this.size = 32,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder<String>(
          future: storageService.getDesignAssetUrl('logo (1).png'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: size,
                height: size,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.hexagon_outlined),
              );
            }

            return Image.network(
              snapshot.data!,
              width: size,
              height: size,
              fit: BoxFit.contain,
            );
          },
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'LUCID BOTS',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
} 