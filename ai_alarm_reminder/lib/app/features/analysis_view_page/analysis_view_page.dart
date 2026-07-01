import 'dart:io';

import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class SavedAnalysisViewPage extends StatefulWidget {
  final String fileName;

  final String file;

  final String extractedText;

  final String analysisResult;

  const SavedAnalysisViewPage({
    super.key,
    required this.fileName,
    required this.file,
    required this.extractedText,
    required this.analysisResult,
  });

  @override
  State<SavedAnalysisViewPage> createState() => _SavedAnalysisViewPageState();
}

class _SavedAnalysisViewPageState extends State<SavedAnalysisViewPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _image;
  String _extractedText = "";
  final String _analysisResult = "";
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
                    hintText: 'Type File Name..',
                    hintStyle:
                        TextStyle(fontSize: 15, color: AppColors.greyText),
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
                  _image != null
                      ? Image.file(File(_image!), fit: BoxFit.contain)
                      : InkWell(
                          child: Container(
                            height: 300,
                            // radius: 80,
                            color: Colors.grey,
                            child: const Icon(
                              FontAwesomeIcons.photoFilm,
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
                            "Extracted Text:\n$_extractedText",
                            style: const TextStyle(fontSize: 16),
                          ),

                        // Markdown for analysis result
                        SingleChildScrollView(
                          child: Markdown(
                            selectable: true,
                            data: _displayedText,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            styleSheet: MarkdownStyleSheet(
                              textAlign: WrapAlignment.end,
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
