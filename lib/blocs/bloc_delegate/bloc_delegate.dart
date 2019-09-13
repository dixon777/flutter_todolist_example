import 'package:bloc/bloc.dart';

class CustomBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print("onEvent: $event");
    super.onEvent(bloc, event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    print("Error: $error");
    super.onError(bloc, error, stacktrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    
    print("onTransition event: ${ transition.event}");
    print("onTransition state: ${transition.currentState} -> ${transition.nextState}");
    super.onTransition(bloc, transition);
  }

}