import "../../lib/postgres/client.dart";
import "../../lib/lang.dart";


genLargeDatabaseName(len) {
  var i, sb = new StringBuffer();
  for (i = 0; i < len; i++) {
    sb.write("a");
  }
  return sb.toString();
}

genSampleQuery1() {
  return "select tablename from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery10() {
  return "select * from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery20() {
  return "select schemaname, tablename from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery30() {
  return "select hasindexes from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery40() {
  return "select * from pg_statistic";
}


genSampleQuery50() {
  return "select * from pg_attribute";
}


genSampleQuery60() {
  return "select * from pg_attrdef";
}


genSampleQuery70() {
  return "select description from pg_description";
}


genSampleQuery80() {
  return "select * from pg_description";
}


main() {
  var pc = new PostgresClient();
  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  //pc.connect(database: genLargeDatabaseName(65535 + 10));
  //pc.connect(database: genLargeDatabaseName(300));
  p(pc);
  pc.query(genSampleQuery80());
}
