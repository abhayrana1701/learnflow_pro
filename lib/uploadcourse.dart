import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'mycourses.dart';

class Uploadcourse extends StatefulWidget {
  const Uploadcourse({super.key});

  @override
  State<Uploadcourse> createState() => _UploadcourseState();
}

class _UploadcourseState extends State<Uploadcourse> {

  List courseimages=['temp','temp'];

  TextEditingController coursename=new TextEditingController();
  TextEditingController shortdescription=new TextEditingController();
  TextEditingController maindescription=new TextEditingController();
  TextEditingController courseduration=new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;









 /* Future<List<String>> _uploadVideosToStorage() async {
    List<String> downloadURLs = [];

    for (String videoPath in coursevideos) {
      try {
        File videoFile = File(videoPath);
        String videoFileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        Reference storageRef = _storage.ref().child('videos/$videoFileName');
        await storageRef.putFile(videoFile);

        String downloadURL = await storageRef.getDownloadURL();
        downloadURLs.add(downloadURL);
      } catch (e) {
        print('Error uploading video to storage: $e');
      }
    }

    return downloadURLs;
  }*/
  String status="Uploading Course";
  double _uploadProgress = 0.0;
  Future<List<String>> _uploadassetsToStorage() async {
    coursevideos=coursevideos+courseimages;
    List<String> downloadURLs = [];

    String assetFileName='';
    for (int i = 0; i < coursevideos.length; i++) {
      try {
        if (i < (coursevideos.length - 2 as int)) {
          assetFileName = 'asset_${DateTime.now().millisecondsSinceEpoch}.mp4';
        }
        else{
          assetFileName = 'asset_${DateTime.now().millisecondsSinceEpoch}.jpg';
        }
        Reference storageRef = _storage.ref().child('assets/$assetFileName');

        UploadTask uploadTask = storageRef.putFile(coursevideos[i]);

        // Listen for state changes, errors, and completion of the upload.
        uploadTask.snapshotEvents.listen(
                (TaskSnapshot snapshot) {
              double progress = snapshot.bytesTransferred / snapshot.totalBytes;
              setState(() {
                _uploadProgress = progress;
              });
            },
            onError: (dynamic error) {
              print('Error during upload: $error');
            },
          onDone: () {
            print('Upload complete');
          },
        );

        // Wait for the upload to complete
        await uploadTask.whenComplete(() => print('Upload task complete'));

        String downloadURL = await storageRef.getDownloadURL();
        downloadURLs.add(downloadURL);
      } catch (e) {
        print('Error uploading video to storage: $e');
      }
    }

    return downloadURLs;
  }







  String nameerror="";
  bool nameValidator(String name){
    if (name.isEmpty) {
      setState(() {
        nameerror="This field cannot be empty";
      });
      return false;
    }

    // Regular expression for a valid name (alphabets and spaces)
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

    if (!nameRegExp.hasMatch(name)) {
      setState(() {
        nameerror="Enter a valid course name";
      });
      return false;
    }
    setState(() {
      nameerror="";
    });
    return true;
  }


  String shortdescriptionerror="";
  bool shortdescriptionValidator(String name){
    if (name.isEmpty) {
      setState(() {
        shortdescriptionerror="This field cannot be empty";
      });
      return false;
    }

    // Regular expression for a valid name (alphabets and spaces)
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

    if (!nameRegExp.hasMatch(name)) {
      setState(() {
        shortdescriptionerror="Enter a valid short description of course";
      });
      return false;
    }
    setState(() {
      shortdescriptionerror="";
    });
    return true;
  }

  String maindescriptionerror="";
  bool maindescriptionValidator(String name){
    if (name.isEmpty) {
      setState(() {
        maindescriptionerror="This field cannot be empty";
      });
      return false;
    }

    // Regular expression for a valid name (alphabets and spaces)
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

    if (!nameRegExp.hasMatch(name)) {
      setState(() {
        maindescriptionerror="Enter a valid main description of course";
      });
      return false;
    }
    setState(() {
      maindescriptionerror="";
    });
    return true;
  }

  String durationerror="";
  bool durationValidator(String durationr){
    if (durationr.isEmpty) {
      setState(() {
        durationerror="This field cannot be empty";
      });
      return false;
    }

    int duration;
    try {
      duration = int.parse(durationr);
      if (duration< 1 || duration > 120) {
        setState(() {
          durationerror='Please enter an duration between 1 and 120';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        durationerror="Enter a valid duration";
      });
      return false;
    }
    setState(() {
      durationerror="";
    });
    return true;
  }


  Future<void> _uploadData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      // Upload videos to storage and get download URLs
      List<String> videoDownloadURLs = await _uploadassetsToStorage();
      String thumbnaildownloaurl=videoDownloadURLs[videoDownloadURLs.length-2];
      String certificatedownloaurl=videoDownloadURLs[videoDownloadURLs.length-1];
      videoDownloadURLs.removeLast();
      videoDownloadURLs.removeLast();
      String docid=DateTime.now().millisecondsSinceEpoch.toString();
      // Data to be uploaded
      Map<String, dynamic> data = {
        'userId': user.uid,
        'coursename':coursename.text,
        'shortdesciption':shortdescription.text,
        'maindescription':maindescription.text,
        'category':selectedCategory,
        'courseduration':courseduration.text,
        'skills':skills,
        'level':selectedValue,
        'units':units,
        'subunits':subunits,
        'subunitlength':subunitnumber,
        'enrolls':0,
        'coursevideopaths': videoDownloadURLs,
        'thumbnailpath':thumbnaildownloaurl,
        'certificatepath':certificatedownloaurl,
        'docid':docid,
      };

      await _firestore.collection('courses').doc(docid).set(data);

      print('Data uploaded successfully!');
      setState(() {
        status="Course Uploaded";
        isvisible3=true;
      });
    } catch (e) {
      print('Error uploading data: $e');}
    finally {
      setState(() {
        //_uploadProgress = 0.0;
      });
    }
  }

  String thumbnailerror="";
  bool thumbnailValidator(){
    if(_pickedImageThumbnail==null){
      setState(() {
        thumbnailerror="You must pick a thumbnail image for your course";
      });
      return false;
    }
    setState(() {
      thumbnailerror="";
    });
    return true;
  }

  int skillnumber=1;
  String selectedValue = 'Basic';
  String selectedCategory = 'Technology and Programming';
   File? _pickedImageThumbnail;

  Future<void> _pickImageThumbnail() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImageThumbnail = File(pickedFile.path);
        courseimages[0]=_pickedImageThumbnail;
      });
    }
  }

  File? _pickedImageCertificate;
  Future<void> _pickImageCertificate() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImageCertificate = File(pickedFile.path);
        courseimages[1]=_pickedImageCertificate;
      });
    }
  }


  File? _pickedVideo;
  List coursevideos=[];
  int vnum=0;
  Future<void> _pickVideo(int unitindex,int index) async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
         setState(() {
        _pickedVideo = File(pickedFile.path);
        for(int i=0;i<unitindex;i++){
          vnum+=subunitnumber[i] as int;
        }
        if ((vnum+index) < coursevideos.length) {
          // Update existing skill
          coursevideos[(vnum+index) as int] = _pickedVideo;
        } else {
          // Add new skill
          coursevideos.add(_pickedVideo);
        }
      });
    }

    vnum=0;

  }
  int updatevideothumb(int unitindex,int index){
    int returnval=0;
    int vnum1=0;
    for(int i=0;i<unitindex;i++){
      vnum1+=subunitnumber[i] as int;
    }
    if ((vnum1+index) < coursevideos.length) {
     returnval=1;
    } else {
      returnval=2;
    }
    if(returnval==1){
      return vnum1+index;
    }
    if(returnval==2){
      return coursevideos.length-1;
    }
    return -1;
  }

  Widget input({
    required hintText,
    required label,
    required length,
    required lines,
    required color,
    required controller
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:30),
        TextFormField(
          controller: controller,
          maxLength: length,
          maxLines: lines,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            //prefixIcon: Icon(Icons.phone)

              filled:true,
              fillColor: color,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238,28,57,1),
                  )
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.white24,
                  )
              ),
              labelText: label,
              labelStyle:TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              ) ,
              hintText:hintText,
              hintStyle: TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              )
          ),
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ],
    );
  }

  List<dynamic> skills=[];
  Widget inputskill({
    required hintText,
    required label,
    required length,
    required lines,
    required color,
    required index,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:30),
        TextFormField(
          maxLength: length,
          maxLines: lines,
          cursorColor: Colors.black,
          onChanged: (value) {
          setState(() {
            if (index < skills.length) {
              // Update existing skill
              skills[index] = value;
            } else {
              // Add new skill
              skills.add(value);
            }
          });},
          decoration: InputDecoration(
            //prefixIcon: Icon(Icons.phone)

              filled:true,
              fillColor: color,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238,28,57,1),
                  )
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.white24,
                  )
              ),
              labelText: label,
              labelStyle:TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              ) ,
              hintText:hintText,
              hintStyle: TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              )
          ),
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ],
    );
  }
  String skillValidator(String skill){
    final RegExp nameRegex = RegExp(r"^[a-zA-Z\s-]+$");
    if(nameRegex.hasMatch(skill)){
      return "";
    }
    if(skill==""){
      return "This field cannot be empty";
    }
    return "Enter valid skill.";
  }

  int unitnumber=1;
  List units=[];
  Widget inputunit({
    required hintText,
    required label,
    required length,
    required lines,
    required color,
    required index,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:30),
        TextFormField(
          maxLength: length,
          maxLines: lines,
          cursorColor: Colors.black,
          onChanged: (value) {
            setState(() {
              if (index < units.length) {
                // Update existing skill
                units[index] = value;
              } else {
                // Add new skill
                units.add(value);
              }
            });},
          decoration: InputDecoration(
            //prefixIcon: Icon(Icons.phone)

              filled:true,
              fillColor: color,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238,28,57,1),
                  )
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.white24,
                  )
              ),
              labelText: label,
              labelStyle:TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              ) ,
              hintText:hintText,
              hintStyle: TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              )
          ),
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ],
    );
  }

  int num=0;
  List subunitnumber=[1];
  int totalsubunitnumber=1;

  List subunits=[];

  Widget inputsubunits({
    required hintText,
    required label,
    required length,
    required lines,
    required color,
    required index,
    required unitindex,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height:30),
        TextFormField(
          onChanged: (value) {
            setState(() {
              for(int i=0;i<unitindex;i++){
                num+=subunitnumber[i] as int;
              }
              if ((num+index) < subunits.length) {
                // Update existing skill
                subunits[(num+index) as int] = value;
              } else {
                // Add new skill
                subunits.add(value);
              }
              num=0;
            });
          },
          maxLength: length,
          maxLines: lines,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            //prefixIcon: Icon(Icons.phone)

              filled:true,
              fillColor: color,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(238,28,57,1),
                  )
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.white24,
                  )
              ),
              labelText: label,
              labelStyle:TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              ) ,
              hintText:hintText,
              hintStyle: TextStyle(
                  color:Color.fromRGBO(238,28,57,1)
              )
          ),
          style: TextStyle(
              color: Colors.black
          ),
        ),
      ],
    );
  }




  bool isvisible1=true;
  bool isvisible2=false;
  bool isvisible3=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(245,245,245,1),
        appBar: AppBar(
          title: Text("Add Course",style: TextStyle(color:Colors.white),),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color.fromRGBO(238,28,57,1),
        ),

        body:Padding(
          padding:  EdgeInsets.only(left:15,right:15),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Visibility(
                  visible: isvisible1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height:30),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.all(Radius.circular(10)),
                            color:Colors.white,
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Select Thumbnail",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: InkWell(
                                    onTap: (){
                                      _pickImageThumbnail();
                                    },
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.2,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius:BorderRadius.all(Radius.circular(10)),
                                        color:Color.fromRGBO(245,245,245,1),
                                      ),
                                        child:_pickedImageThumbnail!=null?Image.file(_pickedImageThumbnail!):Image(image: AssetImage("images/selectimage.png"),)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                      Text(thumbnailerror,style: TextStyle(color: Color.fromRGBO(238,28,57,1))),
                      input(controller: coursename,label: "Course Name",hintText: "Course Name",length: 50,lines:1,color: Colors.white),
                      Text(nameerror,style: TextStyle(color: Color.fromRGBO(238,28,57,1))),
                      input(controller: shortdescription,label: "Short Description",hintText: "Short Description",length: 300,lines:3,color: Colors.white),
                      Text(shortdescriptionerror,style: TextStyle(color: Color.fromRGBO(238,28,57,1))),
                      input(controller: maindescription,label: "Main Description",hintText: "Main Description",length: 600,lines:5,color: Colors.white),
                      Text(maindescriptionerror,style: TextStyle(color: Color.fromRGBO(238,28,57,1))),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.all(Radius.circular(10)),
                            color:Colors.white,
                          ),
                          width:MediaQuery.of(context).size.width,
                          child:Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Select Category",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                DropdownButton<String>(
                                  value: selectedCategory,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedCategory = newValue!;
                                    });
                                  },
                                  items: <String>['Technology and Programming','Business and Entrepreneurship','Creative Arts','Personal Development','Language Learning','Health and Fitness','Science and Math','Humanities','Test Preparation','Industry-Specific Courses','Specializations and Certifications','Hobbies and Interests','Academic Subjects','Programming Languages','Social Sciences','Others']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          )
                      ),
                      input(controller: courseduration,label: "Course Duration",hintText: "Course Duration In Hours",length: 4,lines:1,color: Colors.white),
                      Text(durationerror,style: TextStyle(color: Color.fromRGBO(238,28,57,1))),
                      SizedBox(height:30),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.all(Radius.circular(10)),
                            color:Colors.white,
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Add Skills",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                    InkWell(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        width: 30,
                                        child:Icon(Icons.add,color:Colors.white),
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(238, 28, 57, 1),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                      ),
                                      onTap: (){
                                          setState(() {
                                            if(skillnumber<10){
                                              skillnumber++;
                                            }
                                          });
                                      },
                                    )
                                  ],
                                ),
                               ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: skillnumber,
                                      itemBuilder: (context,int index) {
                                        return Column(
                                          children: [
                                            inputskill(index: index,label: "Skill ${index+1}",hintText: "Skill ${index+1}",length: 50,lines:1,color: Color.fromRGBO(245,245,245,1),),

                                          ],
                                        );
                                      }
                                  ),


                              ],
                            ),
                          )
                      ),


                      SizedBox(height:30),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.all(Radius.circular(10)),
                            color:Colors.white,
                          ),
                        width:MediaQuery.of(context).size.width,
                        child:Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Select Level",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                              DropdownButton<String>(
                                value: selectedValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue!;
                                  });
                                },
                                items: <String>['Basic', 'Intermediate', 'Advanced']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      ),
                      SizedBox(height:30),



                      Container(
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.all(Radius.circular(10)),
                            color:Colors.white,
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Add Unit",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                    InkWell(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        width: 30,
                                        child:Icon(Icons.add,color:Colors.white),
                                        decoration: BoxDecoration(
                                            color: Color.fromRGBO(238, 28, 57, 1),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                      ),
                                      onTap: (){
                                        setState(() {
                                          if(unitnumber<25){
                                            unitnumber++;
                                            subunitnumber.add(1);
                                          }
                                        });
                                      },
                                    )
                                  ],
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: unitnumber,
                                    itemBuilder: (context,int index) {
                                      return Column(
                                        children: [
                                        (inputunit(index: index,label: "Unit ${index+1}",hintText: "Unit ${index+1}",length: 100,lines:1,color: Color.fromRGBO(245,245,245,1),)),
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius:BorderRadius.all(Radius.circular(10)),
                                              color:Color.fromRGBO(245,245,245,1),
                                            ),
                                            child:Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Add Sub Unit",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                                      InkWell(
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          height: 30,
                                                          width: 30,
                                                          child:Icon(Icons.add,color:Colors.white),
                                                          decoration: BoxDecoration(
                                                              color: Color.fromRGBO(238, 28, 57, 1),
                                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                                          ),
                                                        ),
                                                        onTap: (){
                                                          setState(() {
                                                            if(subunitnumber[index]<10){
                                                              setState(() {
                                                                if (index < subunitnumber.length) {
                                                                  // Update existing skill
                                                                  subunitnumber[index]++;
                                                                } else {
                                                                  // Add new skill
                                                                  skills.add(1);
                                                                }
                                                              });
                                                              totalsubunitnumber++;
                                                            }
                                                          });
                                                        },
                                                      )
                                                    ],


                                                  ),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: NeverScrollableScrollPhysics(),
                                                      itemCount: subunitnumber[index],
                                                      itemBuilder: (context,int subunitindex) {
                                                        return Column(
                                                          children: [
                                                             (inputsubunits(unitindex: index,index: subunitindex,label: "Sub Unit ${subunitindex+1}",hintText: "Sub Unit ${subunitindex+1}",length: 100,lines:1,color: Colors.white,))
                                                            ,Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:BorderRadius.all(Radius.circular(10)),
                                                                  color:Colors.white,
                                                                ),
                                                                child:Padding(
                                                                  padding: const EdgeInsets.all(15),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text("Select Video",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                                                      Padding(
                                                                        padding: const EdgeInsets.all(15),
                                                                        child: InkWell(
                                                                          onTap: () {
                                                                            _pickVideo(index,subunitindex).then((value) {updatevideothumb(index, subunitindex); print("hello: ${
                                                                                updatevideothumb(index, subunitindex)}");});

                                                                          },
                                                                          child: Container(
                                                                              height: MediaQuery.of(context).size.height * 0.2,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius:BorderRadius.all(Radius.circular(10)),
                                                                                color:Color.fromRGBO(245,245,245,1),
                                                                              ),
                                                                            child:Image(image: AssetImage("images/temp.jpg")),
                                                                          )
                                                                          ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  ),
                                                ],
                                              ),
                                            )
                                          )
                                        ],
                                      );
                                    }
                                ),
                              ],
                            ),
                          )
                      ),

                      SizedBox(height:30),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:BorderRadius.all(Radius.circular(10)),
                            color:Colors.white,
                          ),
                          child:Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Select Certificate",style: TextStyle(color:  Color.fromRGBO(238, 28, 57, 1),),),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: InkWell(
                                    onTap: (){
                                      _pickImageCertificate();
                                    },
                                    child: Container(
                                        height: MediaQuery.of(context).size.height * 0.2,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius:BorderRadius.all(Radius.circular(10)),
                                          color:Color.fromRGBO(245,245,245,1),
                                        ),
                                        child:_pickedImageCertificate!=null?Image.file(_pickedImageCertificate!):Image(image: AssetImage("images/selectimage.png"),)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                      SizedBox(height:30),
                      SizedBox(
                        height:50,
                        width:MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed:() {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                      backgroundColor: Color.fromRGBO(238, 28, 57, 1),
                                      title: Text("Do you upload the course?",
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
                                             /*thumbnailValidator();
                                              nameValidator(coursename.text);
                                              shortdescriptionValidator(shortdescription.text);
                                              maindescriptionValidator(maindescription.text);
                                              durationValidator(courseduration.text);
                                              if(!thumbnailValidator()){
                                                Navigator.pop(context);
                                                return ;
                                              }
                                              if(!nameValidator(coursename.text)){
                                                Navigator.pop(context);
                                                return ;
                                              }
                                              if(!shortdescriptionValidator(shortdescription.text)){
                                                Navigator.pop(context);
                                                return ;
                                              }
                                              if(!maindescriptionValidator(maindescription.text)){
                                                Navigator.pop(context);
                                                return ;
                                              }
                                              if(!durationValidator(courseduration.text)){
                                                Navigator.pop(context);
                                                return ;
                                              }*/
                                              Navigator.pop(context);
                                              _uploadData();
                                              isvisible1=false;
                                              isvisible2=true;
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
                              }
                            ,child:Text("Upload",style: TextStyle(color:Colors.white),),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            backgroundColor: Color.fromRGBO(238,28,57,1),
                          ),
                        ),
                      ),
                      SizedBox(height:30),


                    ],
                  ),
                ),
                Visibility(
                  visible: isvisible2,
                  child: Column(
                    children: [
                      SizedBox(height:50),
                      Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: FittedBox(fit: BoxFit.contain,child: Text (status,style: TextStyle(color:Color.fromRGBO(238, 28, 57, 1),fontWeight: FontWeight.bold),))
                      ),
                      SizedBox(height:50),
                      Visibility(
                        visible: isvisible3,
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height:MediaQuery.of(context).size.width*0.12,
                              width: MediaQuery.of(context).size.width*0.25,
                              child: Container(
                                height:MediaQuery.of(context).size.width*0.12,
                                width: MediaQuery.of(context).size.width*0.1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                                  color: Color.fromRGBO(238, 28, 57, 1),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height:MediaQuery.of(context).size.width*0.12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                                  color: Color.fromRGBO(238, 28, 57, 1),
                                ),
                              ),
                            ),
                            Container(
                              height:MediaQuery.of(context).size.width*0.12,
                              width: MediaQuery.of(context).size.width*0.25,
                            )
                          ],
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        height:MediaQuery.of(context).size.width*0.4+30,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Color.fromRGBO(238, 28, 57, 1),
                        ),
                        child: Container(
                          height:MediaQuery.of(context).size.width*0.35,
                          width: MediaQuery.of(context).size.width*0.35,
                          //color:Colors.yellow,
                          child: CircularProgressIndicator(
                            strokeWidth: 8,
                            value: _uploadProgress,
                            backgroundColor: Color.fromRGBO(238, 28, 57, 1), // Set background color to white
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Set foreground color to red
                          ),
                        ),
                      ),
                      SizedBox(height:50),
                      Visibility(
                        visible: isvisible3,
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Mycourses(),));
                              }
                              , child: Text("View",style: TextStyle(color:Colors.white ),),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                              backgroundColor: Color.fromRGBO(238, 28, 57, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
