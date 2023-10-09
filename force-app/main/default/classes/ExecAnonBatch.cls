public class ExecAnonBatch implements Database.Batchable<Object> {
  public interface generator {
    Object generate();
  }
  public interface executor {
    void execute(Object[] values);
  }
  generator gen;
  executor exec;

  public ExecAnonBatch(generator theGenerator, executor theExecutor) {
    gen = theGenerator;
    exec = theExecutor;
  }
  public Iterable<Object> start(Database.BatchableContext context) {
    return (Iterable<Object>) gen.generate();
  }
  public void execute(Database.BatchableContext context, Object[] scope) {
    exec.execute(scope);
  }
  public void finish(Database.BatchableContext context) {
  }
}