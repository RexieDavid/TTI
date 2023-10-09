public without sharing class TTI_SearchOrCreateCustomerController {
 /**
* @author: Shivam Singh
* @date: Dec 2017
* @description: This method used to search customer.
*/
  
    @AuraEnabled
    public static SearchOrCreateCustomerWrapper searchCustomer(string brand, string lastName, string email, string mobile, string home){
        set<Id> recordTypeId = new set<Id>();
        ID industryAssociation = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Industry Association').getRecordTypeId();
        ID endConsumer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End Consumer').getRecordTypeId();
        ID headOfficeAccountEndConsumer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Head Office Account - End-Consumer').getRecordTypeId();
        recordTypeId.add(industryAssociation);
        recordTypeId.add(endConsumer);
        recordTypeId.add(headOfficeAccountEndConsumer);
        
        list<Contact> contactObj = new list<Contact>();
        //S1 - Scenario when everything is populated
        if(lastName != null && lastName != '' && email != null && email != '' && mobile != null && mobile != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone, Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND Email=:email AND MobilePhone=:mobile AND Account.RecordTypeId IN: recordTypeId];
        }
        //S2 - Scenario when last name and home phone is blank but email and mobile is populated
        else if((lastName == null || lastName == '') && (home == null || home == '') && email != null && email != '' && mobile != null && mobile != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND Email=:email AND MobilePhone=:mobile AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S3 - Scenario when email and home phone is blank but lastname and mobile is populated
        else if((email == null || email == '') && (home == null || home == '') && lastName != null && lastName != '' && mobile != null && mobile != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND MobilePhone=:mobile AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S4 - Scenario when mobile and home phone is blank but lastname and email is populated
        else if((mobile == null || mobile == '') && (home == null || home == '') && lastName != null && lastName != '' && email != null && email != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND Email=:email AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S5 - Scenario when email and mobile is blank but lastname and home phone is populated
        else if((email == null || email == '') && (mobile == null || mobile == '') && lastName != null && lastName != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND HomePhone=:home AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S6 - Scenario when last name and mobile is blank but email and home phone is populated
        else if((lastName == null || lastName == '') && (mobile == null || mobile == '') && email != null && email != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND Email=:email AND HomePhone=:home AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S7 - Scenario when last name and email is blank but mobile and home phone is populated
        else if((lastName == null || lastName == '') && (email == null || email == '') && mobile != null && mobile != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND MobilePhone=:mobile AND HomePhone=:home AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S8 - Scenario when only home phone is blank
        else if((home == null || home == '') && lastName != null && lastName != '' && email != null && email != '' && mobile != null && mobile != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND Email=:email AND MobilePhone=:mobile AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S9 - Scenario when only mobile is blank
        else if((mobile == null || mobile == '') && lastName != null && lastName != '' && email != null && email != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND Email=:email AND HomePhone=:home AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S10 - Scenario when only email is blank
        else if((email == null || email == '') && lastName != null && lastName != '' && mobile != null && mobile != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND LastName=:lastName AND MobilePhone=:mobile AND HomePhone=:home AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }
        //S11 - Scenario when only last name is blank
        else if((lastName == null || lastName == '') && email != null && email != '' && mobile != null && mobile != '' && home != null && home != ''){
            contactObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet 
                            FROM Contact WHERE Brand__c=:brand AND Email=:email AND MobilePhone=:mobile AND HomePhone=:home AND Account.RecordTypeId IN: recordTypeId AND Account.Record_Status__c ='Active'];
        }

        System.debug('RDAVID >>> contactObj >>> '+contactObj);

        if(contactObj.size() == 1){
            SearchOrCreateCustomerWrapper SearchOrCreateCustomerWrapperObj = new SearchOrCreateCustomerWrapper(contactObj[0], null,false);
            return SearchOrCreateCustomerWrapperObj;
        }      
        
        
        else if(contactObj.size() == 0 || contactObj.size() > 1){
            ID B2CConsumerContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2C Consumer Contact').getRecordTypeId();
            list<Contact> personAccountObj = new list<Contact>();
            //S1 - Scenario when everything is populated
            if(lastName != null && lastName != '' && email != null && email != '' && mobile != null && mobile != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND Account.PersonEmail=:email AND 
                                    Account.PersonMobilePhone=:mobile AND Account.RecordTypeId =: B2CConsumerContact AND
                                    Account.PersonHomePhone=:home AND Account.Record_Status__c ='Active'];
            }
            //S2 - Scenario when last name and home phone is blank but email and mobile is populated
            else if((lastName == null || lastName == '') && (home == null || home == '') && email != null && email != '' && mobile != null && mobile != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact WHERE 
                                    Brand__c=:brand AND Account.PersonEmail=:email AND
                                    Account.PersonMobilePhone=:mobile AND Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S3 - Scenario when email and home phone is blank but lastname and mobile is populated
            else if((email == null || email == '') && (home == null || home == '') && lastName != null && lastName != '' && mobile != null && mobile != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND 
                                    Account.PersonMobilePhone=:mobile AND Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S4 - Scenario when mobile and home phone is blank but lastname and email is populated
            else if((mobile == null || mobile == '') && (home == null || home == '') && lastName != null && lastName != '' && email != null && email != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND Account.PersonEmail=:email AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S5 - Scenario when email and mobile is blank but lastname and home phone is populated
            else if((email == null || email == '') && (mobile == null || mobile == '') && lastName != null && lastName != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND Account.PersonHomePhone=:home AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S6 - Scenario when last name and mobile is blank but email and home phone is populated
            else if((lastName == null || lastName == '') && (mobile == null || mobile == '') && email != null && email != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.PersonEmail=:email AND Account.PersonHomePhone=:home AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S7 - Scenario when last name and email is blank but mobile and home phone is populated
            else if((lastName == null || lastName == '') && (email == null || email == '') && mobile != null && mobile != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.PersonMobilePhone=:mobile AND Account.PersonHomePhone=:home AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S8 - Scenario when only home phone is blank
            else if((home == null || home == '') && lastName != null && lastName != '' && email != null && email != '' && mobile != null && mobile != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND Account.PersonEmail=:email AND Account.PersonMobilePhone=:mobile AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S9 - Scenario when only mobile is blank
            else if((mobile == null || mobile == '') && lastName != null && lastName != '' && email != null && email != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND Account.PersonEmail=:email AND Account.PersonHomePhone=:home AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S10 - Scenario when only email is blank
            else if((email == null || email == '') && lastName != null && lastName != '' && mobile != null && mobile != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.LastName=:lastName AND Account.PersonMobilePhone=:mobile AND Account.PersonHomePhone=:home AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }
            //S11 - Scenario when only last name is blank
            else if((lastName == null || lastName == '') && email != null && email != '' && mobile != null && mobile != '' && home != null && home != ''){
                personAccountObj = [SELECT Id,HasOptedOutOfEmail, FirstName, LastName, Brand__c, MobilePhone, HomePhone,Email,MailingAddress,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet FROM Contact  WHERE 
                                    Brand__c=:brand AND Account.PersonEmail=:email AND Account.PersonMobilePhone=:mobile AND Account.PersonHomePhone=:home AND 
                                    Account.RecordTypeId =: B2CConsumerContact AND Account.Record_Status__c ='Active'];
            }

            System.debug('RDAVID >>> personAccountObj >>> '+personAccountObj);
            System.debug('RDAVID >>> personAccountObj.size() >>> '+personAccountObj.size());

            if(personAccountObj.size() == 1){
                SearchOrCreateCustomerWrapper SearchOrCreateCustomerWrapperObj = new SearchOrCreateCustomerWrapper(personAccountObj[0], null,false); 
                return SearchOrCreateCustomerWrapperObj;
            }
            else if(personAccountObj.size() == 0 || personAccountObj.size() > 1){
                string errorMessage = 'We could not accurate locate the customer you are looking for.  Please try again or click on the New button to input the customer information';
                SearchOrCreateCustomerWrapper SearchOrCreateCustomerWrapperObj = new SearchOrCreateCustomerWrapper(null, errorMessage, true); 
                return SearchOrCreateCustomerWrapperObj;
                
            }
            
        }
        
        return null;
        
    }
    // Wrapper class to hold value.
    public class SearchOrCreateCustomerWrapper{
        
        @AuraEnabled
        public Contact contactObj;
        
        @AuraEnabled
        public String errorMessage;
        
        @AuraEnabled
        public Boolean isError;
        
        public SearchOrCreateCustomerWrapper(Contact contactObj, String errorMessage, Boolean isError){
            this.contactObj=contactObj;
            this.errorMessage=errorMessage;
            this.isError=isError;
        }
        
    }
    
}