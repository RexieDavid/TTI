/**
* @author: Stephen James Laylo
* @date: May 2017
* @description: This class handles all CRUD operations for the
* User Trigger. All logic should be placed here and not in the
* trigger itself
*/ 
public class UserTriggerHandler {
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles all on Before Insert
    * functionalities of the User
    */ 
    public static void onBeforeInsert(List<User> newUsers) {
        copyAccountIdToTemporaryField(newUsers);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles all on Before Update
    * functionalities of the User
    */ 
    public static void onBeforeUpdate(List<User> newUsers, Map<Id, User> oldUsersMap) {
        copyAccountIdToTemporaryField(newUsers);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles all on After Insert
    * functionalities of the User
    */ 
    public static void onAfterInsert(List<User> newUsers) {
        refreshIsCommunityUserValue(newUsers);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles all on After Update
    * functionalities of the User
    */ 
    public static void onAfterUpdate(List<User> newUsers, Map<Id, User> oldUsersMap) {
        refreshIsCommunityUserValue(newUsers);
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles the value of custom Account Id
    */ 
    public static void copyAccountIdToTemporaryField(List<User> newUsers) {
        for (User u : newUsers) {
            if (u.ContactId != null) {
                u.Account_Id__c = u.Contact_Account_Id__c;
            }
        }
    }
    
    /**
    * @author: Stephen James Laylo
    * @date: May 2017
    * @description: This method handles the value of Is Community User checkbox
    */ 
    public static void refreshIsCommunityUserValue(List<User> newUsers) {
        Map<Id, User> usersMap = new Map<Id, User>();
        
        for (User u : newUsers) {
            if (u.Account_Id__c != null) {
                usersMap.put(u.Account_Id__c, u);
            }
        }

        List<Account> accounts = [SELECT Id, Is_Community_User__c FROM Account WHERE RecordType.Name = 'B2C Consumer Contact' AND Id IN :usersMap.keySet()];

        if (System.isFuture() || System.isBatch()) {
            updateUserAccountsSynchronously(accounts);
        } else {
            updateUserAccountsAsynchronously(JSON.serialize(accounts));
        }
    }
    
    @future
    private static void updateUserAccountsAsynchronously(String serializedAccountIds) {
        List<Account> accounts = (List<Account>) JSON.deserialize(serializedAccountIds, List<Account>.class);
        
        try {
            update accounts;
        } catch (Exception err) { }
    }
    
    private static void updateUserAccountsSynchronously(List<Account> accounts) {
        try {
            update accounts;
        } catch (Exception err) { }
    }
    
}