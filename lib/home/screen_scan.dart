import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scan/app/constantes.dart';

class ScreenScan extends StatefulWidget {
  @override
  _ScreenScanState createState() => _ScreenScanState();
}

class _ScreenScanState extends State<ScreenScan> {
  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);
  bool canVibrate = true;
  List<BarcodeFormat> selectedFormats = [..._possibleFormats];
  final scan = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Center(
              child: TextField(
                controller: scan,
                onTap: () {
                  setState(() {
                    initScane(scanner: scanCard(inforCarte));
                  });
                },
                decoration: InputDecoration(
                  hintText: "Clic ici pour scan",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future scanCard(Function function) async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": cancelController.text,
          "flash_on": flashOnController.text,
          "flash_off": flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: possitionCamera,
        autoEnableFlash: autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: aspectTolerance,
          useAutoFocus: useAutoFocus,
        ),
      );
      var resultat = await BarcodeScanner.scan(options: options);
      setState(() async {
        qrResultat = resultat;
        if (qrResultat.rawContent.length > 0) {
          setState(() {
            function(qrResultat.rawContent);
          });

          // idCarte.text = qrResultat.rawContent;

        }
      });
    } on PlatformException catch (_) {
      if (_.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          print("Camera permissin was denied");
        });
      } else {
        setState(() {
          print("Unknown Error $_");
        });
      }
    } on FormatException {
      setState(() {
        print("You pressed the back button before scanning anithing");
      });
    } catch (_) {
      setState(() {
        print("Unknown Error $_");
      });
    }
  }

  inforCarte(value) {
    scan.text = value;
  }

  initScane({void scanner}) {
    var contentList = <Widget>[
      if (qrResultat != null)
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Result Type"),
                subtitle: Text(qrResultat.type?.toString() ?? ""),
              ),
              ListTile(
                title: Text("Raw Content"),
                subtitle: Text(qrResultat.rawContent ?? ""),
              ),
              ListTile(
                title: Text("Format"),
                subtitle: Text(qrResultat.format?.toString() ?? ""),
              ),
              ListTile(
                title: Text("Format note"),
                subtitle: Text(qrResultat.formatNote ?? ""),
              ),
            ],
          ),
        ),
      ListTile(
        title: Text("Camera selection"),
        dense: true,
        enabled: false,
      ),
      RadioListTile(
        onChanged: (v) => setState(() => selectedCamera = -1),
        value: -1,
        title: Text("Default camera"),
        groupValue: selectedCamera,
      ),
    ];
    for (var i = 0; i < numberOfCameras; i++) {
      contentList.add(RadioListTile(
        onChanged: (v) => setState(() => selectedCamera = i),
        value: i,
        title: Text("Camera ${i + 1}"),
        groupValue: selectedCamera,
      ));
    }

    contentList.addAll([
      ListTile(
        title: Text("Button Texts"),
        dense: true,
        enabled: false,
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Flash On",
          ),
          controller: flashOnController,
        ),
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Flash Off",
          ),
          controller: flashOffController,
        ),
      ),
      ListTile(
        title: TextField(
          decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            labelText: "Cancel",
          ),
          controller: cancelController,
        ),
      ),
    ]);

    if (Platform.isAndroid) {
      contentList.addAll([
        ListTile(
          title: Text("Android specific options"),
          dense: true,
          enabled: false,
        ),
        ListTile(
          title:
              Text("Aspect tolerance (${aspectTolerance.toStringAsFixed(2)})"),
          subtitle: Slider(
            min: -1.0,
            max: 1.0,
            value: aspectTolerance,
            onChanged: (value) {
              setState(() {
                aspectTolerance = value;
              });
            },
          ),
        ),
        CheckboxListTile(
          title: Text("Use autofocus"),
          value: useAutoFocus,
          onChanged: (checked) {
            setState(() {
              useAutoFocus = checked;
            });
          },
        )
      ]);
    }

    contentList.addAll([
      ListTile(
        title: Text("Other options"),
        dense: true,
        enabled: false,
      ),
      CheckboxListTile(
        title: Text("Start with flash"),
        value: autoEnableFlash,
        onChanged: (checked) {
          setState(() {
            autoEnableFlash = checked;
          });
        },
      )
    ]);

    contentList.addAll([
      ListTile(
        title: Text("Barcode formats"),
        dense: true,
        enabled: false,
      ),
      ListTile(
        trailing: Checkbox(
          tristate: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: selectedFormats.length == _possibleFormats.length
              ? true
              : selectedFormats.length == 0
                  ? false
                  : null,
          onChanged: (checked) {
            setState(() {
              selectedFormats = [
                if (checked ?? false) ..._possibleFormats,
              ];
            });
          },
        ),
        dense: true,
        enabled: false,
        title: Text("Detect barcode formats"),
        subtitle: Text(
          'If all are unselected, all possible platform formats will be used',
        ),
      ),
    ]);

    contentList.addAll(
      _possibleFormats.map(
        (format) => CheckboxListTile(
          value: selectedFormats.contains(format),
          onChanged: (i) {
            setState(() => selectedFormats.contains(format)
                ? selectedFormats.remove(format)
                : selectedFormats.add(format));
          },
          title: Text(format.toString()),
        ),
      ),
    );
  }
}
