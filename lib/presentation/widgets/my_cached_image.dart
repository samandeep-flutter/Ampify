import 'package:ampify/data/utils/exports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyCachedImage extends StatefulWidget {
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
  State<MyCachedImage> createState() => _MyCachedImageState();
}

class _MyCachedImageState extends State<MyCachedImage> {
  Widget _builder(bool isAvatar, bool loading) {
    final scheme = context.scheme;

    return Builder(builder: (context) {
      final _path = isAvatar ? ImageRes.userThumbnail : ImageRes.thumbnail;
      final _radius = widget.avatarRadius ?? Dimens.sizeLarge;
      final _thumbnail = Padding(
          padding: EdgeInsets.all(isAvatar ? _radius * .7 : Dimens.iconXLarge),
          child: Image.asset(_path,
              color: scheme.backgroundDark, fit: widget.fit ?? BoxFit.cover));

      if (isAvatar) {
        return CircleAvatar(
            backgroundColor: scheme.shimmer,
            radius: widget.avatarRadius,
            child: loading ? Shimmer.avatar : _thumbnail);
      }
      return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
          child: Container(
              color: scheme.shimmer,
              height: widget.height,
              width: widget.width,
              child: loading ? Shimmer.box : _thumbnail));
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.image?.isEmpty ?? true) || widget.loading) {
      return _builder(widget.isAvatar, widget.loading);
    }

    return CachedNetworkImage(
        imageUrl: widget.image!,
        fit: widget.fit ?? BoxFit.cover,
        height: widget.height,
        width: widget.width,
        imageBuilder: (context, provider) {
          if (widget.isAvatar) {
            return CircleAvatar(
                backgroundImage: provider, radius: widget.avatarRadius);
          }

          return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
              child: Image(
                  image: provider,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit ?? BoxFit.cover));
        },
        placeholder: (_, url) {
          return _builder(widget.isAvatar, widget.loading);
        },
        errorWidget: (_, url, error) {
          logPrint(error, 'cached-image');
          return _builder(widget.isAvatar, widget.loading);
        });
  }
}
