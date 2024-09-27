import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'getdetails.dart';

class Mycourses extends StatefulWidget {
  const Mycourses({super.key});

  @override
  State<Mycourses> createState() => _MycoursesState();
}

class _MycoursesState extends State<Mycourses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Courses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(238, 28, 57, 1),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height:25),
            Padding(
              padding:  EdgeInsets.only(left:15,right:15),
              child: Text("Courses uploaded by you.",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            SizedBox(height:25),
            Padding(
              padding:  EdgeInsets.only(left:15,right:15),
              child: StreamBuilder(
                stream:FirebaseFirestore.instance.collection('courses').where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator(color:  Color.fromRGBO(238,28,57,1),)); // Loading indicator while fetching data
                  }

                  var documents = (snapshot.data as QuerySnapshot).docs;
                  List<Widget> items = [];

                  for (var document in documents) {
                    var data = document.data() as Map<String, dynamic>;
                    var coursename = data['coursename'] ?? 'Default Value';
                    var shortdescription = data['shortdesciption'] ?? 'Default Value';
                    var coursethumbnail = data['thumbnailpath'] ?? '';
                    var docid=data['docid']??'';
                    items.add(
                      Container(
                        alignment: Alignment.topCenter,
                        // height: MediaQuery.of(context).size.height * 0.45,
                        // width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(2, 2))
                            ]),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  //  color:Colors.orange,
                                ),
                                child: Image.network(
                                  coursethumbnail,
                                  fit: BoxFit.cover,
                                ),),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.04,
                                left: MediaQuery.of(context).size.width * 0.04,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      //  color:Colors.green,
                                    ),
                                    child: Text(
                                      coursename,
                                      style:
                                      TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      //color:Colors.green,
                                    ),
                                    child: Text(
                                      shortdescription,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Getdetails(docid: docid),));
                                      },
                                      child: Text("View Course"),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5))),
                                        backgroundColor: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),),
                    );
                  }

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          items[index],
                          SizedBox(height:50)
                        ],
                      );
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  );
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}
