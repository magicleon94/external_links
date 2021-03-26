import 'package:external_links/src/bloc/external_links_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExternalLinksListener extends StatelessWidget {
  final Widget child;
  const ExternalLinksListener({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocListener<ExternalLinksBloc, ExternalLinksState>(
      listenWhen: (previos, current) => current is ExternalLinkAvailable,
      listener: (context, state) {
        if (state is ExternalLinkAvailable) {
          BlocProvider.of<ExternalLinksBloc>(context).add(
            ProcessLink(
              processFunction: (link) {
                return link.getHandler(context).processLink(link);
              },
            ),
          );
        }
      },
      child: child,
    );
  }
}
