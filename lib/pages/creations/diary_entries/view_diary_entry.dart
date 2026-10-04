import 'package:flutter/material.dart';
import 'package:terrain/pages/creations/diary_entries/create_diary_entry.dart';
import 'package:terrain/services/branding.dart';
import 'package:terrain/services/supabase.dart';

class ViewDiaryEntry extends StatefulWidget {
  const ViewDiaryEntry({super.key});

  @override
  State<ViewDiaryEntry> createState() => _ViewDiaryEntryState();
}

class _ViewDiaryEntryState extends State<ViewDiaryEntry> {

  Branding br = Branding();
  SupabaseServices ss = SupabaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        backgroundColor: br.green,
        onPressed: (() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDiaryEntry()));
        }),
        child: Icon(Icons.edit, color: br.pink,),
      ),
    );
  }
}