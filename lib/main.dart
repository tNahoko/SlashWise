import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:slash_wise/models/notifiers.dart';
import 'package:slash_wise/models/user_auth.dart';
import 'package:slash_wise/screens/group_screen.dart';
import 'package:slash_wise/screens/setting_screen.dart';
import 'package:slash_wise/screens/wrapper.dart';
import 'package:slash_wise/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:slash_wise/services/dbServiceExpense.dart';
import "package:slash_wise/services/dbServiceGroup.dart";
import 'package:slash_wise/services/dbServiceUser.dart';
import './models/user.dart' as userModel;

import 'models/dbGroup.dart';
import 'models/expense.dart';

FirebaseAuth auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
  }

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return MultiProvider(
      providers: [
        StreamProvider<AuthUser>.value(
          initialData: null,
          value: AuthService().user,
        ),
        StreamProvider<List<DbGroup>>.value(
          initialData: [],
          value: DatabaseServiceGroup().groups(),
        ),
        StreamProvider<List<userModel.User>>.value(
          initialData: [],
          value: DatabaseServiceUser().users(),
        ),
        StreamProvider<List<Expense>>.value(
          initialData: [],
          value: DatabaseServiceExpense().expenses(),
        ),
        ChangeNotifierProvider<MultipleNotifier>(
          create: (_) => MultipleNotifier([]),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.indigo, fontFamily: 'RobotoCondensed'),
        initialRoute: '/',
        routes: {
          '/': (context) => Wrapper(),
          GroupScreen.routeName: (context) => GroupScreen(),
          SettingScreen.routeName: (context) => SettingScreen(),
        },
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<AuthUser>.value(
//       initialData: null,
//       value: AuthService().user,
//       child: MaterialApp(
//         theme: ThemeData(primarySwatch: Colors.purple),
//         initialRoute: '/',
// routes: {
//   '/': (context) => Wrapper(),
//   GroupScreen.routeName: (context) => GroupScreen(),
// },
//       ),
//     );
//   }
// }
