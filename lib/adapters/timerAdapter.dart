import 'dart:async';

class TimerAdapter {
  bool _running = false;
  late Timer _timer;
  final int time;
  final void Function()? onTiger;

  TimerAdapter({required this.time,this.onTiger});

  void start() {
    onTiger;
    _timer = Timer.periodic(Duration(seconds: time),(timer) { onTiger; } );
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