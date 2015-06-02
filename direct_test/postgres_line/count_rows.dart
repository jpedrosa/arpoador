import "../../lib/postgres/client.dart";
import "../../lib/lang.dart";


genSampleQuery1() {
  return "select count(*) from pg_description";
}


main() {
  var pc = new PostgresClient();
  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  pc.query(genSampleQuery1());
}
