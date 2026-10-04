import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terrain/onboarding/login.dart';
import 'package:terrain/services/branding.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  Branding br = Branding();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children:[ 

        Image.asset(
          'lib/assets/welcome.png', 
          fit: BoxFit.cover, 
          height: double.infinity, 
          width: double.infinity,),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(br.green),
                  shadowColor: WidgetStatePropertyAll(Colors.white)
                ),
                icon: Icon(Icons.public, color: br.pink, size: 25,),
                onPressed: () {}, 
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('Explore Terrains',
                  style: GoogleFonts.archivoBlack(
                    fontSize: 20,
                    color: br.pink
                  ),
                  ),
                )
              ),
            
              SizedBox(
                width: 25,
              ),
            
              TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(br.pink),
                  shadowColor: WidgetStatePropertyAll(Colors.white)
                ),
                icon: Icon(Icons.edit, color: br.green, size: 25,),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                }, 
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('Write Your Own',
                  style: GoogleFonts.archivoBlack(
                    fontSize: 20,
                    color: br.green
                  ),
                  ),
                )
              ),
            
              ],
            ),
          ),

          

            ]
          ) 
    );

  }
}
