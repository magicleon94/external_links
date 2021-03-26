import 'package:external_links/src/model/external_link.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

abstract class ExternalLinksAdapter extends Cubit<ExternalLink?> {
  ExternalLinksAdapter() : super(null);
  Future<void> init();
  @mustCallSuper
  void dispose() {
    close();
  }
}
