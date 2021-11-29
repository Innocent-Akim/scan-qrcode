import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';

final flashOnController = TextEditingController(text: "Flash on");
final flashOffController = TextEditingController(text: "Flash off");
final cancelController = TextEditingController(text: "Cancel");
var aspectTolerance = 0.00;
var numberOfCameras = 0;
var selectedCamera = -1;
var useAutoFocus = true;
var autoEnableFlash = false;
ScanResult qrResultat;
int possitionCamera = -1;
bool bl = false;
String result;
