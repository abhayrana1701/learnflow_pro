import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class Docourse extends StatefulWidget {
  final String docid;

  Docourse({required this.docid});

  @override
  State<Docourse> createState() => _DocourseState();
}

class _DocourseState extends State<Docourse> {

  double aspectratio=16/9;
  IconData orientationicon =Icons.fullscreen ;
  String orientation="p";
  Future<void> updateArray() async {
    try {
      // Get the collection reference
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('enrolledcourses');

      // Query the collection with the conditions
      QuerySnapshot querySnapshot = await collectionReference
          .where('courseenrolled', isEqualTo: widget.docid)
          .where('userid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if there are documents matching the conditions
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want to update the first document found
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        // Access the document reference for the specific document
        DocumentReference specificDocRef = collectionReference.doc(documentSnapshot.id);

        // Replace the existing array with a new one
        await specificDocRef.update({
          'length':completionstatusarr,
        });

        print('Array updated successfully');
      } else {
        print('No document found with the given conditions');
      }
    } catch (e) {
      print('Error updating array: $e');
    }
  }


  void dispose() {
    // Ensure you dispose of the video controller when the page is closed
    controller.dispose();
    super.dispose();
  }




  Future<List<dynamic>> completionstatus() async {
    try {
      // Get the collection reference
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('enrolledcourses');

      // Query the collection with the condition
      QuerySnapshot querySnapshot = await collectionReference.where('courseenrolled', isEqualTo: widget.docid).where('userid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

      // Check if there are documents matching the condition
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (you can modify this based on your requirements)
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

        // Check if the array field exists in the document

          // Get the array from the document
          List<dynamic> array = documentSnapshot['length'] as List<dynamic>;
          return array;

      } else {
        // No documents found with the given condition
        return [];
      }
    } catch (e) {
      // Handle errors
      print('Error fetching array from Firebase with condition: $e');
      return [];
    }
  }


  Future<void> fetchcoursedatainitial() async {
    try {
      // Get the document reference
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('courses').doc(widget.docid);

      // Get the document snapshot
      DocumentSnapshot documentSnapshot = await userDocRef.get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Access data from the document


        // Access the array field
        List<dynamic>subunits= documentSnapshot['subunits'] ?? [];
        List<dynamic>coursevideopaths= documentSnapshot['coursevideopaths'] ?? [];
        setState(() {
          print("Rsult: $completionstatusarr");
         coursename=documentSnapshot['coursename'];

         for(int i=0;i<completionstatusarr.length;i++){
           if(completionstatusarr[i]==0){
             indexcompletionarr1=i;
             break;
           }
         }
         subheading=subunits[indexcompletionarr1];
         videourl=coursevideopaths[indexcompletionarr1];
         print("RESSSSSS $videourl");
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
  int indexcompletionarr1=0;

  String coursename="";
  String subheading="";
  late VideoPlayerController controller;
  bool isFullScreen = false;
  String elapsedTime = "0:00";
  var coursevideopaths;
  var videourl = "";
  int index = -1;

    List completionstatusarr=[];

  void initState() {
    initializeData();
    super.initState();
  }

  initializeData() async {
    List<dynamic> result = await completionstatus();
    setState(() {
      completionstatusarr = result;
    });
    await fetchcoursedatainitial();
    loadVideoPlayer(indexcompletionarr1);
  }


  loadVideoPlayer(int indexforcompletionarr) {
    Uri videoUri = Uri.parse(videourl);
    bool isVideoInitialized = false;
    controller = VideoPlayerController.network(videoUri.toString())
      ..addListener(() {


        if (controller != null && controller!.value.position != null) {
          double videoLength = controller!.value.duration.inMilliseconds.toDouble();
          double currentPos = controller!.value.position.inMilliseconds.toDouble();

          // Check if the video is initialized
          if (!isVideoInitialized && controller!.value.isInitialized) {
            isVideoInitialized = true; // Set the flag once the video is initialized
          }

          // Check if 10% of the video is played after the video is initialized
          if (isVideoInitialized &&
              currentPos >= 0.1 * videoLength &&
              completionstatusarr[indexforcompletionarr] == 0) {
            setState(() {
              completionstatusarr[indexforcompletionarr] = 1;
            });
            print('At least 10% of the video has been played.');
            updateArray();
          }

          setState(() {
          elapsedTime = _formatDuration(controller.value.position);
        });}
      })
      ..initialize().then((value) {
        setState(() {});
      });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
  bool visible1=true;
  bool visible2=true;
  bool visible3=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: visible1==true?AppBar(
        title: Text(
          "Do Course",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(238, 28, 57, 1),
        elevation: 0,
      ):null,
      body: WillPopScope(
        onWillPop: () async {
          // Call your function here
          if(orientation=="l"){
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            orientation="p";
            orientationicon=Icons.fullscreen;
            visible1=true;
            visible2=true;
            visible3=true;
            aspectratio=16/9;
            return false;
          }

          // Allow the back button press
          return true;
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Visibility(
                visible: visible2,
                child: Padding(
                  padding:  EdgeInsets.only(left:15,right:15),
                  child: Container(
                    child:coursename==""?(Container()):(Column(
                      children: [
                        SizedBox(height:25),
                        Text(coursename,style: TextStyle(fontSize: 20)),
                        SizedBox(height:25),
                      ],
                    )),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },

                child: AspectRatio(
                  aspectRatio: aspectratio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(controller),
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          backgroundColor: Color.fromRGBO(238, 28, 57, 1),
                          playedColor: Colors.green,
                          bufferedColor: Color.fromRGBO(238, 28, 57, 1),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (controller.value.isPlaying) {
                                  controller.pause();
                                } else {
                                  controller.play();
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              elapsedTime,
                              style: TextStyle(color: Colors.white),
                            ),

                            InkWell(
                              child: Icon(
                                orientationicon ,
                                color:Colors.white,
                              ),
                              onTap: (){
                                if(orientation=="p"){
                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.landscapeLeft,
                                    DeviceOrientation.landscapeRight,
                                  ]);
                                  orientation="l";
                                  orientationicon=Icons.fullscreen_exit;
                                  visible1=false;
                                  visible2=false;
                                  visible3=false;
                                  aspectratio=MediaQuery.of(context).size.height/MediaQuery.of(context).size.width;
                                }
                                else{
                                  SystemChrome.setPreferredOrientations([
                                    DeviceOrientation.portraitUp,
                                  ]);
                                  orientation="p";
                                  orientationicon=Icons.fullscreen;
                                  visible1=true;
                                  visible2=true;
                                  visible3=true;
                                  aspectratio=16/9;
                                }

                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              Visibility(
                visible: visible3,
                child: Padding(
                  padding:  EdgeInsets.only(left:15,right:15),
                  child: Container(
                    child:subheading==""?(Container()):(Column(
                      children: [
                        SizedBox(height:25),
                        Text(subheading,style: TextStyle(fontSize: 16)),
                        SizedBox(height:25),
                      ],
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "Course Hierarchy",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 25),
                  ],
                ),
                color: Color.fromRGBO(238, 28, 57, 1),
              ),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.docid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color:  Color.fromRGBO(238, 28, 57, 1),));
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('Document does not exist');
                  }
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var units = data['units'] as List<dynamic>;
                  var subunits = data['subunits'] as List<dynamic>;
                  var subunitslength =
                  data['subunitlength'] as List<dynamic>;
                  coursevideopaths =
                  data['coursevideopaths'] as List<dynamic>;
                  coursename=data['coursename'];
                  


                  return Padding(
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
                            itemCount: subunitslength[unitIndex],
                            itemBuilder: (context, itemIndex) {
                              int sum = 0;
                              for (int i = 0; i < unitIndex; i++) {
                                sum = sum + subunitslength[i] as int;
                              }
                              return InkWell(
                                child: Row(
                                  children: [
                                    SizedBox(width: 15),
                                    completionstatusarr[sum + itemIndex] == 0
                                        ? Icon(Icons.circle_outlined)
                                        : Icon(Icons.check, color: Colors.green),
                                    SizedBox(width: 15),
                                    Flexible(
                                      child: Text(
                                        "${subunits[sum + itemIndex]}",
                                        softWrap: true, // Use ellipsis for overflow
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                  ],
                                ),
                                onTap: () {
                                  int sum = 0;
                                  for (int i = 0; i < unitIndex; i++) {
                                    sum = sum + (subunitslength[i] as int);
                                  }

                                  var newVideoUrl =
                                  coursevideopaths[sum + itemIndex];
                                  if (newVideoUrl != null) {
                                    setState(() {
                                      videourl = newVideoUrl;
                                      subheading=subunits[sum+itemIndex];

                                    });
                                    loadVideoPlayer(sum+itemIndex);
                                  } else {
                                    print('Invalid video URL');
                                  }
                                },
                              );
                            },
                          ),
                          isExpanded: index == unitIndex,
                        );
                      }).toList(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
      onDrawerChanged: (val){
        if(val){
          print("yes");
          controller.pause();
        }
      },
    );
  }
}
