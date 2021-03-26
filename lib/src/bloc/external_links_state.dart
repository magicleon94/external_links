part of 'external_links_bloc.dart';

@immutable
abstract class ExternalLinksState extends Equatable {
  @override
  List<Object> get props => [
        //every state is different
        Random().nextInt(4294967296), //2^32
      ];
}

///The initial state of the Bloc
class ExternalLinksInitial extends ExternalLinksState {}

///Triggered whenever a new link is available on the queue
class ExternalLinkAvailable extends ExternalLinksState {}

///Triggered when a link is processing
class ExternalLinkProcessing extends ExternalLinksState {}

///Triggered when the links queue is empty
class NoExternalLinks extends ExternalLinksState {}
