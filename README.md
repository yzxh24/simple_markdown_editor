<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

A simple implementation of a Markdown WYSIWYG editor for flutter.

Note that it's not a proper editor implementation, just a Markdown content editing feature that I've switched to a different way of thinking.

The idea of implementation is simple.

Split the content into paragraphs, render each paragraph using flutter_markdown, use TextField to edit the content when clicking on the paragraph, and then re-render the content using flutter_markdown when the focus is removed from the TextField.

So it's simple and not for everyone, if you need complex functionality, [flutter_quill](https://pub.dev/packages/flutter_quill) might be a better choice!

## Features

Allows you to type Markdown content directly into the editor and see the rendered result directly.

Nothing else.

## Getting started

To use this package, add `simple_markdown_editor` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  simple_markdown_editor: ^0.0.1
```

Then, run `flutter pub get` in your terminal.

## Usage

To use the SimpleMarkdownEditor in your Flutter app, import the package and use the widget as follows:

```dart
import 'package:flutter/material.dart';
import 'package:simple_markdown_editor/simple_markdown_editor.dart';

class MyMarkdownEditorPage extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Markdown Editor')),
      body: SimpleMarkdownEditor(
        content: '# Initial content\n\nStart editing here...',
        /// Whether to show the line number
        showLineNumber: true,
        onContentChange: (String newContent) {
          // Handle content changes here
          print('New content: $newContent');
        },
      ),
    );
  }
}
```

## Known issues

Due to a bug in the SelectionArea component, the copied content is now not line-breaking, see [flutter/flutter#104549](https://github.com/flutter/flutter/issues/104549) and [flutter/flutter#104548](https://github.com/flutter/flutter/issues/104548) for details.

## Additional information

This package is still in early development and may have limitations or bugs. Contributions, feature requests, and bug reports are welcome on the [GitHub repository](https://github.com/yourusername/markdown_wysiwyg).

For more advanced Markdown editing features, consider using other packages like [flutter_quill](https://pub.dev/packages/flutter_quill) or [markdown_editable_textinput](https://pub.dev/packages/markdown_editable_textinput).

If you encounter any issues or have questions, please file an issue on the GitHub repository. We'll do our best to address them in a timely manner.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.