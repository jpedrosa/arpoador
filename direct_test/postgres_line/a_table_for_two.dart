import "../../lib/postgres/client.dart";
import "../../lib/lang.dart";


genSampleQuery1() {
  return "create table for_two (id serial primary key, "
      "name1 varchar(50), name2 varchar(50))";
}


genSampleQuery10() {
  return "drop table for_two";
}


genSampleQuery20() {
  return "  "; // Purposefully empty.
}


genSampleQuery30() {
  return "insert into for_two (name1, name2) values ('Magnus', 'Beth')";
}


genSampleQuery40() {
  return "select * from for_two";
}


main() {
  var r, pc = new PostgresClient();
  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  p(pc);
  r = pc.query(genSampleQuery40());
  p(["results", r]);
}
