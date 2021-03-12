import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slash_wise/models/dbGroup.dart';
import 'package:slash_wise/models/user_auth.dart';
import 'package:slash_wise/screens/group_screen.dart';
import 'package:slash_wise/services/dbServiceGroup.dart';

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final groupDatabase = DatabaseServiceGroup();

  _deleteGroup(String groupID) {
    groupDatabase.deleteGroup(groupID);
  }

  @override
  Widget build(BuildContext context) {
    List<DbGroup> groupList = Provider.of<List<DbGroup>>(context);
    final authUser = Provider.of<AuthUser>(context);

    var filteredGroupList =
        groupList.where((group) => group.users.contains(authUser.uid)).toList();

    return Container(
      height: 600,
      child: (filteredGroupList.isEmpty)
          ? Column(
              children: <Widget>[Text('No Group added yet!')],
            )
          : ListView.builder(
              itemBuilder: (_, index) {
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Text('Picture'),
                    ),
                    title: Text(filteredGroupList[index].name),
                    subtitle: Text(
                      DateFormat.yMMMd().format(filteredGroupList[index].date),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.exit_to_app),
                      color: Theme.of(context).errorColor,
                      onPressed: () =>
                          _deleteGroup(filteredGroupList[index].id),
                    ),
                    onTap: () {
                      // pass to the GroupScreen _groupList[index]
                      Navigator.pushNamed(context, GroupScreen.routeName,
                          arguments: filteredGroupList[index]);
                    },
                  ),
                );
              },
              itemCount: filteredGroupList.length,
            ),
    );
  }
}
