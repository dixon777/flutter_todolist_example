import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class Fragment {
  Widget preBuilder(BuildContext context, WidgetBuilder scaffoldBuilder) =>
      scaffoldBuilder(context);

  PreferredSizeWidget appBarBuilder(BuildContext context) => null;
  Widget bodyBuilder(BuildContext context) => null;
  Widget bottomNavigationBarBuilder(BuildContext context) => null;
  Widget floatingActionButtonBuilder(BuildContext context) => null;
}

class FragmentScaffold extends StatelessWidget {
  final Fragment defaultFragment;
  final _FragmentBloc bloc;
  final Drawer Function(BuildContext context) drawerBuilder;
  final Drawer Function(BuildContext context) endDrawerBuilder;
  FragmentScaffold(
      {@required Fragment initFragment,
      this.defaultFragment,
      drawerBuilder,
      endDrawerBuilder})
      : bloc = _FragmentBloc(initFragment),
        this.drawerBuilder = drawerBuilder ?? ((context) => null),
        this.endDrawerBuilder = endDrawerBuilder ?? ((context) => null);

  @override
  Widget build(BuildContext context) {
    return Provider<_FragmentBloc>(
        builder: (context) => bloc,
        child: StreamBuilder<Fragment>(
            stream: bloc.fragmentStream,
            builder: (context, snapshot) {
              final fragment = snapshot.data;
              final WidgetBuilder scaffoldBuilder = (context) => Scaffold(
                    endDrawer: endDrawerBuilder(context),
                    drawer: drawerBuilder(context),
                    appBar: fragment?.appBarBuilder(context) ??
                        defaultFragment?.appBarBuilder(context),
                    body: fragment?.bodyBuilder(context) ??
                        defaultFragment?.bodyBuilder(context),
                    bottomNavigationBar: fragment
                            ?.bottomNavigationBarBuilder(context) ??
                        defaultFragment?.bottomNavigationBarBuilder(context),
                    floatingActionButton: fragment
                            ?.floatingActionButtonBuilder(context) ??
                        defaultFragment?.floatingActionButtonBuilder(context),
                  );
              return fragment?.preBuilder(context, scaffoldBuilder) ??
                  defaultFragment?.preBuilder(context, scaffoldBuilder) ??
                  Container();
            }));
  }

  static void switchFragment(BuildContext context, Fragment fragment) {
    return Provider.of<_FragmentBloc>(context).setFragment(fragment);
  }
}

class _FragmentBloc {
  final BehaviorSubject<Fragment> _fragmentStream;

  _FragmentBloc(initFragment)
      : _fragmentStream = BehaviorSubject.seeded(initFragment);

  void setFragment(fragment) => _fragmentStream.add(fragment);

  Stream<Fragment> get fragmentStream => _fragmentStream.stream;
}
