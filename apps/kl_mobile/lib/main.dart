import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navi4all/util/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navi4all/view/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only portrait mode is currently supported
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const LotsenApp()));
}

class LotsenApp extends StatelessWidget {
  const LotsenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LotsenApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Navi4AllColors.klRed,
          primary: Navi4AllColors.klRed,
          secondary: Navi4AllColors.klPink,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const Splash(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
