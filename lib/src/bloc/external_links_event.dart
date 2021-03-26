part of 'external_links_bloc.dart';

@immutable
abstract class ExternalLinksEvent extends Equatable {
  @override
  List<Object> get props => [runtimeType];
}

class EnqueueLink extends ExternalLinksEvent {
  final ExternalLink link;

  EnqueueLink(this.link);
}

class ProcessLink extends ExternalLinksEvent {
  final ExternalLinkHandler? handler;
  final Future<void> Function(ExternalLink link)? processFunction;

  ProcessLink({
    this.handler,
    this.processFunction,
  });
}
