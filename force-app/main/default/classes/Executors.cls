public class Executors {
  class FieldUpdate implements ExecAnonBatch.executor {
    SObjectField field;
    Object value;
    FieldUpdate(SObjectField updateField, Object fieldValue) {
      field = updateField;
      value = fieldValue;
    }
    public void execute(Object[] scope) {
      SObject[] records = (SObject[])scope;
      for(SObject record: records) {
        record.put(field, value);
      }
      Database.update(records, false);
    }
  }
  public static ExecAnonBatch.executor updateField(SObjectField field, Object value) {
    return new FieldUpdate(field, value);
  }
}