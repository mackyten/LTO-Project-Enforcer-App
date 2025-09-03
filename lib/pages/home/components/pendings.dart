import 'package:enforcer_auto_fine/pages/home/components/title.dart';
import 'package:enforcer_auto_fine/pages/home/handlers.dart';
import 'package:enforcer_auto_fine/pages/violation/models/report_model.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:enforcer_auto_fine/shared/app_theme/fonts.dart';
import 'package:enforcer_auto_fine/shared/date/format.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pendings extends StatefulWidget {
  const Pendings({super.key});

  @override
  State<Pendings> createState() => _PendingsState();
}

class _PendingsState extends State<Pendings> {
  final _handlers = HomeHandlers();

  // Use a late final variable to ensure the future is only created once
  late final Future<List<ReportModel>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _draftsFuture = _handlers.loadAllReportDrafts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _draftsFuture, // Pass the pre-initialized future here
      builder: (context, snapshot) {
        // Correctly handle the data and its type

        return Container(
          // constraints: BoxConstraints(maxHeight: 400),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleBuilder(
                    title: 'Pending Reports',
                    icon: Icon(
                      Icons.insert_drive_file,
                      color: MainColor().warning,
                    ),
                  ),
                  const SizedBox(height: 16),

                  snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                      ? Center(child: Text('Error: ${snapshot.error}'))
                      : (!snapshot.hasData || snapshot.data!.isEmpty)
                      ? const Center(child: Text('No pending reports.'))
                      : Column(
                          children: snapshot.data!.asMap().entries.map((draft) {
                            var item = draft.value;

                            return ListTile(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/violations',
                                  arguments: item,
                                );
                              },
                              leading: Text(
                                "${draft.key + 1}.",
                                style: TextStyle(
                                  fontSize: FontSizes().body,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              title: Text(item.fullname ?? "No Name"),
                              subtitle: Text(
                                DateFormat(
                                  AppDate.format,
                                ).format(item.createdAt!),
                              ),
                              trailing: Icon(Icons.open_in_new_outlined),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
