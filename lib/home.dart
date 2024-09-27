import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:mainproject/signin.dart";
import "package:shared_preferences/shared_preferences.dart";
import "enrolledcourses.dart";
import "getdetails.dart";
import "mycourses.dart";
import "myprofile.dart";
import "signup.dart";
import "uploadcourse.dart";
import 'package:flutter_share/flutter_share.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
boll toggle=false;
  Color color1=  Color.fromRGBO(238, 28, 57, 1);
  Color color2= Color.fromRGBO(200, 200, 200, 1);
  Color color3= Color.fromRGBO(200, 200, 200, 1);
  Color color4= Color.fromRGBO(200, 200, 200, 1);

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
      print('Password reset email sent to $email');
      showsuccess(context, "Password reset email sent to $email");
    } catch (e) {
      // Handle errors such as invalid email, user not found, etc.
      print('Error sending password reset email: $email');
      showerror(context,"Error sending password reset email: $email");
    }
  }


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


  Future<Map<String, String>> getUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Assuming you have a 'users' collection and 'name' and 'email' fields
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshot.exists) {
      String username = userSnapshot.data()?['name'] ?? 'Default Name';
      String email = userSnapshot.data()?['email'] ?? 'Default Email';

      return {'username': username, 'email': email};
    } else {
      return {'username': 'Default Name', 'email': 'Default Email'};
    }
  }




  Future<void> shareapp() async {
    await FlutterShare.share(
        title: 'share',
        text: 'Download Learnflow Pro now to engage in process of sharing and learning',
        linkUrl: 'https://flutter.dev/',
        chooserTitle: 'Share Learnflow Pro');
  }

  List categoryselected=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] ;
  List checkcategory=[];
  List categorieslist=['Technology and Programming','Business and Entrepreneurship','Creative Arts','Personal Development','Language Learning','Health and Fitness','Science and Math','Humanities','Test Preparation','Industry-Specific Courses','Specializations and Certifications','Hobbies and Interests','Academic Subjects','Programming Languages','Social Sciences','Others'];
  Widget categories(){
    return ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: categorieslist.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Row(
            children: [
              InkWell(
                child: Container(
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(categorieslist[index]),
                  ),
                  decoration: BoxDecoration(
                    border: categoryselected[index]==0 ? Border.all(color: Colors.black):Border.all(color:Color.fromRGBO(238,28,57,1)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onTap: (){
                  setState(() {
                    if(categoryselected[index]==0){
                      categoryselected[index]=1;
                      checkcategory.add(categorieslist[index]);
                    }
                    else{
                      categoryselected[index]=0;
                      checkcategory.remove(categorieslist[index]);
                    }
                  });
                  print(checkcategory);
                },
              ),
              SizedBox(width:15),
            ],
          );
        },
    );
  }



  void signout() async{
      try {
        // Sign out the user
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isSignedIn', false);


        // Navigate to the login page or wherever you want
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signin(),));
      } catch (e) {
        // Handle sign-out exceptions
        print('Error signing out: $e');
        showerror(context,"Error singing out.");
        // You can show a snackbar or a dialog to inform the user about the error.
      }
  }



  String level="none";

  Widget coursethumbnail() {
    return Container(
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
                  child: Image(
                    image: AssetImage("images/data.jpg"),
                    fit: BoxFit.cover,
                  )),
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
                      "Flutter For Beginers",
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
                      "This course will help you to gain knowledge in order to build apps with flutter using firebase as backend.This course covers many basic to advance concepts of flutter.",
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Learnflow Pro",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(238, 28, 57, 1),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      backgroundColor: Color.fromRGBO(238, 28, 57, 1),
                      title: Text("Do you want to sign out?",
                          style: TextStyle(color: Colors.white)),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No",
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
                          ElevatedButton(
                            onPressed: () {
                              signout();
                            },
                            child: Text("Yes",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              backgroundColor: Colors.black,
                            ),
                          ),
                        ],
                      )));
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup(),));
            },
            icon: Icon(Icons.logout_rounded, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: MediaQuery.of(context).size.height * 0.18,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color.fromRGBO(238, 28, 57, 1),
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.elliptical(380, 60)),
            ),
            child:Padding(
              padding:  EdgeInsets.only(left:15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height:MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      Container(
                        height:MediaQuery.of(context).size.height * 0.04,
                        //color:Colors.yellow,
                        child:FittedBox(fit: BoxFit.fitHeight,child: Text("Hi",style:TextStyle(fontWeight: FontWeight.bold,color:Colors.white))),
                      ),
                      SizedBox(width:15),
                      Container(
                        height:MediaQuery.of(context).size.height * 0.04,
                        child:FittedBox(fit:BoxFit.fitHeight,child:Icon(Icons.emoji_emotions_outlined)),

                      )
                    ],
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.01),
                  Container(
                    height:MediaQuery.of(context).size.height * 0.02,
                   // color:Colors.yellow,
                    child:FittedBox(fit: BoxFit.fitHeight,child: Text("Today is a good day",style:TextStyle(color:Colors.white))),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.01),
                  Container(
                    height:MediaQuery.of(context).size.height * 0.02,
                    //color:Colors.yellow,
                    child:FittedBox(fit: BoxFit.fitHeight,child: Text("to learn something",style:TextStyle(color:Colors.white))),
                  ),
                  SizedBox(height:MediaQuery.of(context).size.height * 0.01),
                  Container(
                    height:MediaQuery.of(context).size.height * 0.02,
                    //color:Colors.yellow,
                    child:FittedBox(fit: BoxFit.fitHeight,child: Text("new!",style:TextStyle(color:Colors.white))),
                  )
                ],
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  "Hi, what do you want to learn today?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                level="none";
                                color1= Color.fromRGBO(238, 28, 57, 1);
                                color2=Color.fromRGBO(200, 200, 200, 1);
                                color3=Color.fromRGBO(200, 200, 200, 1);
                                color4=Color.fromRGBO(200, 200, 200, 1);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              backgroundColor: Color.fromRGBO(227, 129, 43, 1.0),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(
                                      Icons.local_fire_department,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    //color:Colors.green,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text("All Courses")),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height:5),
                        Container(
                          height: 5,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color:color1,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                level="Basic";
                                color1= Color.fromRGBO(200, 200, 200, 1);
                                color2=Color.fromRGBO(238, 28, 57, 1);
                                color3=Color.fromRGBO(200, 200, 200, 1);
                                color4=Color.fromRGBO(200, 200, 200, 1);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              backgroundColor: Color.fromRGBO(1, 98, 193, 1),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 15.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(
                                      Icons.local_fire_department,
                                      color: Color.fromRGBO(227, 129, 43, 1.0),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    // color:Colors.green,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text("Basic Courses")),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height:5),
                        Container(
                          height: 5,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color:color2,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                    height: (MediaQuery.of(context).size.width) -
                        MediaQuery.of(context).size.width * 0.96),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                level="Intermediate";
                                color1= Color.fromRGBO(200, 200, 200, 1);
                                color2=Color.fromRGBO(200, 200, 200, 1);
                                color3=Color.fromRGBO(238, 28, 57, 1);
                                color4=Color.fromRGBO(200, 200, 200, 1);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              backgroundColor: Color.fromRGBO(187, 15, 30, 1),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 15),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(
                                      Icons.my_library_books,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    //color:Colors.green,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text("Medial Courses")),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height:5),
                        Container(
                          height: 5,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color:color3,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                level="Advanced";
                                color1= Color.fromRGBO(200, 200, 200, 1);
                                color2=Color.fromRGBO(200, 200, 200, 1);
                                color3=Color.fromRGBO(200, 200, 200, 1);
                                color4=Color.fromRGBO(238, 28, 57, 1);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              backgroundColor: Color.fromRGBO(1, 102, 90, 1),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 15.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(Icons.star_half,
                                        color: Color.fromRGBO(227, 129, 43, 1.0)),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 20,
                                    // color:Colors.green,
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text("Advance Courses")),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height:5),
                        Container(
                          height: 5,
                          width: (MediaQuery.of(context).size.width * 0.48) - 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color:color4,
                          ),
                        )
                      ],
                    ),
                  ],
                ),







                SizedBox(height:25),
                Container(
                  height:50,
                  child:categories(),
                  //color:Colors.green,
                ),


                SizedBox(height:25),
                StreamBuilder(
                  stream: level=="none"?(checkcategory.isEmpty ?  FirebaseFirestore.instance.collection('courses').snapshots():FirebaseFirestore.instance.collection('courses').where('category', whereIn:checkcategory).snapshots()):
                  (checkcategory.isEmpty ? FirebaseFirestore.instance.collection('courses').where('level', isEqualTo: level).snapshots(): FirebaseFirestore.instance.collection('courses').where('level', isEqualTo: level).where('category', whereIn:checkcategory).snapshots())
                  ,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator(); // Loading indicator while fetching data
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
                          child: toggle?Row(children: [
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
    child: Row(
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
    ],):Column(
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


                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            items[index],
                            SizedBox(height:50),
                            ElevatedButton(onPressed:(){setState((){toggle=!toggle;});},child:Text("Change View"))
                          ],
                        );
                      },
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    );
                  },
                ),

            ],
            ),
          )
        ],
      ),
      drawer: Drawer(
        child:FutureBuilder<Map<String, String>>(
      future: getUserInfo(),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: Container(child:CircularProgressIndicator(color:  Color.fromRGBO(238, 28, 57, 1),),height: MediaQuery.of(context).size.width*0.2,width: MediaQuery.of(context).size.width*0.2,));
      } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
      } else {
      String username = snapshot.data?['username'] ?? 'Default Name';
      String email = snapshot.data?['email'] ?? 'Default Email';

      return






























        Column(
          children: [
          Container(
          color: Color.fromRGBO(238, 28, 57, 1),
        child: Column(
        children: [
        SizedBox(
        height: MediaQuery.of(context).padding.top,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          alignment: Alignment.center,

        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        // color:Colors.green,
        child: CircleAvatar(
          child:Text(username[0],style: TextStyle(color:Color.fromRGBO(238, 28, 57, 1),fontSize: MediaQuery.of(context).size.width*0.2/2),),
          radius: MediaQuery.of(context).size.width*0.2,
          backgroundColor: Colors.white,
        ),

        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
        child: Text(username,
        style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold)),
        // color:Colors.yellow,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
        child: Text("You are signed in as: ",
        style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold)),
        //color:Colors.yellow,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
        child: Text(email,
        style: TextStyle(color: Colors.white, fontSize: 15)),
        //color:Colors.yellow,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ],
        )),
        InkWell(
        child: ListTile(
        leading: Icon(Icons.my_library_books),
        title: Text("My Courses"),
        ),
        onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Mycourses(),));
        },
        ),
        InkWell(
        child: ListTile(
        leading: Icon(Icons.account_circle_outlined),
        title: Text("My Profile"),
        ),
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profile(),
              ));

        },
        ),
        InkWell(
        child: ListTile(
        leading: Icon(Icons.star),
        title: Text("Enrolled Courses"),
        ),
        onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Enrolledcourses(),));
        },
        ),
        InkWell(
          child: ListTile(
          leading: Icon(Icons.key),
          title: Text("Reset Password"),
          ),
          onTap: (){
            print("trgerewqqwdfbggf");
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    backgroundColor: Color.fromRGBO(238, 28, 57, 1),
                    title: Text("Do you want to reset your password?",
                        style: TextStyle(color: Colors.white)),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("No",
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
                        ElevatedButton(
                          onPressed: () {
                            resetPassword(email);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text("Yes",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ],
                    )));
          },
        ),
        InkWell(
        child: ListTile(
        leading: Icon(Icons.share),
        title: Text("Share App"),
        ),
        onTap: (){
        shareapp();
        },
        ),
        ],);
      }
      },

      ),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Uploadcourse(),
              ));
        },
        backgroundColor: Color.fromRGBO(238, 28, 57, 1),
        elevation: 10,
        tooltip: "Add Course",
        child: Icon(Icons.add, color: Colors.white),
      ),

    );
  }

}
