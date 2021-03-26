import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:external_links/src/adapters/external_links_adapter.dart';
import 'package:external_links/src/model/external_link.dart';
import 'package:external_links/src/model/external_link_handler.dart';
import 'package:meta/meta.dart';

part 'external_links_event.dart';
part 'external_links_state.dart';

class ExternalLinksBloc extends Bloc<ExternalLinksEvent, ExternalLinksState> {
  final _providersSubscriptions = <StreamSubscription>[];

  final _queue = ListQueue<ExternalLink>();

  bool get hasLinkToProcess => state.runtimeType == ExternalLinkAvailable;
  bool get isProcessing => state.runtimeType == ExternalLinkProcessing;

  ExternalLinksBloc(
      {List<ExternalLinksAdapter> adapters = const <ExternalLinksAdapter>[]})
      : super(ExternalLinksInitial()) {
    adapters.forEach(
      (provider) {
        final subscription = provider.stream.listen(_enqueueLink);
        _providersSubscriptions.add(subscription);
      },
    );
  }

  void _enqueueLink(ExternalLink? link) {
    if (link != null) {
      add(EnqueueLink(link));
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
    if (event is EnqueueLink) {
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
