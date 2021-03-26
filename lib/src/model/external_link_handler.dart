import 'package:external_links/src/model/external_link.dart';
import 'package:flutter/widgets.dart';

abstract class ExternalLinkHandler {
  Future<void> processLink(ExternalLink link);
}

abstract class ExternalLinkContextHandler extends ExternalLinkHandler {
  final BuildContext context;
  ExternalLinkContextHandler(this.context);

  @protected
  Future<void> processLinkWithContext(BuildContext context, ExternalLink link);

  @override
  Future<void> processLink(ExternalLink link) {
    return processLinkWithContext(context, link);
  }
}

class EmptyHandler extends ExternalLinkHandler {
  @override
  Future<void> processLink(ExternalLink link) {
    return Future.value();
  }
}
