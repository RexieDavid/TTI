public class SendEmailToRefreeAndReferer {
    
    public static Id caseId;
    public class CaseWrapper{
        @InvocableVariable
        public Id caseId;
        @InvocableVariable
        public  String referralCode;
        @InvocableVariable
        public String customerContactemail;
        @InvocableVariable
        public String approvalpicklist;
        @InvocableVariable
        public String contactId;
    }
    
    @InvocableMethod(label='Send email to Refree/Referer' description='Send email to Refree/Referer')
    public static void sendEmailInvokedFromFlow(List<CaseWrapper> casewrapobj){
        List<User> userList;
        String countryName;
        if(casewrapobj[0].referralCode!=''){
            userList = [SELECT Id, email, Used_Referral_Code__c, ContactId, Contact.Country__c from User WHERE Referral_Code__c = :casewrapobj[0].referralCode AND ContactId!=null limit 1]; 
            if(userList.size() > 0){
                countryName = userList[0].Contact.Country__c;
            }
        } 
        String[] toAddresses;
        EmailTemplate emailTemplate;
        if(casewrapobj[0].approvalpicklist=='Approve'){
            Date dt = date.today();
            List<Redemption_Campaigns__c> RedemptionCampaigns = [Select RedeemableProducts__c 
                                                                 from Redemption_Campaigns__c 
                                                                 where RAF__c = true AND Country__c =:countryName AND Brand__c='AEG' 
                                                                 AND Valid_From__c <=: dt AND Valid_To__c >=:dt]; 
                                                                
            if(RedemptionCampaigns.size()>0){
                caseId = casewrapobj[0].caseId;

                emailTemplate = [Select Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where name =:System.Label.Redeem_Product_Email_Template Limit 1];
                if(userList.size() > 0){
                    sendEmail(userList[0].email,emailTemplate,userList[0].Id); 
                }

                emailTemplate = [Select Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where name =:System.Label.Redeem_Product_Email_Template_Referee Limit 1];
                sendEmail(casewrapobj[0].customerContactemail,emailTemplate,casewrapobj[0].contactId);
            }
            
        }
    }
    
    public static void sendEmail(String toAddress,EmailTemplate emailTemplate,String TargetObjectId){         
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setOrgWideEmailAddressId(System.Label.Org_Wide_Email_Address_Id);
        message.toAddresses = new String[] {toAddress};      
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(TargetObjectId);
        message.setWhatId(caseId);
        message.setSaveAsActivity(false);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    }
                
}