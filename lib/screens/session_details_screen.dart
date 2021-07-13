import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aws_s3/providers/auth.dart';
import 'package:flutter_aws_s3/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class SessionDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session Details'),
      ),
      drawer: AppDrawer(),
      backgroundColor: Colors.white,
      body: auth.isSignedIn
          ? Container(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Item('Username', auth.getCurrentUser()),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Item('Used Logged In', auth.fetchSession()),
                  ),
                  UserAttributesWidget(auth.getUserAttributes()),
                ],
              ),
            )
          : Container(),
    );
  }
}

class Item extends StatelessWidget {
  final Future<String> future;
  final String keyName;
  const Item(this.keyName, this.future);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : SingleAttribute(
                  attribute: keyName,
                  value: snapshot.data as String,
                ),
    );
  }
}

class UserAttributesWidget extends StatelessWidget {
  final Future<List<AuthUserAttribute>> userAttributes;
  const UserAttributesWidget(this.userAttributes);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userAttributes,
      builder: (ctx, snapshot) {
        return snapshot.connectionState == ConnectionState.waiting
            ? CircularProgressIndicator()
            : Column(
                children: [
                  ...(snapshot.data as List<AuthUserAttribute>).map(
                    (attribute) {
                      return ListTile(
                        leading: _getIcon(attribute.userAttributeKey),
                        title: SingleAttribute(
                          attribute: attribute.userAttributeKey,
                          value: attribute.value,
                        ),
                      );
                    },
                  ).toList(),
                ],
              );
      },
    );
  }
}

Widget _getIcon(String key) {
  switch (key) {
    case 'email':
      return Icon(Icons.email_outlined);

    case 'phone_number_verified':
      return Icon(Icons.phone_android_outlined);

    case 'email_verified':
      return Icon(Icons.attach_email_rounded);

    case 'sub':
      return Icon(Icons.verified_user);

    default:
      return Icon(Icons.flutter_dash);
  }
}

class SingleAttribute extends StatelessWidget {
  const SingleAttribute(
      {Key? key, required this.attribute, required this.value})
      : super(key: key);

  final String attribute;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                '${attribute[0].toUpperCase() + attribute.substring(1, attribute.length)}',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
