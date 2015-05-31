library stdout;

import "../sys/moresys.dart";


class Stdout {

  write(String string) {
    MoreSys.print(string);
    MoreSys.fflush();
  }

}
