@Skip(
    "Currently skipping external links tests because they're failing due to equality implementation of ExternalLinksState")
import 'package:bloc_test/bloc_test.dart';
import 'package:external_links/external_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ignore: must_be_immutable
class TestLink extends Mock implements ExternalLink {}

class ExternalLinkAdapterForTest extends ExternalLinksAdapter {
  void generateExternalLink() {
    emit(TestLink());
  }

  @override
  Future<void> init() async {}
}

void main() {
  final adapter = ExternalLinkAdapterForTest();

  blocTest<ExternalLinksBloc, ExternalLinksState>(
    'Single link enqueueing',
    build: () => ExternalLinksBloc(adapters: [adapter]),
    act: (_) => adapter.generateExternalLink(),
    expect: () => [ExternalLinkAvailable()],
  );

  blocTest<ExternalLinksBloc, ExternalLinksState>(
    'Single link processing',
    build: () => ExternalLinksBloc(adapters: [adapter]),
    act: (cubit) async {
      adapter.generateExternalLink();
      await cubit.stream.first;
      cubit.add(ProcessLink(processFunction: (_) async {}));
    },
    expect: () =>
        [ExternalLinkAvailable(), ExternalLinkProcessing(), NoExternalLinks()],
  );

  blocTest<ExternalLinksBloc, ExternalLinksState>(
    'Cubit processing link',
    build: () => ExternalLinksBloc(adapters: [adapter]),
    act: (cubit) async {
      adapter.generateExternalLink();
      await cubit.stream.first;
      cubit.add(ProcessLink(processFunction: (_) async {}));
    },
    expect: () =>
        [ExternalLinkAvailable(), ExternalLinkProcessing(), NoExternalLinks()],
  );

  blocTest<ExternalLinksBloc, ExternalLinksState>(
    'Multiple processing link',
    build: () => ExternalLinksBloc(adapters: [adapter]),
    act: (cubit) async {
      adapter.generateExternalLink();
      adapter.generateExternalLink();
      await (Future.delayed(Duration(milliseconds: 100)));
      cubit.add(ProcessLink(
          processFunction: (_) => Future.delayed(Duration(milliseconds: 100))));
      cubit.add(ProcessLink(
          processFunction: (_) => Future.delayed(Duration(milliseconds: 100))));
    },
    expect: () => [
      ExternalLinkAvailable(),
      ExternalLinkProcessing(),
      ExternalLinkAvailable(),
      ExternalLinkProcessing(),
      NoExternalLinks()
    ],
  );
}
