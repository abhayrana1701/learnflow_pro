import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<Map<String, dynamic>> getAllFields() async {
    // Replace 'your_collection' with the name of your Firestore collection
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Access all fields from the document data
    Map<String, dynamic> fields = document.data() as Map<String, dynamic>;

    return fields;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getAllFields(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child:CircularProgressIndicator(color:  Color.fromRGBO(238,28,57,1),)),);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Access the fields using snapshot.data
          var fieldsData = snapshot.data;
          return Scaffold(
            body: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      //color:Colors.yellow
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.4,
                      color: Color.fromRGBO(238, 28, 57, 1),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: MediaQuery.of(context).size.height * 0.2 / 2,
                        child: Text(
                          "${fieldsData!['name']?.substring(0, 1) ?? ''}",
                          style: TextStyle(
                            color: Color.fromRGBO(238, 28, 57, 1),
                            fontSize: MediaQuery.of(context).size.height * 0.2 / 2,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.4 -
                            MediaQuery.of(context).size.height * 0.08 / 2,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color.fromRGBO(238, 28, 57, 1), // Set the border color here
                            width: 2.0, // Set the border width here
                          ),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.08 / 2,
                          //color:Colors.yellow,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text("${fieldsData!['name'] ?? ''}"),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.4 +
                            MediaQuery.of(context).size.height * 0.08 / 2 +
                            20,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color.fromRGBO(238, 28, 57, 1), // Set the border color here
                            width: 2.0, // Set the border width here
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.08 / 3,
                                //color:Colors.yellow,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text("${fieldsData!['email'] ?? ''}"),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.08 / 4,
                                // color:Colors.green,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text("E-mail"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.4 +
                            MediaQuery.of(context).size.height * 0.08 +
                            MediaQuery.of(context).size.height * 0.08 +
                            10,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color.fromRGBO(238, 28, 57, 1), // Set the border color here
                            width: 2.0, // Set the border width here
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * 0.08 / 3,
                                //color:Colors.yellow,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text("${fieldsData!['age'] ?? ''} years"),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.08 / 4,
                                // color:Colors.green,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text("Age"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
