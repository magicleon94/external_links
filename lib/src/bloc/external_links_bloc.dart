import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:external_links/src/adapters/external_links_adapter.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/external_link_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'external_links_event.dart';
part 'external_links_state.dart';

///The bloc that manages the links queue
class ExternalLinksBloc extends Bloc<ExternalLinksEvent, ExternalLinksState> {
  final _providersSubscriptions = <StreamSubscription>[];

  final _queue = ListQueue<ExternalLink>();

  ///Returns `true` if there's a link to process
  bool get hasLinkToProcess => state.runtimeType == ExternalLinkAvailable;

  ///Returns `true` if the bloc is processing a link right now
  bool get isProcessing => state.runtimeType == ExternalLinkProcessing;

  ExternalLinksBloc({
    List<ExternalLinksAdapter> adapters = const <ExternalLinksAdapter>[],
  }) : super(ExternalLinksInitial()) {
    adapters.forEach(
      (provider) {
        final subscription = provider.stream.listen(_enqueueLink);
        _providersSubscriptions.add(subscription);
      },
    );
  }

  void _enqueueLink(ExternalLink? link) {
    if (link != null) {
      add(_EnqueueLink(link));
    }
  }

  Future<void> _processLink(ProcessLink event) async {
    if (event.handler == null && event.processFunction == null) {
      return;
    }
    final link = _queue.removeFirst();
    return event.handler?.processLink(link) ??
        event.processFunction?.call(link);
  }

  @override
  Future<void> close() {
    _providersSubscriptions.forEach(
      (subscription) {
        subscription.cancel();
      },
    );
    return super.close();
  }

  @override
  Stream<ExternalLinksState> mapEventToState(ExternalLinksEvent event) async* {
    if (event is _EnqueueLink) {
      _queue.addFirst(event.link);
      yield ExternalLinkAvailable();
    } else if (event is ProcessLink) {
      yield ExternalLinkProcessing();
      await _processLink(event);
      if (_queue.isEmpty) {
        yield NoExternalLinks();
      } else {
        yield ExternalLinkAvailable();
      }
    }
  }
}
