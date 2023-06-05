class Controls {
  bool forward = false;
  bool backward = false;
  bool left = false;
  bool right = false;

  void stop() {
    forward = false;
    backward = false;
    left = false;
    right = false;
  }

  void moveOn() {
    forward = true;
  }

  void moveBack() {
    backward = true;
  }

  void turnRight() {
    right = true;
  }

  void turnLeft() {
    left = true;
  }

  bool isStop() {
    return !forward && !backward && !left && !right;
  }
}
