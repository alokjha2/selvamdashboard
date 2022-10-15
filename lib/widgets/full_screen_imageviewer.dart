import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:selvam_broilers/utils/colors.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'dart:html' as html;

import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String url;
  final String fileName;

  const FullScreenImageViewer(
      {Key? key, required this.url, required this.fileName})
      : super(key: key);
  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    String? mimeType = mime(basename(widget.fileName));
    final String? extension = extensionFromMime(mimeType!);

    return Container(
      width: size.width * 0.95,
      height: size.height * 0.95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size.width * 0.95,
            height: size.height * 0.83,
            child: extension == 'pdf'
                ? SfPdfViewer.network(widget.url)
                : CachedNetworkImage(
                    imageUrl: widget.url,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    placeholder: (context, url) => Text('Loading...',
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: gray)),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: red,
                    ),
                  ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                  width: 120,
                  height: 40,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Close'),
              SizedBox(
                width: 60,
              ),
              CustomButton(
                  width: 120,
                  height: 40,
                  onPressed: () {
                    html.window.open(widget.url, "_blank");
                  },
                  text: 'Download')
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
