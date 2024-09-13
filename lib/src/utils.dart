List<String> splitTexts(String texts) {
  List<String> result = [];
  List<String> lines = texts.split("\n");
  bool inCodeBlock = false;
  bool inTable = false;
  String currentBlock = "";

  for (String line in lines) {
    if (line.trim().startsWith("```")) {
      if (inCodeBlock) {
        // 结束代码块
        currentBlock += "$line\n";
        result.add(currentBlock);
        currentBlock = "";
        inCodeBlock = false;
      } else {
        // 开始新的代码块
        if (currentBlock.isNotEmpty) {
          result.add(currentBlock);
        }
        currentBlock = "$line\n";
        inCodeBlock = true;
      }
    } else if (line.trim().startsWith("|") || line.trim().startsWith("+-")) {
      // 检测表格开始或继续
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
      // 检测表格结束
      result.add(currentBlock);
      currentBlock = "";
      inTable = false;
    } else if (inCodeBlock || inTable) {
      // 在代码块或表格内，继续添加行
      currentBlock += "$line\n";
    } else {
      // 不在代码块或表格内，单独添加行
      if (currentBlock.isNotEmpty) {
        result.add(currentBlock);
        currentBlock = "";
      }
      result.add(line);
    }
  }

  // 添加最后一个块（如果有的话）
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
