import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<void> openShareSheet(
  BuildContext context, {
  required VoidCallback onExcelTapped,
  required VoidCallback onCSVTapped,
}) async {
  await showModalBottomSheet(
    context: context,
    builder: (context) =>
        ShareSheet(onExcelTapped: onExcelTapped, onCSVTapped: onCSVTapped),
  );
}

class ShareSheet extends StatelessWidget {
  final VoidCallback onExcelTapped;
  final VoidCallback onCSVTapped;
  const ShareSheet({
    super.key,
    required this.onExcelTapped,
    required this.onCSVTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Export as',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ExportOption(
                icon: FontAwesomeIcons.fileExcel,
                onTap: onExcelTapped,
                color: Colors.green,
              ),
              const SizedBox(width: 10),
              ExportOption(
                icon: FontAwesomeIcons.fileCsv,
                onTap: onCSVTapped,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ExportOption extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final EdgeInsets padding;
  const ExportOption({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
    this.padding = const EdgeInsets.all(10),
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: size),
      ),
    );
  }
}
