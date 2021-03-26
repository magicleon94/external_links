part of 'external_links_bloc.dart';

@immutable
abstract class ExternalLinksState extends Equatable {
  @override
  List<Object> get props => [
        //every state is different
        Random().nextInt(4294967296), //2^32
      ];
}

class ExternalLinksInitial extends ExternalLinksState {}

class ExternalLinkAvailable extends ExternalLinksState {}

class ExternalLinkProcessing extends ExternalLinksState {}

class NoExternalLinks extends ExternalLinksState {}
