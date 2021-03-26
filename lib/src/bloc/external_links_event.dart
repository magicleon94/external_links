part of 'external_links_bloc.dart';

@immutable
abstract class ExternalLinksEvent extends Equatable {
  @override
  List<Object> get props => [runtimeType];
}

///Insert a link into the queue
class _EnqueueLink extends ExternalLinksEvent {
  final ExternalLink link;

  _EnqueueLink(this.link);
}

///Process a link specifying a handler or a function
class ProcessLink extends ExternalLinksEvent {
  final ExternalLinkHandler? handler;
  final Future<void> Function(ExternalLink link)? processFunction;

  ProcessLink({
    this.handler,
    this.processFunction,
  });
}
