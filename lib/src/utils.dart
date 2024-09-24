import 'package:path_provider/path_provider.dart';

List<String> splitTexts(String texts) {
  List<String> result = [];
  List<String> lines = texts.split("\n");
  bool inCodeBlock = false;
  bool inTable = false;
  bool inUnorderedList = false;
  String currentBlock = "";

  for (String line in lines) {
    if (line.trim().startsWith("```")) {
      if (inCodeBlock) {
        // end code block
        currentBlock += line;
        result.add(currentBlock);
        currentBlock = "";
        inCodeBlock = false;
      } else {
        // start new code block
        if (currentBlock.isNotEmpty) {
          result.add(currentBlock);
        }
        currentBlock = "$line\n";
        inCodeBlock = true;
      }
    } else if (line.trim().startsWith("|") || line.trim().startsWith("+-")) {
      // detect table start or continue
      if (!inTable) {
        if (currentBlock.isNotEmpty) {
          result.add(currentBlock);
        }
        currentBlock = "$line\n";
        inTable = true;
      } else {
        currentBlock += "$line\n";
      }
    } else if (inTable) {
      // Check if the table has ended
      if (line.trim().isEmpty) {
        // Empty line, end the table
        result.add(currentBlock);
        currentBlock = "";
        inTable = false;
        result.add(line); // Add the empty line as a separate item
      } else {
        // Table has ended, add the current line separately
        result.add(currentBlock);
        currentBlock = "";
        inTable = false;
        result.add(line);
      }
    } else if (line.trim().startsWith("- ") ||
        line.trim().startsWith("* ") ||
        line.trim().startsWith("+ ")) {
      // start or continue unordered list
      if (!inUnorderedList) {
        if (currentBlock.isNotEmpty) {
          result.add(currentBlock);
        }
        currentBlock = "$line\n";
        inUnorderedList = true;
      } else {
        currentBlock += "$line\n";
      }
    } else if (inUnorderedList &&
        (line.trim().isEmpty || line.trim().startsWith("  "))) {
      // continue add line in unordered list if it's not empty
      if (line.trim().isNotEmpty) {
        currentBlock += "$line\n";
      } else {
        // End the list if we encounter an empty line
        result.add(currentBlock);
        currentBlock = "";
        inUnorderedList = false;
        result.add(line); // Add the empty line as a separate item
      }
    } else if (inUnorderedList) {
      // end unordered list
      result.add(currentBlock);
      currentBlock = "";
      inUnorderedList = false;
      // handle current line not in list
      if (inCodeBlock || inTable) {
        currentBlock += "$line\n";
      } else {
        result.add(line);
      }
    } else if (inCodeBlock || inTable) {
      // continue add line in code block or table
      currentBlock += "$line\n";
    } else {
      // not in code block or table, add line separately
      if (currentBlock.isNotEmpty) {
        result.add(currentBlock);
        currentBlock = "";
      }
      result.add(line);
    }
  }

  // add last block (if any)
  if (currentBlock.isNotEmpty) {
    result.add(currentBlock);
  }

  return result.map((e) {
    if (e.endsWith('\n')) {
      e = e.trimRight();
    }
    return e;
  }).toList();

  // return result;
}

bool isInsideCodeBlock(String text, int cursorPosition) {
  RegExp codeBlockRegex = RegExp(r'```[\s\S]*?```');
  Iterable<RegExpMatch> matches = codeBlockRegex.allMatches(text);
  for (RegExpMatch match in matches) {
    if (match.start <= cursorPosition && cursorPosition <= match.end) {
      return true;
    }
  }
  return false;
}

bool isInsideTable(String text, int cursorPosition) {
  RegExp tableRegex = RegExp(r'\|.*\|[\s\S]*?\|.*\|');
  Iterable<RegExpMatch> matches = tableRegex.allMatches(text);
  for (RegExpMatch match in matches) {
    if (match.start <= cursorPosition && cursorPosition <= match.end) {
      return true;
    }
  }
  return false;
}

bool isInsideUnorderedList(String text, int cursorPosition) {
  RegExp listItemRegex =
      RegExp(r'(^|\n)[ \t]*[-*+][ \t]+.*(\n[ \t]+.*)*', multiLine: true);
  Iterable<RegExpMatch> matches = listItemRegex.allMatches(text);
  for (RegExpMatch match in matches) {
    if (match.start <= cursorPosition && cursorPosition <= match.end) {
      return true;
    }
  }
  return false;
}

Future<String> getAbsoluteImagePath(String relativePath) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$relativePath';
}
