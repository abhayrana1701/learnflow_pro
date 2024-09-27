import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "signin.dart";

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool sending=false;

  Future<void> _sendPasswordResetEmail() async {
    try {
      var userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.text)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // Email exists in the "users" collection
        await _auth.sendPasswordResetEmail(email: email.text).then((value) {
          // Successful password reset email sent
          print('Password reset email sent to ${email.text}');
          setState(() {
            sending=false;
          });
          showsuccess(context,"Password reset email sent to ${email.text}");
          // Add your code here to navigate to another screen or show a confirmation message
        });
      } else {
        setState(() {
          sending=false;
        });
        showerror(context, "No user found for this email.");
        print('No user found for that email.');
        // Add your code here to display a message to the user
      }
    } on FirebaseAuthException catch (e) {
      showerror(context,"Something went wrong.");
      print('Error: ${e.message}');
      setState(() {
        sending=false;
      });
      // Handle other exceptions
    } catch (e) {
      showerror(context,"Something went wrong.");
      print('Error: $e');
      setState(() {
        sending=false;
      });
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

  String emailerror="";
  bool emailValidator(String email){
    if (email.isEmpty) {
      setState(() {
        emailerror="This field cannot be empty";
      });
      return false;
    }

    final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        emailerror="Enter a valid email";
      });
      return false;
    }
    setState(() {
      emailerror="";
    });
    return true;
  }

  TextEditingController email = TextEditingController();

  Widget inputField(
      {required controller,
      required hintText,
      required labelText,
      required icon}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(
          icon,
          color: Colors.white,
        ),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(238, 28, 57, 1),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(200, 40),
                      bottomRight: Radius.elliptical(200, 40))),
              child: Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.1,
                      // color: Colors.green,
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text("Learnflow Pro",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    Row(
                      children: [
                        Container(
                          //width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.05,
                          //color: Colors.blue,
                          child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text("Reset Password",
                                  style: TextStyle(color: Colors.white))),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.025,
                      //color:Colors.green,
                      child: Row(
                        children: [
                          FittedBox(
                              fit: BoxFit.contain,
                              child: (Text(
                                "Please enter your email to continue",
                                style: TextStyle(color: Colors.white),
                              ))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.1,
                      //color:Colors.yellow,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputField(
                                controller: email,
                                hintText: "Email",
                                labelText: "Email",
                                icon: Icons.email_outlined),
                            Text(emailerror,style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.65 -
                    (MediaQuery.of(context).size.height * 0.065) / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Signin(),
                          ));
                    },
                    child: Text("Login",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      emailValidator(email.text);
                      if(!emailValidator(email.text)){
                        showerror(context, "Please fill all the fields correctly");
                        return;
                      }
                      sending=true;
                      _sendPasswordResetEmail();
                    },
                    child: sending==false ? Text("Continue",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)):CircularProgressIndicator(color:Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      backgroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
