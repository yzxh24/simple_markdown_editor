import 'package:flutter/material.dart';
import 'package:simple_markdown_editor/simple_markdown_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.deepPurple,
          surfaceTint: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.deepPurple,
          surfaceTint: Colors.transparent,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Markdown Editor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String texts = '''
## Heading 1
Some **bold** text.

```dart
void sourceCode() {
  print(123);
  print('hello world');
}
```

Another markdown *italic* item.
One more item with `code`.
![This is a image](https://blog.redis.com.cn/wp-content/uploads/2020/03/qrcode_for_gh_82cf87d482f0_258.jpg)
There has some problems with ```code```.
This editor was use flutter to build.

```js
function hello() {
  console.log('hello world');
}
```

`Cursor` is a fork of `VS Code`. This allows us to focus on making the best way to code with AI, while offering a familiar text editing experience.As a standalone application, Cursor has more control over the UI of the editor, enabling greater AI integration. Some of our features, like `Cursor` Tab and **CMD-K**, are not possible as plugins to existing coding environments.
> This is a quote

You can use a colon to define the alignment of the table, like this:
| Name   | Age |     Work |
| :----- | :--: | -------: |
| Cute |  18  | Eat cute |
| Brave little |  20  | Climb a brave tree |
| Little smart |  22  | Read a smart book |
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SimpleMarkdownEditor(
        content: texts,
        showLineNumber: false,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
        onContentChange: (content) {
          print(content);
        },
      ),
    );
  }
}
