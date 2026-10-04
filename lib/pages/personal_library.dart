import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terrain/pages/creations/create_diary.dart';
import 'package:terrain/pages/creations/diary_entries/view_diary_entry.dart';
import 'package:terrain/services/branding.dart';
import 'package:terrain/services/supabase.dart';

class MyPersonalLibrary extends StatefulWidget {
  const MyPersonalLibrary({super.key});

  @override
  State<MyPersonalLibrary> createState() => _MyPersonalLibraryState();
}

class _MyPersonalLibraryState extends State<MyPersonalLibrary> {

  Branding br = Branding();
  SupabaseServices ss = SupabaseServices();

  Widget createDiary() {
    return GestureDetector(
              onTap: () {

                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context, builder: (context) {
                  return CreateDiary();
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('+',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.indieFlower(
                    color: Colors.white,
                    fontSize: 30
                  ),),
                    Text('Create New \nDiary',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.homemadeApple(
                    color: Colors.white,
                    fontSize: 15
                  ),
                    )
                  ],
                ),
              ),
            );
  }


  @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Ensure at least 1 column to avoid divide-by-zero or 0-column layout bugs
      int columns = (constraints.maxWidth / 150).floor().clamp(1, 10);

      return Scaffold(
        body: Stack(
          children: [
            // Background Image
            Image.asset(
              'lib/assets/background.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.5),
            ),

            // Scrollable Content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30),
                      child: ListTile(
                        title: Text(
                          'My Personal Diaries',
                          style: GoogleFonts.homemadeApple(
                            color: br.pink,
                            fontSize: 50,
                          ),
                        ),
                      ),
                    ),

                    createDiary(),

                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ss.supabase
                          .from('diaries')
                          .select()
                          .eq('user_id', ss.supabase.auth.currentUser!.id)
                          .asStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Text('Loading diaries...'),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Text('No diaries found.'),
                          );
                        }

                        final array = snapshot.data!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                          child: AlignedGridView.count(
                            shrinkWrap: true, // Required inside SingleChildScrollView
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: array.length,
                            crossAxisCount: columns,
                            itemBuilder: (context, index) {
                              final data = array[index];
                          
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewDiaryEntry()));
                                },
                                child: Container(
                                  height: 300,
                                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(int.tryParse(data['color_hex_code'].toString()
                                    .replaceAll('#', '').padLeft(8, 'F'), radix: 16,) ??
                                    0xFF808080,),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data['title'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.homemadeApple(
                                        color: Colors.white,
                                        fontSize: 14
                                      ),
                                      ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}



