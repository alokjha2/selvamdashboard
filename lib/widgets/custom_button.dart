import '../utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final bool? filled;
  final Color? color;
  final double? height;
  final double? width;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.filled,
    this.color,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height ?? 46,
      width: this.width,
      child: filled ?? true
          ? ElevatedButton(
              child: Text(
                text,
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                onPressed();
              },
              style: ElevatedButton.styleFrom(
                primary: color ?? primaryButton,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            )
          : OutlinedButton(
              child: Text(
                text,
                style: Theme.of(context).textTheme.button,
              ),
              onPressed: () {
                onPressed();
              },
              style: ElevatedButton.styleFrom(
                side: BorderSide(width: 2.0, color: primaryButton),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final Function onSelectPressed;
  final Function onClearPressed;
  final String label;
  final Color? color;
  final double? height;
  final double width;
  final String? fileName;
  const UploadButton(
      {Key? key,
      required this.onSelectPressed,
      required this.onClearPressed,
      required this.label,
      this.color,
      this.height,
      required this.width,
      this.fileName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.height ?? 46,
      width: this.width,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.all(
          Radius.circular(6.0),
        ),
        border: Border.all(color: primaryBorder, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                label,
                style:
                    Theme.of(context).textTheme.bodyText2!.copyWith(height: 1),
              ),
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(right: 5),
              height: 30,
              decoration: BoxDecoration(
                color: gray,
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0),
                ),
              ),
              child: this.fileName == null || this.fileName!.isEmpty
                  ? Container(
                      child: TextButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 14,
                              color: white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Select file',
                              style: Theme.of(context).textTheme.button!,
                            )
                          ],
                        ),
                        onPressed: () {
                          this.onSelectPressed();
                        },
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          constraints:
                              BoxConstraints(maxWidth: this.width * 0.35),
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            this.fileName ?? '',
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(color: primaryTextDark, fontSize: 9),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 24,
                            height: 24,
                            child: IconButton(
                              iconSize: 14,
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: red,
                              ),
                              onPressed: () {
                                this.onClearPressed();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Function onPressed;
  final Widget icon;
  final double? height;
  final double? width;

  const CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height ?? 40,
        width: width ?? 40,
        child: Material(
          color: transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            child: icon,
            onTap: () {
              onPressed();
            },
          ),
        ));
  }
}
