import 'package:flutter/material.dart';
import 'package:flutter_aws_s3/widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AWS Amplify for Flutter'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '''AWS Amplify is a set of tools and services that can be used together or on their own, to help front-end web and mobile developers build scalable full stack applications, powered by AWS.
          ''',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
