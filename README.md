# external_links

A package that provides abstraction to handle external links to your apps with an unified interface whether it's a push notification, a deep link, a dynamic link or whatever.

## Components
### ExternalLink
The object that represents the link information. It consists of the following properties and getters:
- `title` of the link, usually associated to the title of a push notification
- `content` of the link, usually associated to the content of a push notification
- `args` of the link, usually associated to the arguments of a push notification
- `uri`, of the link, usually associated to the conuri tent of a deep link
- `authenticationRequired` tells if is being logged in is required to process this link
- `getHandler` returns the handler for the link. If no operation handler is needed, return an instance of `EmptyHandler`.
- `mapFactory` is used to create links from a `Map<String,dynamic>`. Assign it as soon as possible
- `uriFactory` is used to create links from an `Uri`. Assign it as soon as possible

Example:
```dart
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
```

### ExternalLinkHandler and ExternalLinkContextHandler
The handler of a link. This is used to perform actions when processing the link.
Use `ExternalLinkHandler` if your actions do not need a `BuildContext` and if they do use `ExternalLinkContextHandler` instead.

Example:
```dart
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
```

### ExternalLinksAdapter
The adapter that processes information into `ExternalLink`s, which will be automatically enqueued by the `ExternalLinksBloc` the adapter is passed to.
It can be anything you need, for example you can use the following adapter if you're hooking your app to [Firebase dynamic links](https://pub.dev/packages/firebase_dynamic_links/versions/2.0.0-dev.0):

```dart
class DynamicLinkAdapter extends ExternalLinksAdapter {
  StreamSubscription? _uriChangeSubscription;

  @override
  Future<void> init() async {
    try {
      final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

      final initialUri = initialLink?.link;

      if (initialUri != null) {
        _onUriLink(initialUri);
      }

      FirebaseDynamicLinks.instance.onLink(
        onSuccess: (linkData) async => _onUriLink(linkData?.link),
      );
    } on PlatformException catch (e, stackTrace) {
      //report error
    }
  }

  void _onUriLink(Uri? uri) {
    if (uri != null) {
      final link = ExternalLink.uriFactory(uri);
      emit(link);
    }
  }

  @override
  void dispose() {
    _uriChangeSubscription?.cancel();
    super.dispose();
  }
}

```
### ExternalLinksBloc
The Bloc that manages the links queue.

Just instantiate it passing a list of `ExternalLinksAdapter` to its constructor.
Note that you might need to call `init` on yout adapters in order to setting them up (usually useful when init containts `async` operations).

The Bloc takes in a `ProcessLink` event with the informations needed to process the current link of the queue and emits the following states:

- `ExternalLinksInitial`: The initial state of the Bloc

- `ExternalLinkAvailable`: Triggered whenever a new link is available on the queue

- `ExternalLinkProcessing`: Triggered when a link is processing

- `NoExternalLinks`: Triggered when the links queue is empty

Example:
```dart
BlocProvider<ExternalLinksBloc>(
    create: (_)=>ExternalLinksBloc(
        adapters: [
            DeepLinkAdapter()..init(), //an adapter for deep links
            CloudMessagingAdapter()..init(), //an adapter for push notifications
            //any other adapter
        ],
    ),
    child: //child here. Usually the MaterialApp
)

```
### ExternalLinksListener
This is just a convenience class that listens to the `ExternalLink`s queue and processes them using their handler.
It is optional to use this and you can listen directly to the `ExternalLinksBloc` instead and decide what to do upon receiving links.

The implementation is quite simple:

```dart
class ExternalLinksListener extends StatelessWidget {
  final Widget child;
  const ExternalLinksListener({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocListener<ExternalLinksBloc, ExternalLinksState>(
      listenWhen: (previous, current) => current is ExternalLinkAvailable,
      listener: (context, state) {
        if (state is ExternalLinkAvailable) {
          BlocProvider.of<ExternalLinksBloc>(context).add(
            ProcessLink(
              processFunction: (link) {
                return link.getHandler(context).processLink(link);
              },
            ),
          );
        }
      },
      child: child,
    );
  }
}
```

### ExternalLink factories:
The `ExternalLink` class has two functions that can be assigned and used ad factory for the links:

- `mapFactory` is used to create links from a `Map<String,dynamic>`
- `uriFactory` is used to create links from an `Uri`

By default those are functions that return `null`. If you want to use them, just assign a new `Function` object to them.

These are totally optional since you are free to generate `ExternalLink`s in any way you like within an adapter, but they might be useful if you want somepalce centralized.

## Considerations
This might look overkill ad first, but in my experience a solid architecture that allows to process external links to an app in a simple way can be a life saver on the long run.

Just set how many adapters you like to receive links information, just define how many link types you need. Despite the name `Link` you can actually use this as an inside notification system in your app too, or hooking an adapter to a websocket or whatever.

Suppose you're managing Deep links, and you currently manage two URLs. Whenever a new URL is needed, just define another link with its handler and update the factory function to return that too. Nothing else is needed.

I've used this architecture in a couple of projects (enterprise ones too) and it proved itself quite useful on the long run.