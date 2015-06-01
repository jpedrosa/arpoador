import "../../lib/postgres/client.dart";
import "../../lib/lang.dart";


genSampleQuery80() {
  return "select * from pg_description";
}


main() {
  var pc = new PostgresClient();
//  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  pc.connect(address: "127.0.0.1", port: 5555); // connect to the straw server.
  p(pc);
  pc.query(genSampleQuery80());
}
