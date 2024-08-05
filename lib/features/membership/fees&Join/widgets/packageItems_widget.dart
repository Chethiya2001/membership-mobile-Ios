import 'package:flutter/material.dart';

class PackageItem extends StatelessWidget {
  const PackageItem({super.key, required this.package, required this.color});

  final Map<String, dynamic> package;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final title = package['title'];
    final duration = package['duration'];
    final price = package['price'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 2, 8),
      child: Row(
        children: [
          // Color container
          Container(
            decoration: BoxDecoration(
              color: color, // Replace with your desired color
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            height: 150,
            width: 50,
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'Price: $price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Information container
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            height: 150,
            width: MediaQuery.of(context).size.width * 0.77,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Text(
                    'Duration: $duration',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
