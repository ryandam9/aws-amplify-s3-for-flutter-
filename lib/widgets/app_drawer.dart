import 'package:flutter/material.dart';
import 'package:flutter_aws_s3/providers/auth.dart';
import 'package:flutter_aws_s3/screens/home_page.dart';
import 'package:flutter_aws_s3/screens/image_picker_screen.dart';
import 'package:flutter_aws_s3/screens/login_screen.dart';
import 'package:flutter_aws_s3/screens/session_details_screen.dart';
import 'package:flutter_aws_s3/screens/show_images_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: Text('AWS Amplify For Flutter'),
              automaticallyImplyLeading: false,
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => HomePage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Show Session Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => SessionDetailsScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cloud_upload),
              title: Text('Upload Images'),
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => SelectImage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cloud_download),
              title: Text('Download Images'),
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => ListBucketScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                // Signout the user
                await auth.signOut();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => AuthScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
