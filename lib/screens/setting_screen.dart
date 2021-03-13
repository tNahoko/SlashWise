import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slash_wise/models/user.dart';
import 'package:slash_wise/models/user_auth.dart';
import 'package:slash_wise/services/dbServiceUser.dart';
import 'package:image_picker/image_picker.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

void _createWipPopup(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Work In Progress'),
          content: Text('Please Come Back Later!'),
          actions: [
            ElevatedButton(
              child: Text('Ok'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      });
}

void _usernamePopup(
    BuildContext context, User currUser, TextEditingController userInput) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Change Username'),
          content: TextField(
            decoration: InputDecoration(
              hintText: currUser.name,
              icon: Icon(Icons.attribution_outlined),
            ),
            controller: userInput,
            onSubmitted: (_) =>
                () => _submitUsername(userInput, currUser, context),
          ),
          actions: [
            ElevatedButton(
              child: Text('Change'),
              onPressed: () => _submitUsername(userInput, currUser, context),
            ),
          ],
        );
      });
}

void _createLogoPopup(BuildContext context, File file, Function pickImage) {
  showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Change Logo'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  child: Text('Choose an Image'),
                  onPressed: pickImage,
                ),
                file != null
                    ? Text('No file selected!')
                    : Text(file.toString()),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text('Apply'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      });
}

void _submitUsername(TextEditingController newUsernameController, User currUser,
    BuildContext context) async {
  if (newUsernameController.text.isEmpty) return;
  final enteredName = newUsernameController.text;

  await DatabaseServiceUser().changeUserName(currUser.id, enteredName);

  Navigator.of(context).pop();
  Navigator.of(context).pop();
  Navigator.of(context).pop();
}

Widget createSettingButton(String settingButtonName, Function action) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20),
      ),
      onPressed: action,
      child: Text(
        settingButtonName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
  );
}

class _SettingScreenState extends State<SettingScreen> {
  File file;
  void pickImage() async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      file = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAuthID = Provider.of<AuthUser>(context).uid;
    final allUsers = Provider.of<List<User>>(context);

    final userDatabase = DatabaseServiceUser();
    final _usernameController = TextEditingController();

    final currUser = allUsers.firstWhere((user) => user.id == userAuthID);

    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              createSettingButton("Change Logo",
                  () => _createLogoPopup(context, file, pickImage)),
              createSettingButton(
                  "Change Email", () => _createWipPopup(context)),
              createSettingButton(
                "Change Username",
                () => _usernamePopup(context, currUser, _usernameController),
              ),
              createSettingButton(
                  "Change Password", () => _createWipPopup(context)),
            ],
          ),
        ));
  }
}
