import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import '../../data/utils/color_resources.dart';
import '../../data/utils/dimens.dart';

class Shimmer {
  static get avatar => const _Shimmer(borderRadius: 50);
  static get box => const _Shimmer();
}

class _Shimmer extends StatelessWidget {
  final double? borderRadius;
  const _Shimmer({this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: ColorRes.shimmer,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0))),
    );
  }
}

class SongTileShimmer extends StatelessWidget {
  final EdgeInsets? margin;
  const SongTileShimmer({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.fromLTRB(
            Dimens.sizeDefault,
            Dimens.sizeSmall,
            Dimens.sizeLarge,
            Dimens.sizeSmall,
          ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 50,
            child: Shimmer.box,
          ),
          const SizedBox(width: Dimens.sizeDefault),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15, width: 200, child: Shimmer.box),
              const SizedBox(height: Dimens.sizeMedSmall),
              SizedBox(
                  height: 15, width: context.width * .7, child: Shimmer.box),
            ],
          )
        ],
      ),
    );
  }
}
