import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:convert';

import 'pages/collections_overview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QAPIC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 71, 160, 233)),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'QAPIC', collections: CollectionsManager()),
    );
  }
}

String collectionTemplate = '''{
  "collections": [
    {
      "collectionName": "example",
      "requestGroups": [
        {
          "requestGroupName": "exampleGroup",
          "requests": [
            {
              "requestName": "exampleRequest"
            }
          ]
        }
      ]
    }
  ]
}''';

class CollectionsManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final bool exists = await File('$path/collection.json').exists();
    if (exists) {
      return File('$path/collection.json');
    } else {
      File file = File('$path/collections.json');
      file.writeAsString(collectionTemplate);
      return File('$path/collections.json');
    }
  }

  Future<Map<String, dynamic>> readCollectionsFile() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final collections = jsonDecode(contents) as Map<String, dynamic>;
      print('collections raw: $collections');
      return collections;
    } catch (error) {
      return {};
    }
  }

  Future<File> writeCollections(Map collection) async {
    final file = await _localFile;

    return file.writeAsString('$collection');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.collections});

  final String title;

  final CollectionsManager collections;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  Map<String, dynamic> collectionsFile = {};
  Map<String, dynamic> currentCollection = {};

  @override
  void initState() {
    super.initState();
    widget.collections.readCollectionsFile().then((value) {
      setState(() {
        collectionsFile = value;
        currentCollection = collectionsFile['collections'][0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    print('current collection: $currentCollection');

    Widget page = CollectionsPage(collections: collectionsFile['collections'],);
    switch (selectedIndex) {
      case 0:
        page = CollectionsPage(collections: collectionsFile['collections'],);
    }

    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
          leading: 
            IconButton(
                onPressed: () => setState(() => selectedIndex = 0),
                icon: const Icon(Icons.home_outlined),
                iconSize: 40), 
                
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return Row(children: [
            NotificationListener<CollectionChanged>(
                child: Expanded(child: mainArea),
                onNotification: (n) {
                  setState(() {
                    // currentCollection = collectionsFile[n.val];
                    // print (collectionsFile);
                  });
                  return true;
                }),
          ]);
        }));
  }
}
