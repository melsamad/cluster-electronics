import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  final supabase = Supabase.instance.client;

  // authentication

  Future<void> passLogin(String pass, String email) async {
    await supabase.auth.signInWithPassword(password: pass, email: email);
  }

  Future<void> forgotPassword() async {}

  Future<void> signUp() async {}

  // diary functions
  Future<void> createDiary(String title, String authorNote, String color, List<String> categories, final XFile? pickedFile) async {

    String imageUrl = '';
    String? uploadedPath;

    try {
      final loggedUser = supabase.auth.currentUser!;

      if (pickedFile != null) {
        // first let's store the background image (if it exists) into supabase storage
        final bytes = await pickedFile.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        uploadedPath = '${loggedUser.id}/$fileName';

        // upload bytes using uploadBinary 
          await Supabase.instance.client.storage
              .from('diary_front_images')
              .uploadBinary(
                uploadedPath,
                bytes,
                fileOptions: FileOptions(
                  contentType: pickedFile.mimeType ?? 'image/jpeg',
                ),
              );

          // get the public URL for the uploaded file
          final publicUrl = supabase.storage
              .from('diary_front_images')
              .getPublicUrl(uploadedPath);


          imageUrl = publicUrl;
      }
      
      await supabase.from('diaries').insert({
        'user_id':loggedUser.id,
        'title':title,
        "author's note":authorNote,
        'color_hex_code':color,
        'background_image': pickedFile != null ? imageUrl : null,
        'categories':categories, 
      });
    } catch (e) {
          if (uploadedPath != null) {
          try {
            await supabase.storage
                .from('diary_front_images')
                .remove([uploadedPath]);
          } catch (_) {
            print(e);
          }
        }
       
        rethrow;
      }
    }

  

  Future<void> createDiaryEntry({
    String? diaryId,
    String title = 'Untitled Entry',
    List<Map<String, dynamic>> texts = const [],
    List<String> images = const [],
    List<String> audios = const [],
    List<String> videos = const [],
  }) async {
    try {
      final loggedUser = supabase.auth.currentUser;
      await supabase.from('diary_entries').insert({
        if (loggedUser != null) 'user_id': loggedUser.id,
        if (diaryId != null) 'diary_id': diaryId,
        'title': title,
        'texts': texts,
        'images': images,
        'audios': audios,
        'videos': videos,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> followDiary() async {}

  Future<void> likeDiaryEntry() async {}

  Future<void> saveDiaryEntry() async {}


}


