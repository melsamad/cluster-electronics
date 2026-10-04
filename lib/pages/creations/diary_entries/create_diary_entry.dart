import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:terrain/pages/creations/diary_entries/draggable_widgets.dart';
import 'package:terrain/services/branding.dart';
import 'package:terrain/services/supabase.dart';

/// Model representing a customizable text entry in a diary
class DiaryTextData {
  final String id;
  TextEditingController controller;
  double fontSize;
  String fontFamily;
  Color color;
  double xPosition;
  double yPosition;

  DiaryTextData({
    required this.id,
    required this.controller,
    this.fontSize = 18.0,
    this.fontFamily = 'Archivo',
    this.color = Colors.black87,
    this.xPosition = 24.0,
    this.yPosition = 120.0,
  });

  /// Convert to Map format ready for Supabase insertion
  Map<String, dynamic> toMap() {
    final int a = (color.a * 255).round();
    final int r = (color.r * 255).round();
    final int g = (color.g * 255).round();
    final int b = (color.b * 255).round();
    final colorHex = '#${a.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

    return {
      'id': id,
      'text': controller.text,
      'font_size': fontSize,
      'font_family': fontFamily,
      'color_hex': colorHex,
      'x_position': xPosition,
      'y_position': yPosition,
    };
  }

  /// Create a DiaryTextData instance from a Map (e.g. when loading from Supabase)
  factory DiaryTextData.fromMap(Map<String, dynamic> map) {
    Color parsedColor = Colors.black87;
    if (map['color_hex'] != null) {
      final hexStr = map['color_hex'].toString().replaceAll('#', '');
      final intVal = int.tryParse(hexStr.length == 6 ? 'FF$hexStr' : hexStr, radix: 16);
      if (intVal != null) {
        parsedColor = Color(intVal);
      }
    }

    return DiaryTextData(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      controller: TextEditingController(text: map['text']?.toString() ?? ''),
      fontSize: (map['font_size'] as num?)?.toDouble() ?? 18.0,
      fontFamily: map['font_family']?.toString() ?? 'Archivo',
      color: parsedColor,
      xPosition: (map['x_position'] as num?)?.toDouble() ?? 24.0,
      yPosition: (map['y_position'] as num?)?.toDouble() ?? 120.0,
    );
  }
}

class CreateDiaryEntry extends StatefulWidget {
  const CreateDiaryEntry({super.key});

  @override
  State<CreateDiaryEntry> createState() => _CreateDiaryEntryState();
}

class _CreateDiaryEntryState extends State<CreateDiaryEntry> {
  final Branding br = Branding();
  final SupabaseServices ss = SupabaseServices();

  // Curated list of Google Fonts suitable for diary entries
  static const List<String> availableGoogleFonts = [
    'Archivo',
    'Homemade Apple',
    'Indie Flower',
    'Caveat',
    'Playfair Display',
    'Pacifico',
    'Dancing Script',
    'Lobster',
    'Comfortaa',
    'Montserrat',
    'Cinzel',
    'Sacramento',
    'Amatic SC',
    'Kalam',
    'Shadows Into Light',
    'Satisfy',
    'Great Vibes',
    'Permanent Marker',
    'Courier Prime',
    'Patrick Hand',
    'Quicksand',
    'Lora',
    'Oswald',
    'Merriweather',
    'Poppins',
    'Roboto',
    'Cormorant Garamond',
  ];

  // Preset size shortcuts
  static const Map<String, double> fontSizePresets = {
    'Small': 14.0,
    'Regular': 18.0,
    'Medium': 24.0,
    'Large': 32.0,
    'Title': 42.0,
  };

  // ALL POSSIBLE DATA TO BE ADDED
  // texts: structured model holding text content, size, font family, color, and positions
  List<DiaryTextData> textEntries = [];

  // Convenience getters for backward compatibility
  List<TextEditingController> get controllers => textEntries.map((e) => e.controller).toList();

  /// Map representation of all text entries saved and ready for Supabase insertion
  List<Map<String, dynamic>> get textInfos => textEntries.map((e) => e.toMap()).toList();

  // images 
  List<String> imagePaths = [];

  // audios
  List<String> audioPaths = [];

  // videos
  List<String> videoPaths = [];

  @override
  void dispose() {
    for (final entry in textEntries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  /// Helper to safely resolve Google Fonts with fallback
  TextStyle getDiaryTextStyle({
    required String fontFamily,
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    try {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      );
    } catch (_) {
      return GoogleFonts.archivo(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      );
    }
  }

  /// Add a new text field on the diary canvas
  void _addNewTextField() {
    final id = 'text_${DateTime.now().millisecondsSinceEpoch}_${textEntries.length}';
    final newEntry = DiaryTextData(
      id: id,
      controller: TextEditingController(),
      fontSize: 18.0,
      fontFamily: 'Archivo',
      color: Colors.black87,
      xPosition: 30.0,
      yPosition: 100.0 + (textEntries.length * 50.0),
    );

    setState(() {
      textEntries.add(newEntry);
    });

    // Automatically open customization sheet for the new text field
    _showTextCustomizationSheet(newEntry);
  }

  /// Remove a text field
  void _removeTextField(DiaryTextData entry) {
    setState(() {
      textEntries.removeWhere((item) => item.id == entry.id);
    });
  }

  /// Bottom Sheet to customize text size, Google Font, and HSV color
  void _showTextCustomizationSheet(DiaryTextData entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // Top drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Header with title and Done button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customize Text',
                            style: GoogleFonts.homemadeApple(
                              color: br.green,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: br.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Done',
                              style: GoogleFonts.archivo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Live Preview Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 70, maxHeight: 110),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F6F0),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: br.pink.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            entry.controller.text.trim().isEmpty
                                ? 'Previewing Text Style...'
                                : entry.controller.text,
                            textAlign: TextAlign.center,
                            style: getDiaryTextStyle(
                              fontFamily: entry.fontFamily,
                              fontSize: entry.fontSize.clamp(12.0, 36.0),
                              color: entry.color,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tab Bar: Font Size, Google Fonts, HSV Color
                    TabBar(
                      labelColor: br.green,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: br.pink,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.archivo(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(icon: Icon(Icons.format_size), text: 'Size'),
                        Tab(icon: Icon(Icons.font_download), text: 'Font'),
                        Tab(icon: Icon(Icons.color_lens), text: 'Color'),
                      ],
                    ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        children: [
                          // TAB 1: FONT SIZE CUSTOMIZER
                          _buildFontSizeTab(entry, setModalState),

                          // TAB 2: GOOGLE FONTS LIST
                          _buildFontFamilyTab(entry, setModalState),

                          // TAB 3: HSV COLOR PICKER
                          _buildColorPickerTab(entry, setModalState),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Widget for the Font Size adjustment tab
  Widget _buildFontSizeTab(DiaryTextData entry, StateSetter setModalState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Size',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: br.green,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: br.pink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.fontSize.toInt()} px',
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: br.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: br.pink,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: br.green,
              overlayColor: br.green.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: entry.fontSize,
              min: 10.0,
              max: 64.0,
              divisions: 54,
              onChanged: (val) {
                setState(() {
                  entry.fontSize = val;
                });
                setModalState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),

          // Size Presets
          Text(
            'Quick Presets',
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fontSizePresets.entries.map((preset) {
              final isSelected = (entry.fontSize - preset.value).abs() < 1;
              return ChoiceChip(
                label: Text('${preset.key} (${preset.value.toInt()})'),
                selected: isSelected,
                selectedColor: br.pink,
                backgroundColor: Colors.grey[100],
                labelStyle: GoogleFonts.archivo(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      entry.fontSize = preset.value;
                    });
                    setModalState(() {});
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Widget for the Google Fonts list tab
  Widget _buildFontFamilyTab(DiaryTextData entry, StateSetter setModalState) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: availableGoogleFonts.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final fontName = availableGoogleFonts[index];
        final isSelected = entry.fontFamily == fontName;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected ? BorderSide(color: br.pink, width: 2) : BorderSide.none,
          ),
          tileColor: isSelected ? br.pink.withValues(alpha: 0.1) : Colors.transparent,
          title: Text(
            fontName,
            style: getDiaryTextStyle(
              fontFamily: fontName,
              fontSize: 18,
              color: isSelected ? br.green : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            'The quick brown fox jumps over the lazy dog',
            style: getDiaryTextStyle(
              fontFamily: fontName,
              fontSize: 13,
              color: Colors.grey[600]!,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: br.pink)
              : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          onTap: () {
            setState(() {
              entry.fontFamily = fontName;
            });
            setModalState(() {});
          },
        );
      },
    );
  }

  /// Widget for the HSV Color Picker tab using flutter_hsvcolor_picker
  Widget _buildColorPickerTab(DiaryTextData entry, StateSetter setModalState) {
    // Quick brand / popular color palette swatches
    final List<Color> quickPalette = [
      Colors.black87,
      Colors.white,
      br.green,
      br.pink,
      const Color(0xFF6B4226), // Dark Brown
      const Color(0xFF8B5E3C), // Earthy Brown
      const Color(0xFF3B5998), // Navy Blue
      const Color(0xFF800020), // Burgundy
      const Color(0xFF556B2F), // Olive Green
      const Color(0xFFB74093), // Magenta
      const Color(0xFFE07A5F), // Terracotta
      const Color(0xFFF4A261), // Sandy Orange
      const Color(0xFF2A9D8F), // Teal
      const Color(0xFF4A4E69), // Slate
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Color Palette
          Text(
            'Color Palette',
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: br.green,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickPalette.map((col) {
                final isSelected = entry.color.value == col.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      entry.color = col;
                    });
                    setModalState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? br.pink : Colors.grey[350]!,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: col.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // HSV Color Picker from flutter_hsvcolor_picker
          Text(
            'Custom HSV Color',
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: br.green,
            ),
          ),
          const SizedBox(height: 8),
          ColorPicker(
            color: entry.color,
            onChanged: (Color newColor) {
              setState(() {
                entry.color = newColor;
              });
              setModalState(() {});
            },
          ),
        ],
      ),
    );
  }

  /// Builds the customizable text field widget
  Widget _buildDiaryTextFieldWidget(DiaryTextData entry) {
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: null
        //color: Colors.white.withValues(alpha: 0.85),
        //borderRadius: BorderRadius.circular(12),
        
        /*Border.all(
          color: br.pink.withValues(alpha: 0.5),
          width: 1.2,
        ),*/
        /*boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],*/
      ),
      child: TextField(
        controller: entry.controller,
        maxLines: null,
        cursorColor: br.pink,
        style: getDiaryTextStyle(
          fontFamily: entry.fontFamily,
          fontSize: entry.fontSize,
          color: entry.color,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Type your thoughts here...',
          hintStyle: getDiaryTextStyle(
            fontFamily: entry.fontFamily,
            fontSize: entry.fontSize,
            color: entry.color.withValues(alpha: 0.4),
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
      ),
    );
  }

  /// Helper method to export all structured entry data for Supabase insertion
  Map<String, dynamic> exportDiaryEntryData({String? diaryId, String? title}) {
    return {
      'diary_id': diaryId,
      'title': title ?? 'Untitled Entry',
      'created_at': DateTime.now().toIso8601String(),
      'texts': textEntries.map((e) => e.toMap()).toList(),
      'images': imagePaths,
      'audios': audioPaths,
      'videos': videoPaths,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.fan,
        pos: ExpandableFabPos.right,
        openButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: Icon(Icons.add, color: br.pink),
          fabSize: ExpandableFabSize.regular,
          backgroundColor: br.green,
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: Icon(Icons.close, color: br.pink),
          fabSize: ExpandableFabSize.regular,
          backgroundColor: br.green,
        ),
        fanAngle: 90,
        distance: 100,
        overlayStyle: null,
        children: [
          FloatingActionButton.small(
            backgroundColor: br.pink,
            heroTag: 'text',
            tooltip: 'Add Text Field',
            onPressed: _addNewTextField,
            child: Icon(Icons.text_fields, color: br.green),
          ),
          FloatingActionButton.small(
            backgroundColor: br.pink,
            heroTag: 'image',
            tooltip: 'Add Image',
            onPressed: () {},
            child: Icon(Icons.image, color: br.green),
          ),
          FloatingActionButton.small(
            backgroundColor: br.pink,
            heroTag: 'audio',
            tooltip: 'Add Audio',
            onPressed: () {},
            child: Icon(Icons.mic, color: br.green),
          ),
          FloatingActionButton.small(
            backgroundColor: br.pink,
            heroTag: 'video',
            tooltip: 'Add Video',
            onPressed: () {},
            child: Icon(Icons.video_camera_back, color: br.green),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'lib/assets/diary_back.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.7),
          ),

          // Top Navigation Bar with Back and Save/Info
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: br.green, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                 

                  // Data / Save Indicator
                  Container(
                    decoration: BoxDecoration(
                      color: br.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      icon: Icon(Icons.cloud_upload_outlined, color: br.pink, size: 18),
                      label: Text(
                        'Ready',
                        style: GoogleFonts.archivo(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        final dataToSave = exportDiaryEntryData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: br.green,
                            content: Text(
                              '${textEntries.length} text elements formatted for Supabase!',
                              style: GoogleFonts.archivo(color: Colors.white),
                            ),
                          ),
                        );
                        // Data is accessible via textInfos or exportDiaryEntryData()
                        debugPrint('Supabase ready data: $dataToSave');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Canvas with all Draggable Widgets
          Stack(
            children: textEntries.map((entry) {
              return DraggableWidget(
                key: ValueKey(entry.id),
                initialX: entry.xPosition,
                initialY: entry.yPosition,
                onPositionChanged: (x, y) {
                  entry.xPosition = x;
                  entry.yPosition = y;
                },
                headerActions: [
                  const SizedBox(width: 4),
                  // Customize Style Button
                  GestureDetector(
                    onTap: () => _showTextCustomizationSheet(entry),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: br.pink,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Delete Button
                  GestureDetector(
                    onTap: () => _removeTextField(entry),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                child: _buildDiaryTextFieldWidget(entry),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}