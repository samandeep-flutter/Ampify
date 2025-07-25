import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';

class ListeningHistory extends StatelessWidget {
  const ListeningHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return BaseWidget(
      appBar: AppBar(
        backgroundColor: scheme.background,
        title: const Text(StringRes.listenHistory),
        titleTextStyle: Utils.defTitleStyle(context),
        centerTitle: false,
      ),
      child: Column(
        children: [
          Text(
            StringRes.listnHisSubtitle,
            style: TextStyle(
                color: scheme.textColorLight, fontSize: Dimens.fontXXXLarge),
          ),
          ToolTipWidget.placeHolder(
            icon: ImageRes.musicAlt,
            title: StringRes.emptyListnHistory,
          )
        ],
      ),
    );
  }
}
