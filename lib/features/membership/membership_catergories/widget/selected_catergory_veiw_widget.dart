import 'package:flutter/material.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';

class CatergoryDataWidget extends StatelessWidget {
  const CatergoryDataWidget({super.key, this.data});
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: newKBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              data.toString(),
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
