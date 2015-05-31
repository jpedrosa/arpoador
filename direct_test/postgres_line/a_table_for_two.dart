import "../../lib/postgres/client.dart";
import "../../lib/lang.dart";


genSampleQuery1() {
  return "create table for_two (id serial primary key, "
      "name1 char(50), name2 char(50))";
}


genSampleQuery10() {
  return "drop table for_two";
}


main() {
  var pc = new PostgresClient();
  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  p(pc);
  pc.query(genSampleQuery1());
}
