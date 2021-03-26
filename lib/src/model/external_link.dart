import 'package:equatable/equatable.dart';
import 'package:external_links/src/model/external_link_handler.dart';
import 'package:flutter/material.dart';

typedef ExternalLinkUriFactory = ExternalLink? Function(Uri);
typedef ExternalLinkMapFactory = ExternalLink? Function(Map<String, dynamic>);

///Common interface for messages coming from push notifications or deep/universal links
abstract class ExternalLink extends Equatable {
  ///[title] of the link, usually associated to the title of a push notification
  String? get title;

  ///[content] of the link, usually associated to the content of a push notification
  String? get content;

  ///[args] of the link, usually associated to the arguments of a push notification
  Map<String, dynamic> get args;

  ///[uri], of the link, usually associated to the conuri tent of a deep link
  Uri? get uri;

  ///[authenticationRequired] tells if is being logged in is required to process this link
  bool get authenticationRequired;

  ExternalLink({Uri? uri, Map<String, dynamic>? json});

  ///[getHandler] returns the handler for the link. If no operation handler is needed, return an instance of `EmptyHandler`.
  ExternalLinkHandler getHandler([BuildContext? context]);

  ///[mapFactory] is used to create links from a `Map<String,dynamic>`
  static ExternalLinkMapFactory mapFactory = (_) => null;

  ///[uriFactory] is used to create links from an `Uri`
  static ExternalLinkUriFactory uriFactory = (_) => null;

  @override
  List<Object?> get props => [
        title,
        content,
        uri,
        authenticationRequired,
        args,
      ];
}
