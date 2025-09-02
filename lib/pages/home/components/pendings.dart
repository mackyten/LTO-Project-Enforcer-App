import 'package:enforcer_auto_fine/pages/home/components/title.dart';
import 'package:enforcer_auto_fine/shared/app_theme/colors.dart';
import 'package:flutter/material.dart';

class Pendings extends StatefulWidget {
  const Pendings({super.key});

  @override
  State<Pendings> createState() => _PendingsState();
}

class _PendingsState extends State<Pendings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              SizedBox(height: 16),

              Text("To do..."),
              SizedBox(height: 16),

       
            ],
          ),
        ),
      ),
    );
  }
}
