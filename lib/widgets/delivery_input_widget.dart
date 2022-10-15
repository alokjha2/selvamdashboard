import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selvam_broilers/utils/colors.dart';
import 'package:selvam_broilers/utils/flags.dart';
import 'custom_button.dart';
import 'custom_input.dart';

class DeliveryInputController {
  late Function getAllInputValues;
}

class DeliveryInputWidget extends StatefulWidget {
  final Function? onBoxCountChanged;
  final Function? onSmallCountChanged;
  final Function? onRegularCountChanged;
  final Function? onRegularTotalKGChanged;
  final Function? onSmallTotalKGChanged;
  final bool isOrderComplete;
  final String orderID;
  final DeliveryInputController? controller;

  DeliveryInputWidget({
    Key? key,
    required this.onBoxCountChanged,
    required this.onSmallCountChanged,
    required this.onRegularCountChanged,
    required this.onRegularTotalKGChanged,
    required this.onSmallTotalKGChanged,
    required this.isOrderComplete,
    required this.orderID,
    this.controller,
  }) : super(key: key);

  @override
  _DeliveryInputWidgetState createState() => _DeliveryInputWidgetState();
}

class _DeliveryInputWidgetState extends State<DeliveryInputWidget> {
  List<DeliveryInputBoxWidget> _deliveryInputWidgets = [];

  @override
  void initState() {
    super.initState();
    //fetching previous values from the local storage
    if (!widget.isOrderComplete) {
      widget.controller?.getAllInputValues = () {
        Map data = {};
        data['count'] = _deliveryInputWidgets.length;
        for (int i = 0; i < _deliveryInputWidgets.length; i++) {
          var inputWidget = _deliveryInputWidgets[i];
          data['${i}_birdCount'] = inputWidget.birdCount;
          data['${i}_boxCount'] = inputWidget.boxCount;
          data['${i}_emptyWight'] = inputWidget.emptyWight;
          data['${i}_loadWight'] = inputWidget.loadWight;
          data['${i}_chickenType'] = inputWidget.chickenType.index;
        }
        return data;
      };
    }

    _addDeliveryInputItem(chickenType: ChickenType.REGULAR);
    _addDeliveryInputItem(chickenType: ChickenType.SMALL);
  }

  void _addDeliveryInputItem({
    required ChickenType chickenType,
    int? boxCount,
    int? birdCount,
    double? emptyWight,
    double? loadWight,
  }) {
    bool _isRegularChicken = chickenType == ChickenType.REGULAR;
    var inputWidget = DeliveryInputBoxWidget(
        chickenType: chickenType,
        boxCount: boxCount ?? 0,
        birdCount: birdCount ?? 0,
        emptyWight: emptyWight ?? 0,
        loadWight: loadWight ?? 0,
        onBirdCountChanged: (int value) {
          if (_isRegularChicken) {
            _calculateRegularTotalCount();
          } else {
            _calculateSmallTotalCount();
          }
        },
        onBoxCountChanged: (int value) {
          _calculateBoxTotal();
        },
        onLoadWeightChanged: (double value) {
          if (_isRegularChicken) {
            _calculateRegularTotalKG();
          } else {
            _calculateSmallTotalKG();
          }
        },
        onEmptyWeightChanged: (double value) {
          if (_isRegularChicken) {
            _calculateRegularTotalKG();
          } else {
            _calculateSmallTotalKG();
          }
        },
        readOnly: false);
    _deliveryInputWidgets.add(inputWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: grayLite, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Details',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              CustomIconButton(
                height: 24,
                icon: PopupMenuButton<String>(
                  onSelected: (String val) {
                    if (val == 'regular') {
                      _addDeliveryInputItem(chickenType: ChickenType.REGULAR);
                    } else if (val == 'small') {
                      _addDeliveryInputItem(chickenType: ChickenType.SMALL);
                    }

                    setState(() {});
                  },
                  child: Icon(Icons.add),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      child: Text('Samll'),
                      value: 'small',
                    ),
                    PopupMenuItem<String>(
                      child: Text('Regular'),
                      value: 'regular',
                    ),
                  ],
                ),
                onPressed: () {},
              )
            ],
          ),
          Divider(
            color: grayDark,
          ),
          SizedBox(height: 15),
          ..._deliveryInputWidgets,
        ],
      ),
    );
  }

  void _calculateBoxTotal() {
    int boxTotal = 0;
    _deliveryInputWidgets.forEach((element) {
      boxTotal += element.boxCount;
    });
    widget.onBoxCountChanged?.call(boxTotal);
  }

  void _calculateSmallTotalCount() {
    int smallTotal = 0;
    _deliveryInputWidgets.forEach((element) {
      if (element.chickenType == ChickenType.SMALL) {
        smallTotal += element.birdCount;
      }
    });
    widget.onSmallCountChanged?.call(smallTotal);
  }

  void _calculateRegularTotalCount() {
    int regularTotal = 0;
    _deliveryInputWidgets.forEach((element) {
      if (element.chickenType == ChickenType.REGULAR) {
        regularTotal += element.birdCount;
      }
    });
    widget.onRegularCountChanged?.call(regularTotal);
  }

  void _calculateRegularTotalKG() {
    double loadTotal = 0;
    _deliveryInputWidgets.forEach((element) {
      if (element.chickenType == ChickenType.REGULAR) {
        loadTotal += element.loadWight;
      }
    });

    double emptyWeight = 0;
    _deliveryInputWidgets.forEach((element) {
      if (element.chickenType == ChickenType.REGULAR) {
        emptyWeight += element.emptyWight;
      }
    });

    widget.onRegularTotalKGChanged?.call(loadTotal - emptyWeight);
  }

  void _calculateSmallTotalKG() {
    double loadTotal = 0;
    _deliveryInputWidgets.forEach((element) {
      if (element.chickenType == ChickenType.SMALL) {
        loadTotal += element.loadWight;
      }
    });

    double emptyWeight = 0;
    _deliveryInputWidgets.forEach((element) {
      if (element.chickenType == ChickenType.SMALL) {
        emptyWeight += element.emptyWight;
      }
    });

    widget.onSmallTotalKGChanged?.call(loadTotal - emptyWeight);
  }
}

class DeliveryInputBoxWidget extends StatefulWidget {
  final Function? onBoxCountChanged;
  final Function? onBirdCountChanged;
  final Function? onLoadWeightChanged;
  final Function? onEmptyWeightChanged;
  final Function? getValueList;
  final bool? readOnly;
  final ChickenType chickenType;

  int boxCount = 0; //will be updated internally
  int birdCount = 0; //will be updated internally
  double emptyWight =
      0; //will be updated externally by the _showScaleInputDialog()
  double loadWight =
      0; //will be updated externally by the _showScaleInputDialog()

  DeliveryInputBoxWidget({
    Key? key,
    this.onBirdCountChanged,
    this.onBoxCountChanged,
    this.onLoadWeightChanged,
    this.onEmptyWeightChanged,
    this.getValueList,
    this.readOnly,
    required this.boxCount,
    required this.birdCount,
    required this.emptyWight,
    required this.loadWight,
    required this.chickenType,
  }) : super(key: key);

  @override
  _DeliveryInputBoxWidgetState createState() => _DeliveryInputBoxWidgetState();
}

class _DeliveryInputBoxWidgetState extends State<DeliveryInputBoxWidget> {
  TextEditingController loadWeight = TextEditingController();
  TextEditingController emptyWeight = TextEditingController();
  TextEditingController birdCount = TextEditingController();
  TextEditingController boxCount = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.loadWight > 0) {
      loadWeight =
          TextEditingController(text: widget.loadWight.toStringAsFixed(2));
    }
    if (widget.emptyWight > 0) {
      emptyWeight =
          TextEditingController(text: widget.emptyWight.toStringAsFixed(2));
    }
    if (widget.birdCount > 0) {
      birdCount = TextEditingController(text: widget.birdCount.toString());
    }
    if (widget.boxCount > 0) {
      boxCount = TextEditingController(text: widget.boxCount.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(widget.chickenType == ChickenType.REGULAR ? 'Regular' : 'Small',
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: secondaryTextDark)),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          CustomInputField(
            controller: boxCount,
            keyboardType: TextInputType.number,
            hint: 'Boxes',
            width: 60,
            textInputFormatter: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: () {
              widget.boxCount = int.tryParse(boxCount.text.trim()) ?? 0;
              widget.onBoxCountChanged?.call(widget.boxCount);
            },
            readOnly: widget.readOnly,
          ),
          SizedBox(width: 5),
          CustomInputField(
            controller: loadWeight,
            keyboardType: TextInputType.number,
            hint: 'Load',
            width: 70,
            textInputFormatter: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: () {
              widget.loadWight = double.tryParse(loadWeight.text.trim()) ?? 0;
              widget.onLoadWeightChanged?.call(widget.loadWight);
            },
          ),
          SizedBox(width: 5),
          CustomInputField(
            controller: emptyWeight,
            keyboardType: TextInputType.number,
            hint: 'Empty',
            width: 70,
            textInputFormatter: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: () {
              widget.emptyWight = double.tryParse(emptyWeight.text.trim()) ?? 0;
              widget.onEmptyWeightChanged?.call(widget.emptyWight);
            },
          ),
          SizedBox(width: 5),
          CustomInputField(
            controller: birdCount,
            keyboardType: TextInputType.number,
            hint: 'Birds',
            width: 60,
            textInputFormatter: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: () {
              widget.birdCount = int.tryParse(birdCount.text.trim()) ?? 0;
              widget.onBirdCountChanged?.call(widget.birdCount);
            },
            readOnly: widget.readOnly,
          )
        ]),
      ),
    ]);
  }
}
