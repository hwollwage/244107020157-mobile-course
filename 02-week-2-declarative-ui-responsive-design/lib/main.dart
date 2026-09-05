import 'package:flutter/material.dart';
import 'components/dashboard_page.dart';

void main() => runApp(DashboardApp());

/// ST F APP

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) {
          setState(() => isDark = value);
        },
      ),
    );
  }
}




//
// INI WARMUP KODE SEBELUMNYA
// 
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("student dashboard"), centerTitle: true,),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final columns = constraints.maxWidth >= 700 ? 2:1;
//           return GridView.count(
//             crossAxisCount: columns,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             padding: const EdgeInsets.all(16),
//             childAspectRatio: 2.6,
//             children: [
//               DashboardCard(title: "assignment", value: "8"),
//               DashboardCard(title: "attendance", value: "92%"),
//               DashboardCard(title: "portofolio", value: "ready"),
//               DashboardCard(title: "current week", value: "02"),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class DashboardApp extends StatelessWidget {
//   const DashboardApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
//       darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
//       themeMode: ThemeMode.system,
//       home: const DashboardPage(),
//     );
//   }
// }