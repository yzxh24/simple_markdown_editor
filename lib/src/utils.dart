List<String> splitTexts(String texts) {
  List<String> result = [];
  List<String> lines = texts.split("\n");
  bool inCodeBlock = false;
  bool inTable = false;
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
    } else if (inTable && line.trim().isEmpty) {
      // detect table end
      result.add(currentBlock);
      currentBlock = "";
      inTable = false;
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

  return result;
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
