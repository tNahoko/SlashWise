import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:slash_wise/models/dbGroup.dart';
import 'package:slash_wise/models/expense.dart';
import 'package:slash_wise/models/user.dart';
import 'package:slash_wise/models/user_auth.dart';
import 'package:slash_wise/services/dbServiceExpense.dart';
import 'package:slash_wise/services/dbServiceGroup.dart';
import 'package:slash_wise/services/dbServiceUser.dart';
import 'package:slash_wise/widgets/new_expense.dart';

class GroupScreen extends StatefulWidget {
  static const routeName = '/group';

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

List<User> team = [];
Map<String, num> owe = {};

class _GroupScreenState extends State<GroupScreen> {
  final expenseDatabase = DatabaseServiceExpense();
  final userDatabase = DatabaseServiceUser();
  final _emailController = TextEditingController();

  String _showUsernameByID(String userID) {
    String username = "";

    for (int i = 0; i < team.length; i++) {
      if (team[i].id == userID) {
        username = team[i].name;
      }
    }

    return username;
  }

  void _showNewExpense(BuildContext context, String userID, String groupID) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return NewExpense(userID, groupID);
        });
  }

  void _generalPaymentDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Pay Everyone'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text('Pay With Cash'),
                    onPressed: () {}, // TODO make the payment function
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void _singlePaymentDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Pay Individualy'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text('Pay With Cash'),
                    onPressed: () {}, // TODO make the payment function
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text('Pay With PayPal'),
                    onPressed: () {}, // TODO make the payment function
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void _submitData(String groupID) async {
    if (_emailController.text.isEmpty) return;
    final enteredEmail = _emailController.text;
    var result = 'User doesn\'t exist';

    var userToAdd = await DatabaseServiceUser().getUserByEmail(enteredEmail);
    if (userToAdd != null) {
      result = 'User successfully added';
      DatabaseServiceGroup().addMemberToGroup(groupID, enteredEmail);
      setState(() {
        print('setState() called when add a member');
        team.add(userToAdd);
        print(team);
      });
    }
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        action: SnackBarAction(label: 'Clear', onPressed: () {}),
      ),
    );
  }

  void _createAddMemberDialog(BuildContext context, String groupID) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Add member'),
            content: TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                icon: Icon(Icons.group_add),
              ),
              controller: _emailController,
              onSubmitted: (_) => () {
                _submitData(groupID);
              },
            ),
            actions: [
              ElevatedButton(
                child: Text('Add Member'),
                onPressed: () => _submitData(groupID),
              ),
            ],
          );
        });
  }

  // forEach

  // DbGroup -> List of User ids -> Send all user ids to backend using the getUser method 8
  void _getListUsers(DbGroup group, String currUserID) {
    userDatabase.getUsers(group.users).then((value) => setState(() {
          print('setState called() 1');
          var filteredList =
              value.where((user) => user.id != currUserID).toList();

          team = filteredList;
          print(team);
        }));
  }

  void _getOtherExpenses(String userID, String groupID) {
    expenseDatabase
        .calculateExpenses(userID, groupID)
        .then((owes) => setState(() {
              print('setState called() 2');
              owe = owes;
            }));
  }

  //var userID;
  //var group;

  @override
  void didChangeDependencies() {
    var userID = Provider.of<AuthUser>(context).uid;
    var group = ModalRoute.of(context).settings.arguments as DbGroup;
    final allGroup = Provider.of<List<DbGroup>>(context);

    group = allGroup.firstWhere((oneGroup) => oneGroup.id == group.id);

    _getOtherExpenses(userID, group.id);
    _getListUsers(group, userID);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final userID = Provider.of<AuthUser>(context).uid;
    final group = ModalRoute.of(context).settings.arguments as DbGroup;

    // All expenses from the database - NEEDS TO BE FILTERED
    final allExpenses = Provider.of<List<Expense>>(context);

    // Expenses made by group
    var filteredExpenses =
        allExpenses.where((expense) => expense.groupID == group.id).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group Details'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.payment),
              onPressed: () => _generalPaymentDialog(context),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _createAddMemberDialog(context, group.id),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Members'),
              Tab(text: 'Expenses'),
            ],
          ),
        ),
        body: TabBarView(children: [
          // First page *********************************=>
          Column(
            children: [
              Container(
                height: 150,
                color: Theme.of(context).colorScheme.background,
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    ClipOval(
                      child: Image.network(
                        "https://he.cecollaboratory.com/public/layouts/images/group-default-logo.png",
                        fit: BoxFit.cover,
                        width: 70.0,
                        height: 70.0,
                      ),
                    ),
                    Text(
                      group.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(DateFormat.yMMMd().format(group.date)),
                  ],
                ),
              ),
              Expanded(
                child: team.length > 0
                    ? Container(
                        child: ListView.builder(
                          itemBuilder: (_, index) {
                            return Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: ListTile(
                                  leading: ClipOval(
                                      child: Image.network(
                                    "https://thumbs.dreamstime.com/b/default-avatar-profile-flat-icon-social-media-user-vector-portrait-unknown-human-image-default-avatar-profile-flat-icon-184330869.jpg",
                                    fit: BoxFit.cover,
                                    width: 60.0,
                                    height: 60.0,
                                  )),
                                  title: Text(
                                    team[index].name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      owe[team[index].name] != null
                                          ? owe[team[index].name] < 0
                                              ? Text(
                                                  '¥ ${owe[team[index].name].abs().toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .errorColor),
                                                )
                                              : Text(
                                                  '¥ ${owe[team[index].name].toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                )
                                          : Text(
                                              '¥ \$0',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .errorColor),
                                            ),
                                      IconButton(
                                        icon: Icon(Icons.payment),
                                        onPressed: () =>
                                            _singlePaymentDialog(context),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: team.length,
                        ),
                      )
                    : Center(
                        child: Text(
                          'No Members Added Yet!',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
              )
            ],
          ),
          // Second page ********************************=>
          Expanded(
            child: filteredExpenses.length > 0
                ? Container(
                    child: ListView.builder(
                      itemBuilder: (_, index) {
                        return Card(
                          elevation: 4,
                          //margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 30,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset(
                                      'assets/money.png',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                filteredExpenses[index].name,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(_showUsernameByID(
                                          filteredExpenses[index].payer) ==
                                      ''
                                  ? 'Remunerator: You'
                                  : 'Remunerator: ${_showUsernameByID(filteredExpenses[index].payer)}'),
                              trailing: Text(
                                '\¥ ${filteredExpenses[index].amount}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: filteredExpenses.length,
                    ),
                  )
                : Center(
                    child: Text(
                      'No Expenses Added Yet!',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
          )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showNewExpense(context, userID, group.id),
          child: Icon(Icons.add), // Add a member to the team
        ),
      ),
    );
  }
}
