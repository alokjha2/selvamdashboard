import 'package:selvam_broilers/utils/colors.dart';
import 'package:selvam_broilers/utils/masked_text_formmatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final String hint;
  final bool? autoFocus;
  final TextEditingController? controller;
  final Function? onSubmitted;
  final Function? onChanged;
  final double? height;
  final double? width;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? textInputFormatter;
  final bool? readOnly;
  final FocusNode? focusNode;

  const CustomInputField(
      {Key? key,
      required this.hint,
      this.controller,
      this.onSubmitted,
      this.onChanged,
      this.autoFocus,
      this.height,
      this.width,
      this.keyboardType,
      this.textInputFormatter,
      this.readOnly,
      this.focusNode,
      this.validator})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 56,
      width: width ?? 240,
      child: TextFormField(
        controller: controller,
        autofocus: this.autoFocus ?? false,
        focusNode: this.focusNode,
        onFieldSubmitted: (String s) {
          onSubmitted?.call();
        },
        onChanged: (s) {
          onChanged?.call();
        },
        keyboardType: this.keyboardType ?? TextInputType.name,
        style: Theme.of(context).textTheme.bodyText2,
        inputFormatters: textInputFormatter,
        validator: this.validator,
        readOnly: this.readOnly ?? false,
        decoration: InputDecoration(
          focusedErrorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: const BorderRadius.all(
              const Radius.circular(6.0),
            ),
            borderSide: BorderSide(color: red, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: const BorderRadius.all(
              const Radius.circular(6.0),
            ),
            borderSide: BorderSide(color: red, width: 2),
          ),
          errorStyle: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: red, height: 0.5),
          labelText: hint,
          contentPadding: EdgeInsets.only(left: 10),
          errorMaxLines: 1,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(6.0),
            ),
            borderSide: BorderSide(color: primaryBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(6.0),
            ),
            borderSide: BorderSide(color: primaryBorder, width: 2),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: secondaryTextDark),
          fillColor: white,
          filled: true,
        ),
      ),
    );
  }
}

class CustomPasswordField extends StatelessWidget {
  final String hint;
  final bool? autoFocus;
  final TextEditingController? controller;
  final Function? onSubmitted;
  final double? height;
  final double? width;
  const CustomPasswordField(
      {Key? key,
      required this.hint,
      this.controller,
      this.onSubmitted,
      this.autoFocus,
      this.height,
      this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 46,
      width: width ?? 240,
      child: TextField(
        controller: controller,
        autofocus: this.autoFocus ?? false,
        obscureText: true,
        onSubmitted: (String s) {
          onSubmitted?.call();
        },
        obscuringCharacter: '*',
        keyboardType: TextInputType.visiblePassword,
        style: Theme.of(context).textTheme.bodyText2,
        decoration: InputDecoration(
          labelText: hint,
          contentPadding: EdgeInsets.only(left: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(6.0),
            ),
            borderSide: BorderSide(color: primaryBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(6.0),
            ),
            borderSide: BorderSide(color: primaryBorder, width: 2),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: secondaryTextDark),
          fillColor: white,
          filled: true,
        ),
      ),
    );
  }
}

class CustomPhoneInputField extends StatelessWidget {
  final String hint;
  final bool? autoFocus;
  final TextEditingController? numberController;
  final TextEditingController? isoController;
  final Function? onSubmitted;
  final double? height;
  final double width;
  final FormFieldValidator<String>? validator;
  final bool? readOnly;

  const CustomPhoneInputField(
      {Key? key,
      required this.hint,
      this.numberController,
      this.isoController,
      this.onSubmitted,
      this.autoFocus,
      this.height,
      this.validator,
      this.readOnly,
      required this.width})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: height ?? 60,
          width: 46,
          margin: EdgeInsets.only(right: 4),
          child: TextFormField(
            controller: isoController,
            autofocus: this.autoFocus ?? false,
            onFieldSubmitted: (String s) {
              onSubmitted?.call();
            },
            keyboardType: TextInputType.number,
            readOnly: this.readOnly ?? false,
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 5, right: 5),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(6.0),
                ),
                borderSide: BorderSide(color: primaryBorder, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(6.0),
                ),
                borderSide: BorderSide(color: primaryBorder, width: 2),
              ),
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: secondaryTextDark),
              fillColor: transparent,
              filled: true,
            ),
          ),
        ),
        Container(
          height: height ?? 60,
          width: width - 50,
          child: TextFormField(
            controller: numberController,
            autofocus: this.autoFocus ?? false,
            onFieldSubmitted: (String s) {
              onSubmitted?.call();
            },
            keyboardType: TextInputType.number,
            style: Theme.of(context).textTheme.bodyText2,
            inputFormatters: [
              MaskedTextInputFormatter(mask: 'xxxxxxxxxx', separator: ''),
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: this.validator,
            readOnly: this.readOnly ?? false,
            decoration: InputDecoration(
              focusedErrorBorder: OutlineInputBorder(
                gapPadding: 0,
                borderRadius: const BorderRadius.all(
                  const Radius.circular(6.0),
                ),
                borderSide: BorderSide(color: red, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                gapPadding: 0,
                borderRadius: const BorderRadius.all(
                  const Radius.circular(6.0),
                ),
                borderSide: BorderSide(color: red, width: 2),
              ),
              errorStyle: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: red, height: 0.5),
              labelText: hint,
              contentPadding: EdgeInsets.only(left: 10),
              errorMaxLines: 1,
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(6.0),
                ),
                borderSide: BorderSide(color: primaryBorder, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(6.0),
                ),
                borderSide: BorderSide(color: primaryBorder, width: 2),
              ),
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: secondaryTextDark),
              fillColor: white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSearchInputField extends StatelessWidget {
  final String hint;
  final bool? autoFocus;
  final TextEditingController? controller;
  final Function? onSubmitted;
  final Function? onChanged;
  final Function? onClear;
  final double? height;
  final double? width;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? textInputFormatter;

  const CustomSearchInputField(
      {Key? key,
      required this.hint,
      this.controller,
      this.onSubmitted,
      this.autoFocus,
      this.height,
      this.width,
      this.keyboardType,
      this.onChanged,
      this.textInputFormatter,
      this.validator,
      this.onClear})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 40,
      width: width ?? MediaQuery.of(context).size.width * .25,
      child: TextFormField(
        controller: controller,
        autofocus: this.autoFocus ?? false,
        onFieldSubmitted: (String s) {
          onSubmitted?.call(s);
        },
        onChanged: (String s) {
          onChanged?.call(s);
        },
        keyboardType: this.keyboardType ?? TextInputType.name,
        style: Theme.of(context).textTheme.bodyText2,
        inputFormatters: textInputFormatter,
        validator: this.validator,
        decoration: InputDecoration(
          hintText: this.hint,
          focusedErrorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: const BorderRadius.all(
              const Radius.circular(12.0),
            ),
            borderSide: BorderSide(color: red, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: const BorderRadius.all(
              const Radius.circular(12.0),
            ),
            borderSide: BorderSide(color: red, width: 2),
          ),
          errorStyle: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: red, height: 0.5),
          contentPadding: EdgeInsets.only(left: 10),
          errorMaxLines: 1,
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(12.0),
            ),
            borderSide: BorderSide(color: primaryBorder, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(12.0),
            ),
            borderSide: BorderSide(color: primaryBorder, width: 2),
          ),
          hintStyle: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: secondaryTextDark),
          fillColor: white,
          filled: true,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 24,
            color: secondaryTextDark,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: secondaryTextDark,
            ),
            onPressed: () {
              this.onClear?.call();
            },
          ),
        ),
      ),
    );
  }
}
