import 'package:external_links/src/model/external_link.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

///The adapter that processes information into `ExternalLink`s, which will be automatically enqueues by the `ExternalLinksBloc` the adapter is passed to.
abstract class ExternalLinksAdapter extends Cubit<ExternalLink?> {
  ExternalLinksAdapter() : super(null);
  Future<void> init();
  @mustCallSuper
  void dispose() {
    close();
  }
}
