import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terrain/services/branding.dart';
import 'package:terrain/services/supabase.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  Branding br = Branding();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  SupabaseServices ss = SupabaseServices();

  Widget textfiel(String hintText, TextEditingController controller, bool obscureText) {
    return SizedBox(
                  width: 300,
                  child: TextField(
                    obscureText: obscureText,
                    cursorColor: br.pink,
                    controller: controller,
                    decoration: InputDecoration(
                      
                      focusColor: br.pink,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: br.pink
                          
                        )
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                          color: br.pink
                        )
                      ),
                      hintText: hintText,
                      hintStyle: GoogleFonts.archivo(
                        color: Colors.grey,
                        fontSize: 12
                      )
                    ),
                  
                  ),
                );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('lib/assets/auth.jpg', fit: BoxFit.cover, height: double.infinity, width: double.infinity,),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                ),

                Text('Enter your email and password',
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  color: br.pink,
                  fontSize: 25
                ),
                ),

                SizedBox(
                  height: 30,
                ),

                textfiel('Email...', email, false),
                SizedBox(
                  height: 20,
                ),
                textfiel('Password...', password, true),

                SizedBox(
                  height: 30,
                ),

                TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(br.green),
                  shadowColor: WidgetStatePropertyAll(Colors.white)
                ),
                icon: Icon(Icons.person, color: br.pink, size: 25,),
                onPressed: () async {
                  await ss.passLogin(password.text, email.text);
                }, 
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('Reconnect with my Terrain',
                  style: GoogleFonts.archivo(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: br.pink
                  ),
                  ),
                )
              ),

              SizedBox(
                  height: 80,
                ),

              Text("New to Terrain? Let's get you set up!",
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  color: br.pink,
                  fontSize: 12
                ),
                ),

                TextButton(
                  onPressed: () {}, 
                  child: Text("Click here to create an account",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    decoration: TextDecoration.underline,
                    decorationColor: br.pink,
                    color: br.pink,
                    fontSize: 12
                  ),
                  ),
                ),

                SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
        ],
      ),
    ); 
  }
}
