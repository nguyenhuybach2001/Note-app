import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/components/side_bar.dart';
import 'package:note_app/screens/note_editor.dart';
import 'package:note_app/screens/note_reader.dart';
import 'package:note_app/style/app_style.dart';
import 'dart:io';
import 'package:note_app/widgets/note_card.dart';

import '../auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0), // here the desired height
        child: AppBar(

          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu,color: Colors.redAccent,),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          title: Row(
            children: [
              Center(
                child: Text(
                  "Notes App",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              // DropdownButtonHideUnderline(
              //   child: DropdownButton2(
              //     focusNode: null,
              //     customButton: Container(
              //       child: CircleAvatar(
              //         radius: 25,
              //         backgroundImage: AssetImage("images/avatar.png"),
              //       ),
              //       margin: EdgeInsets.only(bottom: 13, top: 25),
              //     ),
              //     customItemsHeights: [
              //       ...List<double>.filled(MenuItems.firstItems.length, 30),
              //       8,
              //       ...List<double>.filled(MenuItems.secondItems.length, 30),
              //     ],
              //     items: [
              //       ...MenuItems.firstItems.map(
              //         (item) => DropdownMenuItem<MenuItem>(
              //           value: item,
              //           child: MenuItems.buildItem(item),
              //         ),
              //       ),
              //       const DropdownMenuItem<Divider>(
              //           enabled: false, child: Divider()),
              //       ...MenuItems.secondItems.map(
              //         (item) => DropdownMenuItem<MenuItem>(
              //           value: item,
              //           child: MenuItems.buildItem(item),
              //         ),
              //       ),
              //     ],
              //     onChanged: (value) {
              //       MenuItems.onChanged(context, value as MenuItem);
              //     },
              //     itemHeight: 20,
              //     itemPadding: const EdgeInsets.only(left: 16),
              //     dropdownWidth: 125,
              //     dropdownPadding: const EdgeInsets.symmetric(vertical: 8),
              //     dropdownDecoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(10),
              //       color: Color.fromARGB(255, 255, 237, 80),
              //     ),
              //     dropdownElevation: 8,
              //     offset: const Offset(0, 8),
              //   ),
              // ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/Tet.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your recent Notes",
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Notes")
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    //checking the connection state, if we still load the data we can display a progress bar
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData) {
                      return GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        children: snapshot.data!.docs
                            .where((element) =>
                                element["user_id"] ==
                                AuthController().getUserID())
                            .map((note) => noteCard(() {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NoteReaderScreen(note)));
                                }, note))
                            .toList(),
                      );
                    }
                    return Text(
                      "No Notes",
                      style: GoogleFonts.nunito(color: Colors.white),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NoteEditorScreen()));
        },
        label: const Text("Add note"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static String imageUrl = "";
  static void UploadImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 200,
        maxWidth: 200,
        imageQuality: 75);
    Reference ref = FirebaseStorage.instance.ref().child("images/avatar.png");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) => {imageUrl = value});
  }

  static const List<MenuItem> firstItems = [avatar];
  static const List<MenuItem> secondItems = [logout];

  static const avatar = MenuItem(text: 'Avatar', icon: Icons.person);
  static const logout = MenuItem(text: 'Log Out', icon: Icons.logout);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Color.fromARGB(255, 255, 9, 9), size: 18),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.avatar:
        {
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
                      print(imageUrl);
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  )
                ],
              );
            },
          );
        }
        break;
      case MenuItems.logout:
        AuthController.instance.logOut();
        break;
    }
  }
}
