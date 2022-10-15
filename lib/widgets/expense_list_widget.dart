import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:selvam_broilers/services/expenses_db.dart';
import 'package:selvam_broilers/utils/utils.dart';
import 'package:selvam_broilers/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:selvam_broilers/widgets/custom_input.dart';
import '../../utils/colors.dart';

class ExpenseItemListWidget extends StatefulWidget {
  @override
  _ExpenseItemListWidgetState createState() => _ExpenseItemListWidgetState();
}

class _ExpenseItemListWidgetState extends State<ExpenseItemListWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _expenseList = [];
  TextEditingController _labelController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ExpensesDatabase().listenExpenseListItems().listen((doc) {
      setState(() {
        _expenseList = List.from(doc.get('expense_items'));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: Container(
              width: 400,
              height: 500,
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0),
                ),
                border: Border.all(
                  color: primaryBorder,
                ),
              ),
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                primary: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 20),
                            child: Text(
                              'Expenses List',
                              style: Theme.of(context).textTheme.headline2!,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 50,
                              child: TextButton(
                                child: Icon(Icons.add),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      _labelController.text = '';
                                      final GlobalKey<FormState> _formKey =
                                          GlobalKey<FormState>();

                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                8.0)), //this right here
                                        child: Container(
                                          width: 200,
                                          // height: 100,
                                          padding: EdgeInsets.all(20),
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Add Item',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2!,
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        CustomInputField(
                                                            width: 200,
                                                            hint: 'Label text',
                                                            controller:
                                                                _labelController,
                                                            validator: (value) {
                                                              return value!
                                                                          .length <
                                                                      3
                                                                  ? 'Enter valid label'
                                                                  : _expenseList
                                                                          .contains(
                                                                              value)
                                                                      ? 'Label already exists.'
                                                                      : null;
                                                            }),
                                                        SizedBox(height: 10),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                _isLoading
                                                    ? CircularProgressIndicator()
                                                    : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CustomButton(
                                                              width: 100,
                                                              height: 36,
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              text: 'Cancel'),
                                                          SizedBox(width: 20),
                                                          CustomButton(
                                                            onPressed:
                                                                () async {
                                                              if (!_formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                return;
                                                              }

                                                              if (_expenseList.contains(
                                                                  _labelController
                                                                      .text
                                                                      .trim())) {
                                                                return;
                                                              }
                                                              _showOverlayProgress();
                                                              _expenseList.add(
                                                                  _labelController
                                                                      .text
                                                                      .trim());
                                                              bool res = await ExpensesDatabase()
                                                                  .updateExpenseItemList(
                                                                      _expenseList);
                                                              if (res) {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Label Created!",
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity: ToastGravity
                                                                        .CENTER,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        primary,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0,
                                                                    webBgColor:
                                                                        'linear-gradient(to right, #292A31, #292A31)');
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                        "Unable to create. Try again.",
                                                                    toastLength: Toast
                                                                        .LENGTH_SHORT,
                                                                    gravity:
                                                                        ToastGravity
                                                                            .CENTER,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    textColor: Colors
                                                                        .white,
                                                                    webBgColor:
                                                                        'linear-gradient(to right, #ff0000, #ff0000)',
                                                                    fontSize:
                                                                        16.0);
                                                                _expenseList.remove(
                                                                    _labelController
                                                                        .text
                                                                        .trim());
                                                              }
                                                              _hideOverlayProgress();
                                                            },
                                                            text: 'Add',
                                                            width: 100,
                                                            height: 36,
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        ]),
                    Container(
                      color: Colors.white,
                      child: Table(
                        border: TableBorder(
                            top: BorderSide(color: primaryBorder),
                            bottom: BorderSide(color: primaryBorder),
                            left: BorderSide(color: primaryBorder),
                            right: BorderSide(color: primaryBorder),
                            verticalInside: BorderSide(color: transparent),
                            horizontalInside:
                                BorderSide(color: primaryBorder, width: 1)),
                        columnWidths: {
                          0: FlexColumnWidth(10),
                          1: FlexColumnWidth(5),
                        },
                        children: [
                          _header(),
                          ..._dataRow(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          CustomButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            text: 'Close',
            width: 100,
            height: 36,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  List<TableRow> _dataRow() {
    List<TableRow> rows = [];
    _expenseList.forEach((item) {
      rows.add(TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Text(item, style: Theme.of(context).textTheme.bodyText2),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Material(
                child: InkWell(
                  child: Icon(
                    Icons.delete_rounded,
                    size: 20,
                    color: red,
                  ),
                  onTap: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('Confirmation'),
                        content: Text('Sure want to delete $item?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                _expenseList.remove(item);
                              });

                              bool res = await ExpensesDatabase()
                                  .updateExpenseItemList(_expenseList);
                              if (res) {
                                Navigator.pop(context);
                                showToast(message: 'Label deleted!');
                              } else {
                                _expenseList.add(item);
                                showToast(
                                    message: 'Operation Failed!', color: red);
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ]));
    });

    if (rows.length < 1) {
      rows.add(TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Text('-',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: Text('-',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.w800)),
        ),
      ]));
    }

    return rows;
  }

  TableRow _header() {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text('Label',
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.w800)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text('Action',
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.w800)),
      ),
    ]);
  }

  void _showOverlayProgress() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideOverlayProgress() {
    setState(() {
      _isLoading = false;
    });
  }
}
