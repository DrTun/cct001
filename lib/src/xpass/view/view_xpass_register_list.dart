import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../helpers/helpers.dart';
import '../models/xpass_register_models.dart';
import '../service/xpass_register_service.dart';
import '../utils/datetime_format.dart';
import 'view_xpass_edit_register.dart';
import 'view_xpass_register.dart';

class ViewXpassRegisterList extends StatefulWidget {
  const ViewXpassRegisterList({super.key});
  static const routeName = '/viewxpassregisterlist';

  @override
  State<ViewXpassRegisterList> createState() => _ViewXpassRegisterListState();
}

class _ViewXpassRegisterListState extends State<ViewXpassRegisterList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<RegisterItem> _registerItems = [];
  int _currentPage = 0;
  final Color addIconColor = const Color.fromARGB(255, 8, 83, 10);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _fetchRegisters();
  }

  Future<void> _fetchRegisters({bool isRefresh = false}) async {
    bool hasMore = true;
    if (isRefresh) {
      setState(() {
        _isLoading = true;
      });
      _currentPage = 0;
      _registerItems.clear();
    }

    try {
      final newRegisterItems =
          await XpassRegisterService.fetchRegisters(_currentPage, 10);
      setState(() {
        if (isRefresh) {
          hasMore = true;
          _registerItems = newRegisterItems;
        } else {
          _registerItems.addAll(newRegisterItems);
        }
      });
      hasMore = newRegisterItems.length == 10;
      _refreshController.loadComplete();
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
    await _fetchRegisters(isRefresh: true);
  }

  Future<void> _onLoading() async {
    setState(() {
      _currentPage += 1;
    });
    await _fetchRegisters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, ViewXpassRegister.routeName).then(
                  (value) {
                    if (value == true) {
                      _onRefresh();
                    }
                  },
                );
              },
              label: const Text('Add'),
              icon: const Icon(Icons.add),
              style: OutlinedButton.styleFrom(
                foregroundColor: addIconColor,
                side: BorderSide(color: addIconColor, width: 1),
              ),
            ),
          ]),
          Expanded(
            child: Stack(
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
                    itemCount: _registerItems.length,
                    itemBuilder: (context, index) {
                      RegisterItem registerItem = _registerItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(registerItem.license),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    registerItem.description,
                                  ),
                                  Text(xpassFormatDateTime(
                                      '${registerItem.createdDate}')),
                                  Text(
                                    registerItem.status!.name,
                                    style: TextStyle(
                                        color: registerItem.status ==
                                                RegisterStatus.ACTIVE
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ViewXpassEditRegister.routeName,
                                  arguments: registerItem,
                                ).then(
                                  (value) {
                                    if (value == true) {
                                      _onRefresh();
                                    }
                                  },
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
          ),
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
