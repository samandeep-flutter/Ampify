import 'package:ampify/data/utils/utils.dart';
import 'package:ampify/services/extension_services.dart';
import 'package:flutter/material.dart';
import '../../data/utils/dimens.dart';

class Shimmer {
  static Widget get avatar => const _Shimmer(borderRadius: 50);
  static Widget get box => const _Shimmer();
}

class _Shimmer extends StatelessWidget {
  final double? borderRadius;
  const _Shimmer({this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: context.scheme.shimmer,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0))),
    );
  }
}

class AlbumShimmer extends StatelessWidget {
  const AlbumShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: Utils.insetsHoriz(Dimens.sizeDefault),
        scrollDirection: Axis.horizontal,
        gridDelegate: Utils.fixedCrossAxis(1,
            aspectRatio: 1.3, spacing: Dimens.sizeMedSmall),
        itemCount: Dimens.sizeExtraSmall.toInt(),
        itemBuilder: (_, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.borderSmall),
                child: AspectRatio(aspectRatio: 1, child: Shimmer.box),
              ),
              const SizedBox(height: Dimens.sizeSmall),
              SizedBox(
                  height: Dimens.sizeMedSmall,
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: .5,
                    child: Shimmer.box,
                  )),
              const SizedBox(height: Dimens.sizeSmall),
              SizedBox(
                  height: Dimens.sizeMedSmall,
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: .8,
                    child: Shimmer.box,
                  )),
            ],
          );
        });
  }
}

class SongTileShimmer extends StatelessWidget {
  final EdgeInsets? margin;
  final double? iconSize;
  const SongTileShimmer({super.key, this.margin, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          Utils.insetsOnly(Dimens.sizeSmall, left: Dimens.sizeDefault),
      child: Row(
        children: [
          SizedBox.square(
            dimension: iconSize ?? Dimens.iconExtraLarge,
            child: Shimmer.box,
          ),
          const SizedBox(width: Dimens.sizeDefault),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: Dimens.sizeMedSmall, width: 200, child: Shimmer.box),
              const SizedBox(height: Dimens.sizeMedSmall),
              SizedBox(
                  height: Dimens.sizeSmall,
                  width: context.width * .7,
                  child: Shimmer.box),
            ],
          )
        ],
      ),
    );
  }
}

class MusicGroupShimmer extends StatelessWidget {
  final bool isLikedSongs;
  final double? imageSize;
  final int? itemCount;
  const MusicGroupShimmer({
    super.key,
    this.imageSize,
    this.itemCount,
    this.isLikedSongs = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: context.scheme.background,
          toolbarHeight: Dimens.sizeExtraLarge,
        ),
        if (!isLikedSongs)
          SizedBox.square(
            dimension: imageSize ?? context.height * .3,
            child: Shimmer.box,
          ),
        Container(
          margin: const EdgeInsets.all(Dimens.sizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Dimens.sizeLarge,
                width: context.width * .6,
                child: Shimmer.box,
              ),
              const SizedBox(height: Dimens.sizeSmall),
              if (!isLikedSongs) ...[
                SizedBox(
                    height: Dimens.sizeDefault - 1,
                    width: double.infinity,
                    child: Shimmer.box),
                const SizedBox(height: Dimens.sizeSmall),
                SizedBox(
                    height: Dimens.sizeDefault - 1,
                    width: double.infinity,
                    child: Shimmer.box),
                const SizedBox(height: Dimens.sizeSmall),
              ],
              Row(
                children: [
                  if (!isLikedSongs)
                    SizedBox(
                        height: Dimens.sizeMidLarge,
                        width: context.width * .4,
                        child: Shimmer.avatar),
                  const SizedBox(width: Dimens.sizeSmall),
                  SizedBox(
                      height: Dimens.sizeDefault - 1,
                      width: context.width * .3,
                      child: Shimmer.box),
                ],
              )
            ],
          ),
        ),
        Row(
          children: [
            const SizedBox(width: Dimens.sizeDefault),
            if (!isLikedSongs)
              Icon(
                Icons.add_circle_outline,
                size: Dimens.iconLarge,
                color: context.scheme.shimmer,
              ),
            const Spacer(),
            SizedBox.square(
                dimension: Dimens.iconExtraLarge, child: Shimmer.avatar),
            const SizedBox(width: Dimens.sizeDefault),
          ],
        ),
        Expanded(
          child: ListView.builder(
              itemCount: itemCount ?? 5,
              padding: const EdgeInsets.only(top: Dimens.sizeDefault),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                return const SongTileShimmer();
              }),
        )
      ],
    );
  }
}
