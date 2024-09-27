import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'docourse.dart';
import 'getdetails.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class Enrolledcourses extends StatefulWidget {
  const Enrolledcourses({super.key});

  @override
  State<Enrolledcourses> createState() => _EnrolledcoursesState();
}

class _EnrolledcoursesState extends State<Enrolledcourses> {



  void showerror(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(color: Colors.white),),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.fromRGBO(238,28,57,1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void showsuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: TextStyle(color: Colors.white),),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context,String _url) async {
    String? message;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Download image
      final http.Response response = await http.get(Uri.parse(_url));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create an image name
      var filename = '${dir.path}/certificate.jpg';

      // Save to filesystem
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      // Ask the user to save it
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        message = 'Certificate saved to device.';
        showsuccess(context, message);
      }
    } catch (e) {
      message = 'An error occurred while saving the certificate.';
      showerror(context, message);
      print(e);
    }

  }






  List<Map<String, dynamic>> enrolledCoursesData = [];
  final ValueNotifier<double> progressNotifier = ValueNotifier<double>(50);
  List colors=[Colors.red,Colors.limeAccent,Colors.deepOrange,Colors.lightBlue];




  Future<bool> checkcompletionforcertificate(String docId) async {
    try {
      // Get the collection reference
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('enrolledcourses');

      // Query the collection with the conditions
      QuerySnapshot querySnapshot = await collectionReference
          .where('courseenrolled', isEqualTo: docId)
          .where('userid', isEqualTo:  FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if there are documents matching the conditions
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (you can modify this based on your requirements)
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        // Check if the 'length' field exists in the document

          List<dynamic> lengthArray = documentSnapshot['length'] as List<dynamic>;
          for(int i=0;i<lengthArray.length;i++){
            if(lengthArray[i]==0){
              return false;
            }
          }
          return true;

      } else {
        // No documents found with the given conditions
        return false;
      }
    } catch (e) {
      // Handle errors
      print('Error fetching length array from Firebase: $e');
      return false;
    }
  }





  Future<ValueNotifier<double>> fetchLengthArray(String docId) async {
    try {
      // Get the collection reference
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('enrolledcourses');

      // Query the collection with the conditions
      QuerySnapshot querySnapshot = await collectionReference
          .where('courseenrolled', isEqualTo: docId)
          .where('userid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if there are documents matching the conditions
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (you can modify this based on your requirements)
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;


          List<dynamic> lengthArray = documentSnapshot['length'] as List<dynamic>;
        double progressValue = calculateProgress(lengthArray);
        return ValueNotifier<double>(progressValue);

      } else {
        // No documents found with the given conditions
        return ValueNotifier<double>(0.0);
      }
    } catch (e) {
      // Handle errors
      print('Error fetching length array from Firebase: $e');
      return ValueNotifier<double>(0.0);
    }
  }

  double calculateProgress(List<dynamic> lengthArray) {
    int one=0;
    for(int i=0;i<lengthArray.length;i++){
      if(lengthArray[i]!=0){
        one++;
      }
    }
    return (one/lengthArray.length)*100;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enrolled Courses",
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
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                "Courses in which you have enrolled.",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('enrolledcourses')
                    .where('userid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  var userDocs = (snapshot.data as QuerySnapshot).docs;

                  enrolledCoursesData = userDocs
                      .map<Map<String, dynamic>>((enrolledCourse) => {
                    'courseId': enrolledCourse['courseenrolled'],
                    // Add more fields as needed
                  })
                      .toList();

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .snapshots(),
                    builder: (context, courseSnapshot) {
                      if (!courseSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator(color:  Color.fromRGBO(238,28,57,1),));
                      }

                      var courseDocs =
                          (courseSnapshot.data as QuerySnapshot).docs;

                      // Filter courses based on enrollment
                      var enrolledCourses = courseDocs
                          .where((course) => userDocs.any((enrolledCourse) =>
                              enrolledCourse['courseenrolled'] == course.id))
                          .toList();

                      return ListView.builder(
                        itemCount: enrolledCourses.length,
                        itemBuilder: (context, index) {
                          var data = enrolledCourses[index].data()
                              as Map<String, dynamic>;
                          var coursename =
                              data['coursename'] ?? 'Default Value';
                          var shortdescription =
                              data['shortdesciption'] ?? 'Default Value';
                          var coursethumbnail = data['thumbnailpath'] ?? '';
                          var certificate=data["certificatepath"]??'';
                          var docid = enrolledCourses[index].id ?? '';
                          var courseData = enrolledCoursesData[index];
                          var courseId = courseData['courseId'] as String;

                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      ),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(),
                                        child: Image.network(
                                          coursethumbnail,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Text(
                                              coursename,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 30,
                                              ),
                                            ),
                                            alignment: Alignment.centerLeft,
                                          ),
                                         SizedBox(height:20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.3,
                                                height: MediaQuery.of(context).size.width * 0.3,
                                                child: FutureBuilder<ValueNotifier<double>>(
                                                  future: fetchLengthArray(docid),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      ValueNotifier<double> progressNotifier = snapshot.data!;
                                                      return SimpleCircularProgressBar(
                                                        valueNotifier: progressNotifier,
                                                        progressColors: [colors[(index)%4]],
                                                        backColor: Color.fromRGBO(200, 200, 200, 1),
                                                        mergeMode: true,
                                                        onGetText: (double value) {
                                                          double roundedValue = double.parse(value.toStringAsFixed(0));
                                                          return Text(
                                                            '$roundedValue',
                                                            style: const TextStyle(
                                                              fontSize: 30,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black,
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      return CircularProgressIndicator(color:  Color.fromRGBO(238,28,57,1),);
                                                    }
                                                  },
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: MediaQuery.of(context).size.width * 0.1,
                                                    width: MediaQuery.of(context).size.width * 0.6 - 30,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => Getdetails(docid: docid),
                                                          ),
                                                        );
                                                      },
                                                      child: Text("View Course"),
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        backgroundColor: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                                                  SizedBox(
                                                    height: MediaQuery.of(context).size.width * 0.1,
                                                    width: MediaQuery.of(context).size.width * 0.6 - 30,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => Docourse(docid: docid),
                                                          ),
                                                        );
                                                      },
                                                      child: Text("Do Course"),
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(
                                                            Radius.circular(5),
                                                          ),
                                                        ),
                                                        backgroundColor: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context).size.width*0.1,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: ElevatedButton(
                                              onPressed: () async{


                                                if(await checkcompletionforcertificate(docid)){
                                                  print("yes");
                                                  _saveImage(context,certificate);
                                                }
                                                else{
                                                  showerror(context,"You must complete the course in order to get the certificate.");
                                                }
                                              },
                                              child:Text("Get Certificate"),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 50),
                            ],
                          );
                        },
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      );
                    },
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
