import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key,})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ボタンの色設定
  static Color colorMain = Colors.indigo.shade100;
  static Color colorNum = Colors.blueGrey.shade900;
  static Color colorFunc = Colors.pinkAccent.shade200;
  static const Color colorText = Colors.white;

  // フォント設定
  static const String font = 'Roboto';

  // 画面上に表示する内容を格納する変数
  String text = "";

  // 値を表示する変数
  double displayedNumber = 0;

  // 現在値を格納する変数
  double _setCurrentNumber = 0;

  // 画面に出力できる最大値
  static const MAX_DEGIT = 9;

  //掛け算・割り算の結果を保持する変数
  double _memorialValue = 0;

  //足し算・引き算の結果を保持する変数
  double _previousValue = 0;

  //掛け算・割り算の演算子を記録しておく変数
  String _previousOperation = "";

  //足し算・引き算の演算子を記録しておく変数
  String _memorialOperation = "";

  // 小数点ボタンが押されたかどうかを示すbool値
  bool _decimalFlag = false;

  // "."が押された後の数値の数をカウントする変数
  int _numAfterPoint = 0;

  //桁区切り実装用
  intl.NumberFormat formatter = intl.NumberFormat('#,###.########', 'en_US');

  // 画面上部に出力するメッセージ
  String _cheeringMessage = "";

  // String型に変換したdisplayedNumber
  String displayedNumberAsString = "";

  // データベースに保存する計算式の部分を格納するリスト
  String formula = "";

  //入力値をセットするメソッド
  void input(String text) {
    setState(() {
      if (text == ".") {
      _decimalFlag = true;
      formula += '${text}';
    } else {
      int degit = getDegit(_setCurrentNumber);

      // 整数部分と少数部分を合わせて表示桁数が9桁以上は表示させない
      if (degit + _numAfterPoint == MAX_DEGIT) {
        //処理なし
      } else if (_decimalFlag) {
        _numAfterPoint++;
        if (displayedNumber >= 0) {
          _setCurrentNumber =
            _setCurrentNumber + int.parse(text) * math.pow(0.1, _numAfterPoint);
        } else {
          _setCurrentNumber =
          _setCurrentNumber - int.parse(text) * math.pow(0.1, _numAfterPoint);
        }
        // 整数を入力した時、初期状態だった時
      } else if (_setCurrentNumber == 0) {
        _setCurrentNumber = double.parse(text);
        // 連続入力対応
      } else {
        if (displayedNumber > 0) {
          _setCurrentNumber = _setCurrentNumber * 10 + double.parse(text);
        } else {
          _setCurrentNumber = _setCurrentNumber * 10 - double.parse(text);
        }
        
      }
      //最終的にgetDisplayTextメソッドに送る数値を決定
      displayedNumber = _setCurrentNumber;
      _cheeringMessage = "";
      formula += '${text}';
    }
    });
    
  }

  //画面表示用テキスト作成メソッド(小数点以下がない時は-1を取得)
  String getDisplayText(double value, {int numAfterPoint = -1}) {
    // 少数の時
    if (numAfterPoint != -1) {
      int intPart = value.toInt();
      // 初めて"."が押された時
      if (_decimalFlag == false && text.contains(".")) {
        return formatter.format(value);
      }
      else if (numAfterPoint == 0) {
        return formatter.format(value) + ".";
        // "1.003などへの対応
      } else if (intPart == value) {
        //文字列の足し算のため、「333」+「0.0」は「3330.0」となってしまうのを回避する
        return formatter.format(intPart) +
            (value - intPart).toStringAsFixed(numAfterPoint).substring(1);
      }
    }
    // 単なる整数の時
    return formatter.format(value);
  }

  //桁数を取得するメソッド
  int getDegit(double value) {
    int i = 0;
    if (value > 0) {
      for (; 10 <= value; i++) {
      value = value / 10;
      }
    } else {
      for (; value <= -10; i++) {
      value = value / 10;
    }
    }
    return i + 1;
  }

  // 数値の符号を切り替えるメソッド
  void _invertNum() {
    setState(() {
      displayedNumber = -displayedNumber;
      _setCurrentNumber = -_setCurrentNumber;
    });
  }

  // 一の位の数値を削除していくメソッド
  void _deleteOnesPlace() {
    setState(() {
      String displayedNumberAsString = displayedNumber.toString();
      // double型を文字列に変えたため、整数も小数もデフォルトで文字数が「3」になる
      if (displayedNumberAsString.length > 3) {
        // 単なる整数値の時（例：24.0)
        if (displayedNumberAsString[displayedNumberAsString.length - 1] ==
            "0") {
          displayedNumberAsString = displayedNumberAsString.substring(
              0, displayedNumberAsString.length - 3);
        } else {
          displayedNumberAsString = displayedNumberAsString.substring(
              0, displayedNumberAsString.length - 1);
        }
        // 小数点数で、「.000~」となるときは、double型に変換すると一気に「0.0」まで戻ってしまう
        if (displayedNumberAsString != "-") {
          displayedNumber = double.parse(displayedNumberAsString);
        }
        _numAfterPoint--;
        _decimalFlag = false;
      }
    });
  }

  // 画面上の数値をオールクリアするメソッド
  void _clearNum() {
    setState(() {
      displayedNumber = 0;
      _setCurrentNumber = 0;
      _previousValue = 0;
      _memorialValue = 0;
      _previousOperation = "";
      _memorialOperation = "";
      // _operatorTypeも初期化したい
      _decimalFlag = false;
      _cheeringMessage = "All Clear!";
      _numAfterPoint = 0;
    });
  }

  // 計算結果に応じて表示するメッセージを切り替えるメソッド
  void _getCheeringMessage() {
    setState(() {
      if (_previousOperation == "×") {
      _cheeringMessage = "Excellent!";
    } else if (displayedNumber == double.infinity || displayedNumber.toString() == 'NaN') {
      _cheeringMessage = "Sorry, but I have no idea...";
    } else if (_previousOperation == "÷") {
      _cheeringMessage = "Perfect!";
    } else if (_memorialOperation == "+") {
      _cheeringMessage = "Nice Job!";
    } else {
      _cheeringMessage = "Awesome!";
    } 
    });
  }

  // 途中計算を行うメソッド
  void _halfwayCalculation(String operatorType) {
    setState(() {
      if (operatorType == "×" || operatorType == "÷") {
      if (_previousOperation == "") {
        _previousValue = _setCurrentNumber;
      } else if (_previousOperation == "×") {
        //直前にセットされた値と新しく入力された値を掛ける
        _previousValue = _previousValue * _setCurrentNumber;
      } else {
        _previousValue = _previousValue / _setCurrentNumber;
      }
      displayedNumber = _previousValue;
      _setCurrentNumber = 0;
      _numAfterPoint = 0;
      _decimalFlag = false;
      _previousOperation = operatorType;
      formula += ' ${_previousOperation} ';
      // (1 × 4 + 2 × 4 + ...)などの掛け算の結果を足し合わせていく場合に対応
    } else if (operatorType == "+" || operatorType == "-") {
      if (_previousOperation == "×") {
        if (operatorType == "+" && _memorialOperation == "-") {
           _memorialValue = (_memorialValue - (_previousValue * _setCurrentNumber)).abs();
        } else if (operatorType == "+") {
          _memorialValue += (_previousValue * _setCurrentNumber);
        } else if (operatorType == "-" && _memorialOperation == "+") {
          _memorialValue += (_previousValue * _setCurrentNumber);
        } else {
          _memorialValue = (_memorialValue - (_previousValue * _setCurrentNumber)).abs();
        }
        _previousValue = 0;
        _previousOperation = "";
      } else if (_previousOperation == "÷") {
        if (operatorType == "+" && _memorialOperation == "-") {
          _memorialValue = (_memorialValue - (_previousValue / _setCurrentNumber)).abs();
        } else if (operatorType == "+") {
          _memorialValue += (_previousValue / _setCurrentNumber);
        } else if (operatorType == "-" && _memorialOperation == "+") {
          _memorialValue += (_previousValue / _setCurrentNumber);
        } else {
          _memorialValue = (_memorialValue - (_previousValue / _setCurrentNumber)).abs();
        }
        _previousValue = 0;
        _previousOperation = "";
      } else if (_memorialOperation == "") {
        _memorialValue = _setCurrentNumber;
      } else if (_memorialOperation == "+") {
        _memorialValue = _memorialValue + _setCurrentNumber;
      } else if (_memorialOperation == "-") {
        _memorialValue = _memorialValue - _setCurrentNumber;
      }

      displayedNumber = _memorialValue;
      _setCurrentNumber = 0;
      _numAfterPoint = 0;
      _decimalFlag = false;
      _memorialOperation = operatorType;
      formula += ' ${_memorialOperation} ';
    }
    });
  }

  // 最終的な計算結果を求めるメソッド
  void _finalCalculation() {
    setState(() {
      if (_previousOperation == "×" || _previousOperation == "÷") {
        double result = (_previousOperation == "×")
            ? _previousValue * _setCurrentNumber
            : _previousValue / _setCurrentNumber;
        
        displayedNumber = (_memorialOperation == "-")
            ? _memorialValue - result
            : _memorialValue + result;
      } else if (_memorialOperation == "+") {
        displayedNumber = _memorialValue + _setCurrentNumber;
      } else {
        displayedNumber = _memorialValue - _setCurrentNumber;
      }
      _getCheeringMessage();
      _setCurrentNumber = displayedNumber;
      _previousValue = 0;
      _memorialValue = 0;
      _numAfterPoint = 0;
      _decimalFlag = false;
      formula += ' =';
    });
  }
  
  // ボタンをウィジェット化
  Widget button(String text, Color colorButton, Color colorText) {
    return SizedBox(
      width: text == "0" ? 195 : 94,
      height: 87,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: ElevatedButton(
          onPressed: () async{
            switch (text) {
              case "AC":
                _clearNum();
                break;
              case "+/-":
                _invertNum();
                break;
              case "Del":
                _deleteOnesPlace();
                break;
              case "÷":
                _halfwayCalculation("÷");
                break;
              case "×":
                _halfwayCalculation("×");
                break;
              case "-":
                _halfwayCalculation("-");
                break;
              case "+":
                _halfwayCalculation("+");
                break;
              case "=":
                _finalCalculation();
                formula = "";
                break;
              default:
                input(text);
                break;
            }
          },
          style: ElevatedButton.styleFrom(
            primary: colorButton,
            onPrimary: colorText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: text == "0"
                ? const EdgeInsets.only(
                    left: 50.0, top: 20.0, right: 50.0, bottom: 20.0)
                : const EdgeInsets.all(8.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: font,
                fontWeight: FontWeight.bold,
                fontSize:
                    text == "+/-" || text == "AC" || text == "Del" ? 26 : 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // エミュレーター右上の「debug」という帯を消す
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: colorMain,
          // 計算履歴表示ボタンエリア
          appBar: AppBar(
            backgroundColor: colorNum,
            toolbarHeight: 75.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text("<< logout",
                          style: TextStyle(
                              fontFamily: font, fontSize: 20, color: colorText)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Icon(
                    FontAwesomeIcons.database,
                    color: colorFunc,
                  ),
                ),
                Text(
                  "database on",
                  style: TextStyle(
                    fontFamily: font,
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return Container();
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            final Offset begin = Offset(1.0, 0.0); // 右から左
                            // final Offset begin = Offset(-1.0, 0.0); // 左から右
                            const Offset end = Offset.zero;
                            final Animatable<Offset> tween =
                                Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: Curves.easeInOut));
                            final Animation<Offset> offsetAnimation =
                                animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Icon(FontAwesomeIcons.clockRotateLeft)),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // 計算結果表示エリア
              Expanded(
                flex: 1,
                child: Text(
                  _cheeringMessage,
                  style: TextStyle(
                      fontFamily: font,
                      fontSize: 34.0,
                      fontWeight: FontWeight.bold,
                      color: colorFunc),
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  child: Text(
                    (_decimalFlag) ?
      text = getDisplayText(displayedNumber, numAfterPoint: _numAfterPoint)
  : text = getDisplayText(displayedNumber),
    
                    style: TextStyle(
                        fontFamily: font, fontSize: 75.0, color: colorNum),
                  ),
                ),
              ),
              // ボタン表示エリア
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          button("AC", colorFunc, colorText),
                          button("+/-", colorFunc, colorText),
                          button("Del", colorFunc, colorText),
                          button("÷", colorFunc, colorText),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          button("7", colorNum, colorText),
                          button("8", colorNum, colorText),
                          button("9", colorNum, colorText),
                          button("×", colorFunc, colorText),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          button("4", colorNum, colorText),
                          button("5", colorNum, colorText),
                          button("6", colorNum, colorText),
                          button("-", colorFunc, colorText),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          button("1", colorNum, colorText),
                          button("2", colorNum, colorText),
                          button("3", colorNum, colorText),
                          button("+", colorFunc, colorText),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: <Widget>[
                          button("0", colorNum, colorText),
                          button(".", colorNum, colorText),
                          button("=", colorFunc, colorText),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}