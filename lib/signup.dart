import "package:flutter/material.dart";
import "signin.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  bool signingup=false;
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

  void _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );

      // Navigate to the next page after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Signin(),
        ),
      );

      // Upload user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name':name.text,
        'age':age.text,
        'email': email.text,

        // Add more details as needed
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        signingup=false;
      });
      if (e.code == 'email-already-in-use') {
        showerror(context, "The account already exists for that email.");
      } else{
        showerror(context, "Something went wrong.");
      }
    } catch (e) {
      setState(() {
        signingup=false;
      });
      // Handle other exceptions
      showerror(context, "Something went wrong.");
    }
  }



  bool checked=false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController name=TextEditingController();
  TextEditingController age=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController pass=TextEditingController();
  TextEditingController cpass=TextEditingController();

  Widget inputField({
    required controller,
    required hintText,
    required labelText,
    required icon,
    required obscuretext,
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
        nameerror="Enter a valid name";
      });
      return false;
    }
    setState(() {
      nameerror="";
    });
    return true;
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

    // Password criteria: At least 8 characters, including uppercase, lowercase, and a number.
    final RegExp passwordRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*]).{8,}$');

    if (!passwordRegExp.hasMatch(password)) {
      setState(() {
        passworderror="Password must be at least 8 characters long and include uppercase, lowercase, a number, and a special character.";
      });
      return false;
    }
    setState(() {
      passworderror="";
    });
    return true;
  }

  String ageerror="";
  bool ageValidator(String ager){
    if (ager.isEmpty) {
      setState(() {
        ageerror="This field cannot be empty";
      });
      return false;
    }

    int age;
    try {
      age = int.parse(ager);
      if (age < 12 || age > 99) {
        setState(() {
          ageerror='Please enter an age between 12 and 99';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        ageerror="Enter a valid age";
      });
      return false;
    }

    setState(() {
      ageerror="";
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
              height: MediaQuery.of(context).size.height*0.8,
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
                          child:FittedBox(fit:BoxFit.fitHeight,child: Text("Register",style: TextStyle(color: Colors.white))),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.05,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.35,
                     // color:Colors.yellow,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics:BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputField(obscuretext: false,controller: name, hintText: "Name", labelText: "Name", icon: Icons.account_circle_outlined),
                            Text(nameerror,style: TextStyle(color: Colors.white)),
                            inputField(obscuretext: false,controller: age, hintText: "Age", labelText: "Age", icon: Icons.calendar_month_rounded),
                            Text(ageerror,style: TextStyle(color: Colors.white)),
                            inputField(obscuretext: false,controller: email, hintText: "Email", labelText: "Email", icon: Icons.email_outlined),
                            Text(emailerror,style: TextStyle(color: Colors.white)),
                            inputField(obscuretext: true,controller: pass, hintText: "Password", labelText: "Password", icon: Icons.lock_outline),
                            Text(passworderror,style: TextStyle(color: Colors.white)),
                            inputField(obscuretext: true,controller: cpass, hintText: "Confrim Password", labelText: "Confirm Password", icon: Icons.lock_outline),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.025,
                      //color: Colors.green,
                      child: Row(
                        children: [
                          Checkbox(
                              value: checked,
                              checkColor: MaterialStateColor.resolveWith((states) => Color.fromRGBO(238,28,57,1)),
                              fillColor: MaterialStateColor.resolveWith((states) => Colors.white),
                              onChanged: (bool){
                                setState(() {
                                  checked=!checked;
                                });
                              }
                          ),
                          Text("  I agree to the ",style:TextStyle(color: Colors.white)),
                          Text("Terms & Conditions",style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ),

            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.8-(MediaQuery.of(context).size.height*0.065)/2),
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.4,
                height: MediaQuery.of(context).size.height*0.065,
                child: ElevatedButton(
                  onPressed: (){
                      nameValidator(name.text);
                      emailValidator(email.text);
                      passwordValidator(pass.text);
                      ageValidator(age.text);
                      if(!nameValidator(name.text)){
                        showerror(context, "Please fill all the fields correctly");
                        return;
                      }
                      if(!emailValidator(email.text)){
                        showerror(context, "Please fill all the fields correctly");
                        return;
                      }
                      if(!passwordValidator(pass.text)){
                        showerror(context, "Please fill all the fields correctly");
                        return;
                      }
                      if(!ageValidator(age.text)){
                        showerror(context, "Please fill all the fields correctly");
                        return;
                      }

                      if(pass.text!=cpass.text){
                          showerror(context, "Password and confirm password doesn't match");
                          return;
                      }
                      if(!checked){
                        showerror(context, "You must agree to the terms and conditions");
                        return;
                      }
                      signingup=true;
                    _signUp();
                    },
                  child:signingup==false ?  Text("Sign Up",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)): CircularProgressIndicator(color: Colors.white),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                      backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.9),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.025,
               // color:Colors.yellow,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(fit: BoxFit.contain,child: Text("Already have an account? ",style: TextStyle(color: Colors.black),)),
                    InkWell(
                      child: FittedBox(fit: BoxFit.contain,child: Text("Log In",style: TextStyle(color: Color.fromRGBO(238,28,57,1)),)),
                      onTap: (){
                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signin(),));
                      },
                    ),
                  ],
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}
