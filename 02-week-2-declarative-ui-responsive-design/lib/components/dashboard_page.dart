import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:declarative_ui/components/dashboard_card.dart';

/// ST L PAGE

const double kWideBreakpoint = 700.0;


class DashboardPage extends StatelessWidget {

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;
  
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("student dashboard"),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              const SizedBox(width: 4,),
              Semantics(
                label: "toggle dark mode",
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              )
            ],
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // final columns = constraints.maxWidth >= 700 ? 2:1;
          final columns = constraints.maxWidth >= kWideBreakpoint ? 2:1;
          return GridView.count(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            childAspectRatio: 2.6,
            children: [
              Semantics(
                label: "student profile: HANZEL WOLLWAGE",
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.people),
                      ),

                      const SizedBox(width: 10,),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("HANZEL PUTRA WOLLWAGE"),
                            const SizedBox(width: 4,),
                            Text("244107020157"),
                            const SizedBox(width: 4,),
                            Text("TI-3I"),
                          ],
                        ),
                      )
                      
                    ],
                  ),
                ),
              ),
              DashboardCard(title: "jago scroll fesnuk?", value: "YES"),
              DashboardCard(title: "assignment", value: "8"),
              DashboardCard(title: "attendance", value: "92%"),
              DashboardCard(title: "portofolio", value: "ready"),
              DashboardCard(title: "current week", value: "02"),
            ],
          );
        },
      ),
    );
  }
}