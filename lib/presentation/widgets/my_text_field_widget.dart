import 'package:ampify/data/utils/exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatefulWidget {
  final Key? fieldKey;
  final String title;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextCapitalization? capitalization;
  final InputDecoration? decoration;
  final bool? expands;
  final int? maxLines;
  final int? maxLength;
  final bool isEmail;
  final bool isPass;
  final bool isNumber;
  final String? Function(String? value)? customValidator;
  final List<TextInputFormatter>? inputFormatters;
  const MyTextField(
      {super.key,
      this.fieldKey,
      required this.title,
      this.controller,
      this.keyboardType,
      this.focusNode,
      this.capitalization,
      this.maxLines = 1,
      this.maxLength,
      this.isEmail = false,
      this.isNumber = false,
      this.isPass = false,
      this.customValidator,
      this.inputFormatters,
      this.obscureText = false})
      : expands = false,
        decoration = null;

  const MyTextField._search({
    this.fieldKey,
    required this.title,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.capitalization,
    this.customValidator,
    this.inputFormatters,
    this.decoration,
  })  : maxLength = null,
        expands = false,
        obscureText = false,
        isEmail = false,
        isPass = false,
        isNumber = false,
        maxLines = 1;

  const MyTextField._custom({
    this.fieldKey,
    required this.title,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.capitalization,
    this.customValidator,
    this.inputFormatters,
    this.expands,
    this.maxLines,
    this.decoration,
  })  : maxLength = null,
        obscureText = false,
        isEmail = false,
        isPass = false,
        isNumber = false;

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isSelected = false;
  late bool obscureText;
  TextInputType? inputType;

  @override
  void initState() {
    obscureText = widget.obscureText;
    if (widget.isEmail) {
      inputType = widget.keyboardType ?? TextInputType.emailAddress;
    } else if (widget.isNumber) {
      inputType = widget.keyboardType ?? TextInputType.phone;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);

    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? inputType,
      obscureText: obscureText,
      focusNode: widget.focusNode,
      expands: widget.expands ?? false,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      autocorrect: false,
      textAlignVertical: widget.expands ?? false ? TextAlignVertical.top : null,
      textCapitalization: widget.capitalization ?? TextCapitalization.none,
      decoration: widget.decoration ??
          InputDecoration(
              suffixIcon: widget.obscureText
                  ? IconButton(
                      style: IconButton.styleFrom(
                          fixedSize: const Size.square(10)),
                      padding: EdgeInsets.zero,
                      splashRadius: 10,
                      selectedIcon: const Icon(Icons.visibility),
                      isSelected: isSelected,
                      onPressed: () {
                        setState(() {
                          isSelected = !isSelected;
                          obscureText = !obscureText;
                        });
                      },
                      icon: const Icon(Icons.visibility_off))
                  : null,
              label: Text(widget.title),
              labelStyle: TextStyle(fontSize: Dimens.fontXXLarge),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: scheme.primaryAdaptive),
              )),
      style: TextStyle(fontSize: Dimens.fontXXLarge),
      inputFormatters: widget.inputFormatters,
      validator: widget.customValidator ??
          (value) {
            if (value?.isEmpty ?? true) {
              return StringRes.errorEmpty(widget.title);
            } else if (widget.isEmail && !value!.isEmail) {
              return StringRes.errorEmail;
            } else if (widget.isPass && !value!.isStringPass) {
              return StringRes.errorCriteria;
            } else if (widget.isNumber &&
                (value?.length != 10 && value.runtimeType is! int)) {
              return StringRes.errorPhone;
            }
            return null;
          },
    );
  }
}

class SearchTextField extends StatelessWidget {
  final EdgeInsets? margin;
  final String title;
  final Key? fieldKey;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextCapitalization? capitalization;
  final double? borderRadius;
  final String? Function(String? value)? customValidator;
  final List<TextInputFormatter>? inputFormatters;
  final Color? backgroundColor;
  final Widget? trailing;
  const SearchTextField({
    super.key,
    this.margin,
    required this.title,
    this.fieldKey,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.borderRadius,
    this.trailing,
    this.capitalization,
    this.customValidator,
    this.backgroundColor,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final _borderRadius = BorderRadius.circular(
      borderRadius ?? Dimens.borderLarge,
    );

    InputBorder border() {
      return OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: scheme.backgroundDark),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: MyTextField._search(
        title: title,
        fieldKey: fieldKey,
        controller: controller,
        keyboardType: keyboardType,
        focusNode: focusNode,
        capitalization: capitalization,
        inputFormatters: inputFormatters,
        customValidator: (value) {
          return null;
        },
        decoration: InputDecoration(
            hintText: title,
            fillColor: backgroundColor,
            filled: backgroundColor != null,
            hintStyle:
                TextStyle(color: scheme.disabled, fontSize: Dimens.fontXXLarge),
            focusedBorder: border(),
            enabledBorder: border(),
            prefixIcon: Icon(Icons.search, color: scheme.disabled),
            suffixIcon: trailing),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final EdgeInsets? margin;
  final String title;
  final Key? fieldKey;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? expands;
  final int? maxLines;
  final TextCapitalization? capitalization;
  final String? Function(String? value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? defaultBorder;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const CustomTextField({
    super.key,
    this.margin,
    required this.title,
    this.fieldKey,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.expands,
    this.maxLines,
    this.capitalization,
    this.validator,
    this.inputFormatters,
    this.backgroundColor,
    this.defaultBorder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = ThemeServices.of(context);
    final radius = BorderRadius.circular(Dimens.borderDefault);

    InputBorder inputBorder() {
      return OutlineInputBorder(
        borderRadius: borderRadius ?? radius,
        borderSide: BorderSide(color: backgroundColor ?? scheme.background),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: MyTextField._custom(
        title: title,
        fieldKey: fieldKey,
        keyboardType: keyboardType,
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        expands: expands ?? false,
        capitalization: capitalization,
        customValidator: validator ?? (value) => null,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: title,
          fillColor: backgroundColor,
          filled: backgroundColor != null,
          hintStyle: TextStyle(color: scheme.disabled),
          focusedBorder: defaultBorder ?? false
              ? OutlineInputBorder(
                  borderSide: BorderSide(color: scheme.primaryAdaptive))
              : inputBorder(),
          enabledBorder: defaultBorder ?? false
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                  color: scheme.disabled,
                  width: 1.5,
                ))
              : inputBorder(),
        ),
      ),
    );
  }
}
