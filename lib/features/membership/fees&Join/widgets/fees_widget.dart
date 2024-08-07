import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/membership/fees&Join/providers/fees_provider.dart';
import 'package:mobile_app/features/membership/stages/widgets/stage_one_widget.dart';

class FeesWidget extends ConsumerStatefulWidget {
  const FeesWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeesWidgetState();
}

class _FeesWidgetState extends ConsumerState<FeesWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'When you join The Union, you become part of a diverse community of professionals, experts, and healthcare workers, with access to a wealth of knowledge and expertise, empowered by the strength of a collective voice. As a member, you share the union’s vision and values and are committed to developing solutions and action through collaboration, at a global and local level. Learn what it costs and about the benefits of membership.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(
              height: 350,
              child: Expanded(
                child: Consumer(
                  builder: (context, watch, child) {
                    final feesData = ref.watch(feesProvider);

                    return feesData.when(
                      data: (data) {
                        final packagesDetails =
                            data['success']['packages-details'];
                        return ListView.builder(
                          itemCount: packagesDetails.length,
                          itemBuilder: (context, index) {
                            final package = packagesDetails[index];
                            return SizedBox(
                              height: 100,
                              child: Card(
                                color: Theme.of(context).colorScheme.primary,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ListTile(
                                    title: Text(
                                      package['title'],
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'Price: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '\$${package['price']}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(
                                                          0.9), // Set the color for the price value
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'Duration: ',
                                              ),
                                              TextSpan(
                                                text: '${package['duration']}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary, // Set the color for the duration value
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stackTrace) => Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "If your organization is interested in joining The Union, please visit,",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const RegisterStageWidget()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  minimumSize: const Size(150, 55)),
              child: Text(
                'Register',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Join our membership groups or propose new ones.\n\n'
                'Vote in our general assembly.\n\n'
                'Apply to join our board of directors\n\n'
                'Join executive committees of our member groups\n\n'
                'Access to join journals.\n'
                'Receive registration discount on our courses and conferences.\n\n'
                'Help the union achieve its goal of a healthier world for all, free of tuberculosis and lung disease.',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}