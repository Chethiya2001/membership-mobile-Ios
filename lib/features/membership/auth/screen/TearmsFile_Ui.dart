import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text(
                "Terms & Condition",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Adamina',
                ),
              ),
            ),
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

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                const BoxShadow(
                                  color: Colors.white,
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
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
