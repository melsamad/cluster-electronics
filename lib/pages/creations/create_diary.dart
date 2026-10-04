import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:terrain/services/branding.dart';
import 'package:terrain/services/supabase.dart';

class CreateDiary extends StatefulWidget {
  const CreateDiary({super.key});

  @override
  State<CreateDiary> createState() => _CreateDiaryState();
}

class _CreateDiaryState extends State<CreateDiary> {

  Widget textfiel(String hintText, TextEditingController controller, bool obscureText) {
    return SizedBox(
      width: 300,
      child: TextField(
        onChanged: (value) {
          setState(() {
            name.text;
          });
        },
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


  Branding br = Branding();
  SupabaseServices ss = SupabaseServices();

  // text field
  TextEditingController name = TextEditingController();

  List<String> categories = [
    'Daily Life',
    'Founder Stories', 
    'Travels',
    'Uni Life', 
    'Imaginary Story',
    'Cooking/Baking Recipes', 
    'Athlete Journey Journaling',
    'Creative Dumps',
    'Personal Tech Projects',
    'Documentary',
    'Real-life Collection of Testimonies',
    'Historical Archive',
    'Senior Year', 
    'Other'
  ];

  List<String> chosenCategories = [];

  Color chosenColor = Color(0xFFB74093);

  bool isColor = false;

  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;

  Future<void> pickImage() async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // readAsBytes works cross-platform (Web, Mobile, Desktop)
      final Uint8List bytes = await pickedFile!.readAsBytes();
      
      setState(() {
        imageBytes = bytes;
      });
    }
  }
   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(br.pink)
          ),
          onPressed: () async {

            try {

              if (name.text != '') {
              // Multiply the double values (.r, .g, .b) by 255 and round to an integer
              int red = (chosenColor.r * 255).round();
              int green = (chosenColor.g * 255).round();
              int blue = (chosenColor.b * 255).round();

              // Convert each integer to a 2-digit hexadecimal string
              String rHex = red.toRadixString(16).padLeft(2, '0');
              String gHex = green.toRadixString(16).padLeft(2, '0');
              String bHex = blue.toRadixString(16).padLeft(2, '0');

              // Combine and return in uppercase
              final colorCode = '#$rHex$gHex$bHex'.toUpperCase();
              
              await ss.createDiary(
                name.text, 
                name.text, 
                colorCode, 
                categories, 
                pickedFile
              );

              Navigator.pop(context);

              } else {
                print('Please give your diary a name.');
              }
            } catch (e) {
              print(e);
            }
            
            
          }, 
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text('Save & Continue',
              style: GoogleFonts.homemadeApple(
                          color: Colors.white,
                          fontSize: 17
                          
                        ),
              ),
            ),
          )
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
              child: ListTile(
                title: Text('Create a Diary',
                  style: GoogleFonts.homemadeApple(
                    color: br.pink,
                    fontSize: 40
                  ),
                  ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 350,
                width: 250,
                decoration: BoxDecoration(
                  color: chosenColor,
                  //color: const Color.fromARGB(255, 211, 211, 211),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: imageBytes != null ? ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
                  child: Image.memory(imageBytes!, fit: BoxFit.cover,)) : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(name.text.isEmpty ? 'Diary Name' :  name.text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.homemadeApple(
                      color: Colors.white,
                      fontSize: 15
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  textfiel('diary name...', name, false),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text('Choose one or more categories',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.archivo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ), 

                  SizedBox(
                    height: 250,
                    width: 320,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: AlignedGridView.count(
                        crossAxisCount: 2, 
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {

                          String cat = categories[index];
                          bool isChosen = chosenCategories.contains(cat);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                            child: TextButton.icon(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.white)
                              ),
                              icon: isChosen ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.add, color: Colors.black,),
                              onPressed: () {
                                if (isChosen) {
                                  setState(() {
                                    chosenCategories.remove(cat);
                                  });
                                  
                                } else {
                                  setState(() {
                                    chosenCategories.add(cat);
                                  });
                                  
                                }
                              }, 
                              label: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(cat,
                                style: GoogleFonts.archivo(
                                  color: Colors.black,
                                  fontSize: 13
                                ),
                                ),
                              )
                            ),
                          );
                        })
                      ),
                    ),
                  )
                ],
              )
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
              child: ListTile(
                title: Text('Choose the color or \nbackground image of your diary',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.archivo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                Expanded(
                  child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: TextButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.white)
                                  ),
                                  icon: !isColor ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.color_lens, color: Colors.black,),
                                  onPressed: () {
                                    setState(() {
                                      isColor = !isColor;
                                    });
                                  }, 
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text('Colors',
                                    style: GoogleFonts.archivo(
                                      color: Colors.black,
                                      fontSize: 14
                                    ),
                                    ),
                                  )
                                ),
                              ),
                ),

                Expanded(
                  child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: TextButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.white)
                                  ),
                                  icon: isColor ? Icon(Icons.check, color: Colors.green,) : Icon(Icons.camera, color: Colors.black,),
                                  onPressed: () {
                                    setState(() {
                                      isColor = !isColor;
                                    });

                                    pickImage();
                                  }, 
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text('Background Image',
                                    style: GoogleFonts.archivo(
                                      color: Colors.black,
                                      fontSize: 14
                                    ),
                                    ),
                                  )
                                ),
                              ),
                ),
              
                ]
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ColorPicker(
                color: chosenColor,
                onChanged: (Color color) {
                setState(() {
                  chosenColor = color;
                });
                
              }),
            )

            
          ],
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';

class CreateDiary extends StatefulWidget {
  const CreateDiary({super.key});

  @override
  State<CreateDiary> createState() => _CreateDiaryState();
}

class _CreateDiaryState extends State<CreateDiary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

 */