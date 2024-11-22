import 'package:flutter/material.dart';
import '../helpers/helpers.dart';
import '../modules/flaxi/helpers/log_model.dart';
import '../modules/flaxi/helpers/log_service.dart';

class ViewLogs extends StatefulWidget {
  static const routeName = '/viewlog';
  const ViewLogs({super.key});

  @override
  State<ViewLogs> createState() => _ViewLogsState();
}

class _ViewLogsState extends State<ViewLogs> {
  late Future<List<LogModel>> _logs; 
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    _logs = LogService.readLogs();  
    setState(() {});  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logs")),
      body: FutureBuilder<List<LogModel>>(
        future: _logs, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());  
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading logs"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No logs available"));
          } else {
            final logs = snapshot.data!;
            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text("Time: ${MyHelpers.ymdDateFormatapi(log.timestamp)}",style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Error: ${log.errorMessage}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                        Text("Stacktrace: ${log.stackTrace}"),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  
}
