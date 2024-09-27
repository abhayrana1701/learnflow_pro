import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';


class Getdetails extends StatefulWidget {
  final String docid;
  const Getdetails({required this.docid});

  @override
  State<Getdetails> createState() => _GetdetailsState();
}

class _GetdetailsState extends State<Getdetails> {







  Future<List<int>> createListOfZeroes() async {

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.docid)
          .get();

      if (documentSnapshot.exists) {
        // Assuming the array field is called 'exampleArray'
        List<dynamic> array = documentSnapshot['subunits'];

        // Get the length of the array
        int arrayLength = array.length;

        // Create a list of zeroes with a length equal to the array length
        List<int> listOfZeroes = List<int>.filled(arrayLength, 0);

        // Now you can use the listOfZeroes variable for your purposes
        print(' $listOfZeroes');

        return listOfZeroes;
      } else {
        print('Error');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }





  Future<void> enrollcourse() async {


    try {
      // Get the current user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
        // User is signed in, get the user's unique ID
        String userId = user!.uid;

        // Get a reference to the Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Create a new collection with the user's unique ID as the document ID
        await firestore.collection("enrolledcourses").doc().set({
          'courseenrolled': widget.docid,
          'userid':userId,
          'status':"Not Started",
          'length':await createListOfZeroes()

        });

        print('Success');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              backgroundColor: Color.fromRGBO(238, 28, 57, 1),
              title: Text("You have enrolled in this course successfully.",
                  style: TextStyle(color: Colors.white)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Ok",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(30))),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),

                ],
              )));

    } catch (e) {
      print('Error creating collection: $e');
    }
  }




  Future<bool> isCourseEnrolled() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      // User is signed in, get the user's unique ID
      String userId = user!.uid;
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Perform a query to check if the document exists
      var querySnapshot = await firestore
          .collection("enrolledcourses")
          .where('userid', isEqualTo: userId).where('courseenrolled',isEqualTo: widget.docid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return true if documents exist
        return true;
      } else {
        // Return false if no documents are found
        return false;
      }
    } catch (e) {
      print('Error checking document existence: $e');
      return false; // Handle the error as needed
    }
  }








  int index = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Details", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('courses')
              .doc(widget.docid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Document does not exist');
            }

            // Access the data from the document
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var coursename = data['coursename'];
            var maindescription = data['maindescription'];
            var duration = data['courseduration'];

            // If the field is an array, you can access its elements
            var skills = data['skills'] as List<dynamic>;
            var units = data['units'] as List<dynamic>;
            var subunits = data['subunits'] as List<dynamic>;
            var subunitslength = data['subunitlength'] as List<dynamic>;

            return Padding(
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    coursename,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "About this Course",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ReadMoreText(
                    maindescription,
                    trimLines: 3,
                    style: TextStyle(color: Colors.black),
                    trimMode: TrimMode.Line,
                    trimCollapsedText: "show more",
                    trimExpandedText: "show less",
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.grey,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 12,
                          child: Icon(Icons.access_time_outlined,
                              color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "100% Online",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 56),
                      Text(
                          "Start instantly and learn at your own schedule"),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.grey,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 12,
                          child: Icon(Icons.list_alt_sharp,
                              color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Course Deadline",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 56),
                      Text("Flexible Deadline"),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.grey,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 12,
                          child: Icon(Icons.access_time,
                              color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Approx. ${duration} hours to complete",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Skills You Will Gain",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: skills.map((text) {
                      return Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(text),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Syllabus: What will you learn in this course",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: ExpansionPanelList(
                      dividerColor: Colors.white,
                      animationDuration: Duration(seconds: 1),
                      elevation: 0,
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          if (index == panelIndex) {
                            index = -1;
                          } else {
                            index = panelIndex;
                          }
                        });
                      },
                      children: units.map((unit) {
                        int unitIndex = units.indexOf(unit);
                        return ExpansionPanel(
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              title: Text(
                                "Unit ${unitIndex + 1} $unit",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                          canTapOnHeader: true,
                          body: ListView.builder(
                            shrinkWrap: true,
                            itemCount: subunitslength[unitIndex], // Replace with your actual item count
                            itemBuilder: (context, itemIndex) {
                              int sum=0;
                              for(int i=0;i<unitIndex;i++){
                                sum=sum+subunitslength[i] as int;
                              }
                              return ListTile(
                                title: Text(subunits[sum+itemIndex]),
                              );
                            },
                          ),
                          isExpanded: index == unitIndex,
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height:20),
                  SizedBox(
                    width:MediaQuery.of(context).size.width,
                    height:50,
                    child: ElevatedButton(
                        onPressed: () async {
                          if(await isCourseEnrolled()){
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                    backgroundColor: Color.fromRGBO(238, 28, 57, 1),
                                    title: Text("You have already enrolled in this course",
                                        style: TextStyle(color: Colors.white)),
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Ok",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(Radius.circular(30))),
                                            backgroundColor: Colors.white,
                                          ),
                                        ),

                                      ],
                                    )));
                          }
                          else{
                            enrollcourse();

                          }
                        },
                        child: Text("Enroll Now",style: TextStyle(color:Colors.white),),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                        backgroundColor: Color.fromRGBO(0,50,173,1),
                      ),
                    ),
                  ),
                  SizedBox(height:50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
