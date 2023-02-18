import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../auth_controller.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String imageUrl = "";
  void UploadImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
        maxWidth: 200,
        imageQuality: 75);
    Reference ref = FirebaseStorage.instance.ref().child("images/avatar.png");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Oflutter.com'),
            accountEmail: Text('example@gmail.com'),
            currentAccountPicture: GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                child: ClipOval(
                  child: imageUrl == ""
                      ? Image(
                          image: AssetImage('images/avatar.png'),
                          width: 150,
                          height: 150,
                        )
                      : Image.network(
                          imageUrl,
                          width: 150,
                          height: 150,
                        ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Avatar'),
            onTap: () => {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Avatar'),
                    content: imageUrl == ""
                        ? Image(
                            image: AssetImage('images/avatar.png'),
                            width: 150,
                            height: 150,
                          )
                        : Image.network(
                            imageUrl,
                            width: 150,
                            height: 150,
                          ),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            UploadImage();
                            Navigator.pop(context);
                          },
                          child: Text('Upload')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      )
                    ],
                  );
                },
              ),
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.notifications),
          //   title: Text('Request'),
          // ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Settings'),
          //   onTap: () => null,
          // ),
          // ListTile(
          //   leading: Icon(Icons.description),
          //   title: Text('Policies'),
          //   onTap: () => null,
          // ),
          ListTile(
            title: Text('LogOut'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => AuthController.instance.logOut(),
          ),
        ],
      ),
    );
  }
}
