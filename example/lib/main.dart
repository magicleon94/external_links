import 'dart:math';

import 'package:external_links/external_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  ExternalLink.uriFactory = (uri) {
    if (uri.path == '/dummy') {
      return DummyLink();
    } else {
      return DummierLink();
    }
  };
  runApp(MyApp());
}

class DummyLink extends ExternalLink {
  @override
  Map<String, dynamic> get args => {};

  @override
  bool get authenticationRequired => false;

  @override
  String get content => 'Dummy content! #${Random().nextInt(100000)}';

  @override
  ExternalLinkHandler getHandler([BuildContext context]) {
    if (context != null) {
      return DummyLinkHandler(context);
    } else {
      return EmptyHandler();
    }
  }

  @override
  String get title => 'Dummy title!';

  @override
  Uri get uri => null;
}

class DummierLink extends ExternalLink {
  @override
  Map<String, dynamic> get args => {};

  @override
  bool get authenticationRequired => false;

  @override
  String get content => 'Dummier content! #${Random().nextInt(100000)}';

  @override
  ExternalLinkHandler getHandler([BuildContext context]) {
    if (context != null) {
      return DummyLinkHandler(context);
    } else {
      return EmptyHandler();
    }
  }

  @override
  String get title => 'Dummier title!';

  @override
  Uri get uri => null;
}

class DummyLinkHandler extends ExternalLinkContextHandler {
  DummyLinkHandler(BuildContext context) : super(context);

  @override
  Future<void> processLinkWithContext(BuildContext context, ExternalLink link) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(link.title ?? ''),
        content: Text(link.content ?? ''),
      ),
    );
  }
}

class DummyAdapter extends ExternalLinksAdapter {
  @override
  Future<void> init() async {}

  void triggerDummy(Uri uri) => emit(
        ExternalLink.uriFactory(uri),
      );
}

final dummyAdapter = DummyAdapter();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExternalLinksBloc>(
      create: (_) => ExternalLinksBloc(
        adapters: [
          dummyAdapter..init(),
        ],
      ),
      child: MaterialApp(
        title: 'External Links Demo',
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ExternalLinksListener(
      child: Scaffold(
        appBar: AppBar(
          title: Text('External links demo'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => dummyAdapter
                  .triggerDummy(Uri.parse('http://dummy.dummy/dummy')),
              child: Text(
                'Trigger dummy',
              ),
            ),
            ElevatedButton(
              onPressed: () => dummyAdapter
                  .triggerDummy(Uri.parse('http://dummy.dummy/dummier')),
              child: Text(
                'Trigger dummier',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
