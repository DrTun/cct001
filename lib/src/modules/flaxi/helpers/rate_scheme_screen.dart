import 'package:flutter/material.dart';
import '../../../helpers/helpers.dart';
import 'log_model.dart';
import 'log_service.dart';
import '../api/api_data_service_flaxi.dart';
import '../api_data_models/groups_models.dart';
import '../api_data_models/rateby_groups_models.dart';
import 'group_service.dart';

class RateSchemeScreen extends StatefulWidget {
  const RateSchemeScreen({super.key});

  @override
  State<RateSchemeScreen> createState() => _RateSchemeScreenState();
}

class _RateSchemeScreenState extends State<RateSchemeScreen> {
  @override
  void initState() {
    super.initState();
    rateScheme();
  }

  Future<List<Rate>> rateScheme() async {
    try {
      Group? selectedGroup = await MyStore.retriveDrivergroup('drivergroup');
      if (selectedGroup == null) {
        await GroupService.fetchAndStoreGroups();
        // logger.e('Driver group data or syskey not found.');
        selectedGroup = await MyStore.retriveDrivergroup('drivergroup');
        if (selectedGroup == null) {
          throw Exception('Driver group data or syskey not found');
        }
      }
      final domain = selectedGroup.syskey;
      final response = await ApiDataServiceFlaxi().ratebyGroups(domain);

      if (response.status == 200 && response.dataList != null) {
        return response.dataList;
      } else {
        logger.e('No rate data available.');
        return [];
      }
    } catch (e) {
      LogService.writeLog(LogModel(errorMessage: e.toString(), stackTrace:' rateScheme (rate_scheme_screen)', timestamp: DateTime.now().toString()));
      logger.e('An error occurred while loading the content: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final paddingFactor = screenWidth * 0.03;
    final fontSizeFactor = screenWidth * 0.045;
    final rowSpacing = screenHeight * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate'),
      ),
      body: FutureBuilder<List<Rate>?>(
        future: rateScheme(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else if (snapshot.hasError || snapshot.data!.isEmpty) {
            return const Center(child: Text('Oops, something went wrong!'));
          } else if (snapshot.hasData && snapshot.data != null) {
            logger.i('groupRate Data: ${snapshot.data}');

            final dataList = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(paddingFactor),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 500),
                  child: buildRateCard(
                    dataList[index],
                    fontSizeFactor,
                    rowSpacing,
                    paddingFactor,
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget buildRateCard(
    Rate rateData,
    double fontSizeFactor,
    double rowSpacing,
    double paddingFactor,
  ) {
    final extras = rateData.extras ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: paddingFactor, horizontal: paddingFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Initial', style: TextStyle(fontSize: fontSizeFactor)),
                Text(MyHelpers.formatInt(int.parse(rateData.initial)),
                    style: TextStyle(fontSize: fontSizeFactor)),
              ],
            ),
            SizedBox(height: rowSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rate',
                    style: TextStyle(fontSize: fontSizeFactor)),
                Text(MyHelpers.formatInt(int.parse(rateData.rate)),
                    style: TextStyle(fontSize: fontSizeFactor)),
              ],
            ),
            SizedBox(height: rowSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Waiting Charge',
                    style: TextStyle(fontSize: fontSizeFactor)),
                Text(MyHelpers.formatInt(int.parse(rateData.waitingCharge)),
                    style: TextStyle(fontSize: fontSizeFactor)),
              ],
            ),
            SizedBox(height: rowSpacing),
            const Divider(thickness: 1, color: Colors.grey),
            SizedBox(height:extras.isEmpty?0: rowSpacing),
            extras.isEmpty ? const SizedBox():
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Extras',
                    style: TextStyle(
                        fontSize: fontSizeFactor, fontWeight: FontWeight.bold)),
                Text('Units ( ${rateData.symbol} )',
                    style: TextStyle(
                        fontSize: fontSizeFactor, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: rowSpacing),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: extras.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: rowSpacing / 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(extras[index].name,
                              style: TextStyle(fontSize: fontSizeFactor)),
                          Text(
                              MyHelpers.formatInt(
                                  int.parse(extras[index].amount)),
                              style: TextStyle(fontSize: fontSizeFactor))
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
