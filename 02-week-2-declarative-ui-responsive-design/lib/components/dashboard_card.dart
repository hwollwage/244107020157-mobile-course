import 'package:flutter/material.dart';

/// ST L CARD

class DashboardCard extends StatelessWidget {

  final String title;
  final String value;

  const DashboardCard({
    required this.title,
    required this.value,
    super.key
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(12)),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Text(value, style: Theme.of(context).textTheme.headlineSmall,)
          ],
        ),
      ),
    );
  }
}