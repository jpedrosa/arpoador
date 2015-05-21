library stdout;

import "../sys/moresys.dart";


class Stdout {

  write(String string) {
    MoreSys.printf(string);
    MoreSys.fflush();
  }

}
