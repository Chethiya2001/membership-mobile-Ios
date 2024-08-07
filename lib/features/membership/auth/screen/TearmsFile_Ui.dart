import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';
import 'package:mobile_app/features/membership/tearms&condition/providers/tearms_provider.dart';

class TearmsFile extends ConsumerStatefulWidget {
  const TearmsFile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TearmsFileState();
}

class _TearmsFileState extends ConsumerState<TearmsFile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: newKMainColor,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: newKMainColor,
        title: Text(
          "Terms & Condition",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Adamina',
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Consumer(
                builder: (context, watch, child) {
                  final termsData = ref.watch(tearmsProvider);

                  return termsData.when(
                    data: (data) {
                      final List<dynamic> faqs = data['success'];

                      return ListView.builder(
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final faq = faqs[index];

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.white,
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  faq['title'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                                subtitle: Text(
                                  faq['sub_title'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      faq['content'],
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const Center(
                        child: Text('Error loading Terms and Conditions')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
