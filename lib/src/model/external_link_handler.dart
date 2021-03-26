import 'package:external_links/src/model/external_link.dart';
import 'package:flutter/widgets.dart';

///An class which performs processing on the given link
abstract class ExternalLinkHandler {
  ///Process the given `ExternalLink`
  Future<void> processLink(ExternalLink link);
}

///An class which performs processing on the given link but using the BuildContext.
///This is useful when interaction with `Navigator` is needed.
abstract class ExternalLinkContextHandler extends ExternalLinkHandler {
  final BuildContext context;
  ExternalLinkContextHandler(this.context);

  ///Process the given `ExternalLink` with the supplied `BuildContext`
  @protected
  Future<void> processLinkWithContext(BuildContext context, ExternalLink link);

  @override
  Future<void> processLink(ExternalLink link) {
    return processLinkWithContext(context, link);
  }
}

/// A no-operation handler
class EmptyHandler extends ExternalLinkHandler {
  @override
  Future<void> processLink(ExternalLink link) {
    return Future.value();
  }
}
