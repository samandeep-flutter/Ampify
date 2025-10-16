import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';

class NotFoundScreen extends StatefulWidget {
  final GoRouterState state;
  const NotFoundScreen(this.state, {super.key});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BaseWidget(
      appBar: AppBar(backgroundColor: scheme.background),
      bodyPadding: Utils.insetsHoriz(Dimens.sizeLarge),
      child: DefaultTextStyle.merge(
        style: Utils.titleStyleLarge(context),
        child: Column(
          children: [
            const Spacer(),
            Text('404',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: context.width * .4,
                )),
            Text(StringRes.errorPage, textAlign: TextAlign.center),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
