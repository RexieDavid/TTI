
//To give Profile Access to the fields to '~ CX System Admin'

String permissionId = [SELECT Id, Name, Description, IsOwnedByProfile, Profile.Name, Profile.UserLicense.Name FROM PermissionSet WHERE IsOwnedByProfile = TRUE and Profile.UserLicense.Name = 'Salesforce' and Profile.Name = '~ CX System Admin'].Id;

String fields = 'Blackhawk_Card_Product__c.Client_Program_Id__c,Blackhawk_Card_Product__c.Content_Provider_Code__c,Blackhawk_Card_Product__c.Currency__c,Blackhawk_Card_Product__c.Locale__c,Blackhawk_Card_Product__c.Logo_Image__c,Blackhawk_Card_Product__c.Parent_Brand_Name__c,Blackhawk_Card_Product__c.Product_Description__c,Blackhawk_Card_Product__c.Product_Image__c,Blackhawk_Card_Product__c.Product_Name__c,Blackhawk_Card_Product__c.Program_Name__c,Blackhawk_Card_Product__c.Program_Type__c,Blackhawk_Card_Product__c.Redemption_Info__c,Blackhawk_Card_Product__c.TNC_Text__c,Blackhawk_Card_Product__c.TNC_Type__c,Blackhawk_Card_Product__c.VR_Maximum__c,Blackhawk_Card_Product__c.VR_Minimum__c,Eligible_Customer__c.Customer_ContactId__c,Eligible_Customer__c.Customer_Name__c,Eligible_Customer__c.Customer__c,Eligible_Customer__c.Member_Benefit_Program__c,Eligible_Customer__c.Send_to_MC__c,Eligible_Product_Line_Item__c.Customer_Facing_Name__c,Eligible_Product_Line_Item__c.Eligible_Product__c,Eligible_Product_Line_Item__c.Product_Model__c,Eligible_Product_Line_Item__c.Product__c,Eligible_Product_Line_Item__c.Quantity__c,Eligible_Product_Line_Item__c.Required__c,Member_Benefit_Program__c.Activation_Validity_Days__c,Member_Benefit_Program__c.Brand__c,Member_Benefit_Program__c.Country__c,Member_Benefit_Program__c.Eligible_Products__c,Member_Benefit_Program__c.End_Date__c,Member_Benefit_Program__c.Gift_Card_Validity_Days__c,Member_Benefit_Program__c.Gift_Card_Value__c,Member_Benefit_Program__c.Product_Hierarchies__c,Member_Benefit_Program__c.Start_Date__c,Member_Benefit_Program__c.Valid_From__c,Member_Benefit_Program__c.Valid_To__c,Member_Benefit__c.Address__c,Member_Benefit__c.Benefit_Activated__c,Member_Benefit__c.Brand__c,Member_Benefit__c.Case_Age__c,Member_Benefit__c.Customer_Name__c,Member_Benefit__c.Email__c,Member_Benefit__c.Gift_Card_URL__c,Member_Benefit__c.Member_Benefit_Program__c,Member_Benefit__c.Mobile__c,Member_Benefit__c.Product_Model__c,Member_Benefit__c.Ready_for_MC__c,Member_Benefit__c.Registered_Products__c,Member_Benefit__c.Rejected_Reason__c,Member_Benefit__c.Status__c';

List<FieldPermissions> fieldPermissions = new List<FieldPermissions>();

Set<String> fields = fields.split(',');
Set<String> existingFields = new Set<String>();
Set<String,String> existingFieldsMap = new Set<String,String>();

for(FieldPermissions fieldPerm : [SELECT Id,Field FROM FieldPermissions WHERE FIELD IN:fields]){
    existingFields.add(fieldPerm.Field);
    existingFieldsMap.put(fieldPerm.Field,fieldPerm.Id);
}

for ( String fieldname: fields.split(',') ) {
    
    String objName = fieldname.split('\\.')[0];
    String fldName = fieldname.split('\\.')[1];

    Boolean isFormula = false;

    Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();

    for(Schema.SObjectField sfield : fieldMap.Values()){
        schema.describefieldresult dfield = sfield.getDescribe();
        if(fldName == dfield.getname()){
            isFormula = dfield.isCalculated();
            System.debug(dfield.getname() + ': '+ dfield.getType() + ' isCalculated() '+ dfield.isCalculated());
        } 
    }

    if(!existingFields.contains(fieldname)){
        fieldPermissions.add(new FieldPermissions(
            Field = fieldname,
            SObjectType = objName;//fieldname.split('\\.')[0],
            ParentId = permissionId,
            PermissionsRead = true,
            PermissionsEdit = isFormula ? false : true;
        ));
    }
    else{
        fieldPermissions.add(new FieldPermissions(
            Id = existingFieldsMap.get(fieldname);
            PermissionsRead = true,
            PermissionsEdit = isFormula ? false : true;
        ));
    }
}

Database.SaveResult[] saveResultList = Database.upsert(fieldPermissions, false);
Integer successCount = 0;
Integer errorCount = 0;
for (Database.SaveResult sr : saveResultList) {
    if (sr.isSuccess()) {
        successCount++;
        // Operation was successful, so get the ID of the record that was processed
        System.debug('Successfully inserted permission: ' + sr.getId());
    }
    else {
        // Operation failed, so get all errors              
        errorCount++;  
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('Permission fields that affected this error: ' + err.getFields());
        }
    }
}
System.debug('successCount >>> '+successCount);
System.debug('errorCount >>> '+errorCount);