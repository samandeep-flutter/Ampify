import 'package:ampify/data/utils/utils.dart';
import 'package:flutter/material.dart';
import '../widgets/base_widget.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      appBar: AppBar(
        title: const Text('Library'),
        titleTextStyle: Utils.defTitleStyle,
        centerTitle: true,
      ),
      child: const Column(children: []),
    );
  }
}
