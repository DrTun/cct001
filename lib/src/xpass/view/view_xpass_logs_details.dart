// detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/xpass_logs_models.dart';
import '../utils/datetime_format.dart';

class ViewXpassLogsDetails extends StatelessWidget {
  const ViewXpassLogsDetails({super.key});
  static const routeName = '/xpasslogsdetails';

  @override
  Widget build(BuildContext context) {
    final LogsItem logsItem =
        ModalRoute.of(context)!.settings.arguments as LogsItem;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License: ${logsItem.license}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date: ${xpassFormatDateTime('${logsItem.createdDate}')}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Status: ${logsItem.logStatus.name}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: logsItem.fullDetectPhotoUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  const SizedBox(height: 16),
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: logsItem.fullLicensePhotoUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
