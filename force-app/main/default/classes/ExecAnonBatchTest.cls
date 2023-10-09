@isTest class ExecAnonBatchTest {
  @isTest static void test() {
    Test.startTest();
    Database.executeBatch(
      new ExecAnonBatch(
        Generators.fromQuery('select id from user limit 1'),
        Executors.updateField(User.LastName, 'Doe')));
    Test.stopTest();
  }
}