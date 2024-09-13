import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/themes/vs2015.dart';
import 'package:simple_markdown_editor/src/utils.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';

class SimpleMarkdownEditor extends StatefulWidget {
  final String content;
  final bool showLineNumber;
  final Function(String)? onContentChange;

  const SimpleMarkdownEditor(
      {super.key,
      required this.content,
      this.onContentChange,
      this.showLineNumber = true});

  @override
  State<SimpleMarkdownEditor> createState() => SimpleMarkdownEditorEditorState();
}

class SimpleMarkdownEditorEditorState extends State<SimpleMarkdownEditor> {
  List<String> texts = [];

  int? editingIndex;
  final TextEditingController _controller = TextEditingController();
  int? _cursorPosition;
  final List<FocusNode> _focusNodes = [];

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    texts = splitTexts(widget.content);
    _controller.addListener(_updateText);
    for (int i = 0; i < texts.length; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateText);
    _controller.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateText() {
    if (editingIndex != null) {
      texts[editingIndex!] = _controller.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: ListView.builder(
      itemCount: texts.length,
      itemBuilder: (context, index) {
        double width = 22.0 +
            (texts.length >= 100 ? 8 : 0) +
            (texts.length >= 1000 ? 10 : 0) +
            (texts.length >= 10000 ? 4 : 0);

        return GestureDetector(
          onTapDown: (details) => onTapDown(details, index),
          onTap: () => onTap(index),
          // behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showLineNumber) ...[
                  SizedBox(
                    width: width,
                    child: SelectionContainer.disabled(
                        child: Text((index + 1).toString(),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                            ))),
                  )
                ],
                const SizedBox(width: 22.0),
                Expanded(
                  child: index == editingIndex
                      ? textInput(index)
                      : textView(index),
                )
              ],
            ),
          ),
        );
      },
    ));
  }

  void onTap(int index) {
    setState(() {
      editingIndex = index;
      _controller.text = texts[index];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cursorPosition != null) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _cursorPosition!),
        );
      }
      _focusNodes[index].requestFocus();
    });
  }

  int onTapDown(TapDownDetails details, int index) {
    return _cursorPosition =
        _getTextPositionFromGlobalPosition(details.globalPosition, index);
  }

  Widget textView(int index) {
    return texts[index].isEmpty
        ? SizedBox(
            height: 20,
            child: Container(
              color: Colors.transparent,
            ),
          )
        : MarkdownBody(
            data: texts[index],
            selectable: false,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16),
              codeblockDecoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              blockquoteDecoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[200],
                border: Border(
                  left: BorderSide(
                    color: Colors.grey[400]!,
                    width: 4,
                  ),
                ),
              ),
            ),
            builders: {
              'code': SyntaxHighlightBuilder(),
            },
          );
  }

  Widget textInput(int index) {
    /// then create a new line, the _controller.text will be '\n',
    /// but the texts[index] will be empty, so we need to trim the _controller.text
    if (_controller.text.isNotEmpty &&
        _controller.text.length == 1 &&
        _controller.text.endsWith('\n')) {
      _controller.text = _controller.text.trim();
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (keyEvent) {
        if (keyEvent is KeyDownEvent) {
          if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
            final currentText = _controller.text;
            if (currentText.isEmpty && texts.length > 1) {
              _deleteCurrentLine(index);
            }
          } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
            _insertNewLine();
          }
        }
      },
      child: TextField(
        controller: _controller,
        focusNode: _focusNodes[index],
        style: const TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {
            texts[editingIndex!] = value;
          });
        },
        onTapOutside: (event) {
          setState(() {
            editingIndex = null;
          });
        },
      ),
    );
  }

  void _insertNewLine() {
    setState(() {
      int currentIndex = editingIndex!;
      String currentText = _controller.text;
      int cursorPosition = _controller.selection.baseOffset;

      // Check if we're inside a code block or table
      bool insideCodeBlock = isInsideCodeBlock(currentText, cursorPosition);
      bool insideTable = isInsideTable(currentText, cursorPosition);

      if (insideCodeBlock || insideTable) {
        // If inside a code block or table, just insert a newline character
        String newText =
            '${currentText.substring(0, cursorPosition)}${currentText.substring(cursorPosition)}';
        texts[currentIndex] = newText;
        _controller.text = newText;
        _controller.selection =
            TextSelection.fromPosition(TextPosition(offset: cursorPosition));
      } else {
        // Handle newline outside of code block
        String beforeCursor =
            currentText.substring(0, cursorPosition).trimRight();
        String afterCursor = cursorPosition < currentText.length
            ? currentText.substring(cursorPosition).trimLeft()
            : '';

        texts[currentIndex] = beforeCursor;
        texts.insert(currentIndex + 1, afterCursor);
        _focusNodes.insert(currentIndex + 1, FocusNode());

        editingIndex = currentIndex + 1;
        _controller.text = afterCursor;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.selection = const TextSelection.collapsed(offset: 0);
          _focusNodes[editingIndex!].requestFocus();
        });
      }
    });
  }

  int _getTextPositionFromGlobalPosition(Offset globalPosition, int index) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: texts[index], style: const TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter
        .getPositionForOffset(localPosition - const Offset(16, 0))
        .offset;
  }

  void _deleteCurrentLine(int index) {
    setState(() {
      texts.removeAt(index);
      _focusNodes.removeAt(index);

      /// update editingIndex, but not change the current line content
      if (index > 0) {
        editingIndex = index - 1;
      } else if (texts.isNotEmpty) {
        editingIndex = 0;
      } else {
        editingIndex = null;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editingIndex != null) {
        /// set focus to the new current line
        _focusNodes[editingIndex!].requestFocus();

        /// set controller's text, and set cursor to the end
        _controller.text = texts[editingIndex!];
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }
}

class SyntaxHighlightBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'code') {
      String language = '';
      if (element.attributes.containsKey('class')) {
        language = element.attributes['class']!.split('-')[1];
      }
      if (language.isNotEmpty) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: HighlightView(
                /// remove the last newline character, otherwise there will be an extra empty line
                element.textContent.trim(),
                language: language,
                theme: vs2015Theme,
                padding: const EdgeInsets.all(8.0),
                textStyle: const TextStyle(fontSize: 14.0),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: element.textContent)),
                child: Text(language,
                    style: TextStyle(
                      color: Colors.grey[400],
                    )),
              ),
            ),
          ],
        );
      }
    }
    return null;
  }
}
