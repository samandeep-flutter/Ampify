import 'package:ampify/services/extension_services.dart';
import 'package:ampify/data/utils/dimens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/utils/app_constants.dart';
import '../../data/utils/image_resources.dart';
import 'shimmer_widget.dart';

class MyCachedImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool isAvatar;
  final bool loading;
  final double? avatarRadius;
  final double? borderRadius;
  final Color? foregroundColor;
  const MyCachedImage(this.image,
      {super.key,
      this.isAvatar = false,
      this.loading = false,
      this.avatarRadius,
      this.height,
      this.width,
      this.foregroundColor,
      this.borderRadius,
      this.fit});

  const MyCachedImage.error(
      {super.key,
      this.isAvatar = false,
      this.avatarRadius,
      this.height,
      this.width,
      this.foregroundColor,
      this.borderRadius,
      this.fit})
      : image = null,
        loading = false;
  const MyCachedImage.loading(
      {super.key,
      this.isAvatar = false,
      this.avatarRadius,
      this.height,
      this.width,
      this.foregroundColor,
      this.borderRadius,
      this.fit})
      : image = null,
        loading = true;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(Dimens.sizeSmall);
    final scheme = context.scheme;
    if (loading) {
      if (isAvatar) {
        return CircleAvatar(
            backgroundColor: scheme.backgroundDark,
            radius: avatarRadius,
            child: Shimmer.avatar);
      }

      return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          child: SizedBox(
            height: height,
            width: width,
            child: Shimmer.box,
          ));
    }

    if (image?.isEmpty ?? true) {
      Image image = Image.asset(
        ImageRes.thumbnail,
        color: scheme.disabled,
        fit: fit ?? BoxFit.cover,
      );
      if (isAvatar) {
        image = Image.asset(ImageRes.userThumbnail, fit: BoxFit.cover);
        return CircleAvatar(
            backgroundColor: scheme.backgroundDark,
            radius: avatarRadius,
            child: Padding(padding: padding, child: image));
      }
      return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          child: Container(
              padding: padding,
              color: scheme.backgroundDark,
              height: height,
              width: width,
              child: image));
    }

    return CachedNetworkImage(
        imageUrl: image!,
        fit: fit ?? BoxFit.cover,
        height: height,
        width: width,
        imageBuilder: (context, imageProvider) {
          if (isAvatar) {
            return CircleAvatar(
                backgroundImage: imageProvider, radius: avatarRadius);
          }

          return ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              child: Image(
                image: imageProvider,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
              ));
        },
        placeholder: (context, url) {
          if (isAvatar) {
            return CircleAvatar(
                backgroundColor: scheme.backgroundDark,
                radius: avatarRadius,
                child: Shimmer.avatar);
          }

          return ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              child: SizedBox(
                height: height,
                width: width,
                child: Shimmer.box,
              ));
        },
        errorWidget: (context, url, error) {
          logPrint(error, 'CachedImage');
          Image image = Image.asset(ImageRes.thumbnail,
              color: const Color(0xFFBDBDBD), fit: fit ?? BoxFit.cover);

          if (isAvatar) {
            image = Image.asset(ImageRes.userThumbnail, fit: BoxFit.cover);
            return CircleAvatar(
                backgroundColor: scheme.backgroundDark,
                radius: avatarRadius,
                child: Padding(padding: padding, child: image));
          }
          return ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius ?? 0),
              child: Container(
                  padding: padding,
                  color: scheme.backgroundDark,
                  height: height,
                  width: width,
                  child: image));
        });
  }
}
