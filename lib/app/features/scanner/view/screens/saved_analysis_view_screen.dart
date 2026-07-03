import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:avo_app/app/core/Language/locale_keys.g.dart';



class SavedAnalysisViewScreen extends StatefulWidget {
  final String fileName;

  final String file;

  final String extractedText;

  final String analysisResult;

  const SavedAnalysisViewScreen({
    super.key,
    required this.fileName,
    required this.file,
    required this.extractedText,
    required this.analysisResult,
  });

  @override
  State<SavedAnalysisViewScreen> createState() => _SavedAnalysisViewScreenState();
}

class _SavedAnalysisViewScreenState extends State<SavedAnalysisViewScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _image;
  String _extractedText = "";

  String _displayedText = "";
  bool saved = true;

  @override
  void initState() {
    super.initState();
    _image = widget.file;

    _nameController.text = widget.fileName;
    _displayedText = widget.analysisResult;
    _extractedText = widget.extractedText;

    // Extract text from image on initialization
    // _extractTextFromImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: TextField(
                  readOnly: true,
                  controller: _nameController,
                  onChanged: (value) => setState(() {}),
                  textAlign:
                      detectArabicOrEnglish(_nameController.text) == 'Arabic'
                          ? TextAlign.right
                          : TextAlign.left,
                  textDirection:
                      detectArabicOrEnglish(_nameController.text) == 'Arabic'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                  style: const TextStyle(fontFamily: 'cairo', fontSize: 20),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: LocaleKeys.scanner_type_file_name.tr(),
                    hintStyle:
                        TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),

                // leading: IconButton(
                //     onPressed: () => Navigator.pop,
                //     icon: const Icon(CupertinoIcons.xmark)),
                floating: false,
                pinned: true,
                scrolledUnderElevation: 0,
                snap: false,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // Image display
                  _image != null && _image!.isNotEmpty
                      ? (_image!.startsWith('http')
                          ? Image.network(_image!, fit: BoxFit.contain)
                          : Image.file(File(_image!), fit: BoxFit.contain))
                      : InkWell(
                          child: Container(
                            height: 300,
                            // radius: 80,
                            color: Colors.grey,
                            child: const Icon(
                              Icons.photo_library,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),

                  // Extracted Text and Analysis
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Original extracted text
                        if (_extractedText.isNotEmpty)
                          Text(
                            LocaleKeys.scanner_extracted_text.tr(args: [_extractedText]),
                            style: const TextStyle(fontSize: 16),
                          ),

                        // Markdown for analysis result
                        Directionality(
                          textDirection: detectArabicOrEnglish(_displayedText) == 'Arabic'
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: MarkdownBody(
                            selectable: true,
                            data: _displayedText,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String detectArabicOrEnglish(String text) {
    if (text.isEmpty) return "Unknown";

    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(text)) return "Arabic";

    final englishRegex = RegExp(r'[a-zA-Z]');
    return englishRegex.hasMatch(text) ? "English" : "Unknown";
  }
}
