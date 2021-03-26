import 'package:equatable/equatable.dart';
import 'package:external_links/src/model/external_link_handler.dart';
import 'package:flutter/material.dart';

typedef ExternalLinkUriFactory = ExternalLink? Function(Uri);
typedef ExternalLinkMapFactory = ExternalLink? Function(Map<String, dynamic>);

///Common interface for messages coming from push notifications or deep/universal links
abstract class ExternalLink extends Equatable {
  ///[title] is the title of the push notification
  String? get title;

  ///[content] is the content message of the push notification
  String? get content;

  ///[args] are the arguments of the push notification
  Map<String, dynamic> get args;

  ///[uri] of the deep link
  Uri? get uri;

  ///check is being logged in is required to process this link
  bool get authenticationRequired;

  ExternalLink({Uri? uri, Map<String, dynamic>? json});

  ///[getHandler] returns the handler for the link. If no operation handler is needed, return an instance of `EmptyHandler`.
  ExternalLinkHandler getHandler([BuildContext? context]);

  ///[mapFactory] is user to create links from a `Map<String,dynamic>`. Assign it as soon as possible
  static ExternalLinkMapFactory mapFactory = (_) => null;

  ///[uriFactory] is user to create links from an `Uri`. Assign it as soon as possible
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
