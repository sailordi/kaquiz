import 'dart:async';

class TimerAdapter {
  bool _running = false;
  late Timer _timer;
  final int minutes;
  final void Function()? onTiger;

  TimerAdapter({required this.minutes,this.onTiger});

  void start() {
    onTiger;
    _timer = Timer.periodic(Duration(minutes: minutes),(timer) { onTiger; } );
    _running = true;
  }

  void stop() {
    if(_running == false) {
      return;
    }
    _timer.cancel();
    _running = false;
  }

  void trigger() {
    stop();
    start();
  }


}