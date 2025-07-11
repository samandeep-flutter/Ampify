import 'package:ampify/data/utils/dimens.dart';
import 'package:ampify/data/utils/image_resources.dart';
import 'package:ampify/data/utils/string.dart';
import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/presentation/widgets/base_widget.dart';
import 'package:ampify/presentation/widgets/top_widgets.dart';
import 'package:ampify/services/extension_services.dart';
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
