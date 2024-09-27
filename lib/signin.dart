import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "forgotpassword.dart";
import "home.dart";
import "signup.dart";
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {

  bool signingin=false;
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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    try {
      // Sign in with email and password (replace with your sign-in logic)
      await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );

      // Navigate to the next page upon successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isSignedIn', true);
    } on FirebaseAuthException catch (e) {
      setState(() {
        signingin=false;
      });
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        showerror(context, "The credentials are not valid.");
      }
    } catch (e) {
      setState(() {
        signingin=false;
      });
      // Handle other exceptions
      showerror(context, "Something went wrong.");
    }
  }



  TextEditingController email=TextEditingController();
  TextEditingController pass=TextEditingController();

  Widget inputField({
    required controller,
    required hintText,
    required labelText,
    required icon,
    required obscuretext
  }){
    return TextFormField(
      controller: controller,
      style: TextStyle(color:Colors.white),
      cursorColor: Colors.white,
      obscureText: obscuretext,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(icon,color: Colors.white,),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
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


  String passworderror="";
  bool passwordValidator(String password){
    if (password.isEmpty) {
      setState(() {
        passworderror="This field cannot be empty";
      });
      return false;
    }
    setState(() {
      passworderror="";
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:SingleChildScrollView(
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
                  height: MediaQuery.of(context).size.height*0.65,
                  decoration:const BoxDecoration(
                      color:Color.fromRGBO(238,28,57,1),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(200, 40),bottomRight: Radius.elliptical(200, 40))
                  ),
                  child:Padding(
                    padding: EdgeInsets.only(left:MediaQuery.of(context).size.width*0.02,right:MediaQuery.of(context).size.width*0.02,),
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.08,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.5,
                          height: MediaQuery.of(context).size.height*0.1,
                         // color: Colors.green,
                          child:FittedBox(fit:BoxFit.contain,child: Text("Learnflow Pro",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.06,),
                        Row(
                          children: [
                            Container(
                              //width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.05,
                             // color: Colors.blue,
                              child:FittedBox(fit:BoxFit.fitHeight,child: Text("Sign In",style: TextStyle(color: Colors.white))),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height*0.18,
                         // color:Colors.yellow,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics:BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                inputField(obscuretext: false,controller: email, hintText: "Email", labelText: "Email", icon: Icons.email_outlined),
                                Text(emailerror,style: TextStyle(color: Colors.white)),
                                inputField(obscuretext: true,controller: pass, hintText: "Password", labelText: "Password", icon: Icons.lock_outline),
                                Text(passworderror,style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).size.height*0.015,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                             // width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.02,
                            //  color: Colors.green,
                              child:FittedBox(fit: BoxFit.contain,child: InkWell(onTap:(){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Forgotpassword(),));},child: Text("Forgot Password ?",style: TextStyle(color: Colors.white),)))
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              ),

              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.65-(MediaQuery.of(context).size.height*0.065)/2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.4,
                      height: MediaQuery.of(context).size.height*0.065,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup(),));
                        },
                        child: Text("Register",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),


                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.4,
                      height: MediaQuery.of(context).size.height*0.065,
                      child: ElevatedButton(
                        onPressed: (){
                          emailValidator(email.text);
                          passwordValidator(pass.text);
                          if(!emailValidator(email.text)){
                            showerror(context, "Please fill all the fields correctly");
                            return;
                          }
                          if(!passwordValidator(pass.text)){
                            showerror(context, "Please fill all the fields correctly");
                            return;
                          }
                          signingin=true;
                          _signIn();
                        },
                        child:signingin==false ? Text("Sign In",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)):CircularProgressIndicator(color: Colors.white,),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
