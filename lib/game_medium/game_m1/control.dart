class Controls {
  bool forward = false;
  bool backward = false;
  bool left = false;
  bool right = false;
  bool isDead = false;

  void stop() {
    forward = false;
    backward = false;
    left = false;
    right = false;
  }

  void moveOn() {
    //if (!bateu) {
    forward = true;
    // }
  }

  void moveBack() {
    if (!isDead) {
      backward = true;
    }
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

  void setAsDead() {
    isDead = true;
  }
}
