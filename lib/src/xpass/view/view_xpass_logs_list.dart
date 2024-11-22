import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../helpers/helpers.dart';
import '../models/xpass_logs_models.dart';
import '../service/xpass_logs_service.dart';
import '../utils/datetime_format.dart';
import 'view_xpass_logs_details.dart';

class ViewXpassLogsList extends StatefulWidget {
  const ViewXpassLogsList({super.key});
  static const routeName = '/viewxpasslogslist';

  @override
  State<ViewXpassLogsList> createState() => _ViewXpassLogsListState();
}

class _ViewXpassLogsListState extends State<ViewXpassLogsList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<LogsItem> _logsItems = [];
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _fetchLogs();
  }

  Future<void> _fetchLogs({bool isRefresh = false}) async {
    bool hasMore = true;
    if (isRefresh) {
      setState(() {
        _isLoading = true;
      });
      _currentPage = 0;
      _logsItems.clear();
    }

    try {
      List<LogsItem> newLogs =
          await XpassLogsService.fetchLogs(_currentPage, 10);
      setState(() {
        if (isRefresh) {
          hasMore = true;
          _logsItems = newLogs;
        } else {
          _logsItems.addAll(newLogs);
        }
      });

      _refreshController.loadComplete();
      hasMore = newLogs.length == 10;
      if (!hasMore) {
        _refreshController.loadNoData();
      } else if (isRefresh) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      if (isRefresh) {
        _refreshController.refreshFailed();
      } else {
        _refreshController.loadFailed();
      }
      MyHelpers.msg(
          message: e.toString().replaceAll('Exception:', ''),
          backgroundColor: Colors.redAccent);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchLogs(isRefresh: true);
  }

  Future<void> _onLoading() async {
    setState(() {
      _currentPage += 1;
    });
    await _fetchLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: Stack(
        children: [
          SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            header: const WaterDropMaterialHeader(
              backgroundColor: Colors.blue,
              color: Colors.white,
            ),
            footer: const ClassicFooter(
              loadingIcon: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            child: ListView.builder(
              itemCount: _logsItems.length,
              itemBuilder: (context, index) {
                LogsItem logsItem = _logsItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: logsItem.fullDetectPhotoUrl,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        title: Text(logsItem.license),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              xpassFormatDateTime('${logsItem.createdDate}'),
                            ),
                            Text(logsItem.logStatus.name),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ViewXpassLogsDetails.routeName,
                            arguments: logsItem,
                          );
                        },
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
                color: Colors.grey,
              ),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
