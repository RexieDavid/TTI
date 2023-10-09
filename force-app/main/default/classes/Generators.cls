public class Generators {
  class QueryGenerator implements ExecAnonBatch.generator {
    String queryString;
    QueryGenerator(String query) {
      queryString = query;
    }
    public Object generate() {
      return Database.getQueryLocator(queryString);
    }
  }
  public static ExecAnonBatch.generator fromQuery(String query) {
    return new QueryGenerator(query);
  }
}