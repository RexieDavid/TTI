@isTest
public class InventoryTriggerDataServiceMock implements System.StubProvider {
    public Object handleMethodCall(
        Object stubbedObject, 
        String stubbedMethodName, 
        Type returnType, 
        List<Type> listOfParamTypes, 
        List<String> listOfParamNames, 
        List<Object> listOfArgs) { 

        switch on stubbedMethodName { 
            when 'fetchSAPUsers' {
                return this.createUsers();
            }
            when else {
                NoSuchElementException nsee = new NoSuchElementException();
                nsee.setMessage('The method called currently isn\'t set up and cannot be mocked.');
                throw nsee;
            }
        }
    }

    /**********************************************************************
     * @description                     Create dummy Users
     * 
     * @return                          List of user records
     */
    private List<User> createUsers() {
        List<User> users = TestUtilityClass.createUser('INV-', 1000);
        for (User user : users) {
            // Need a valid Id 
            user.Id = UserInfo.getUserId();
        }
        return users;
    }
}