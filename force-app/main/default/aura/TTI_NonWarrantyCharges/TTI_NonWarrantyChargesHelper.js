({
    setRecordValueAsPerCustomSetting : function(component,dummyObj) {
        var userType=component.get("v.userType");
        var RetailChargesCustomSetting=component.get("v.RetailChargesCustomSetting");
        var Service_Request_Case=component.get("v.Service_Request_Case");
        for(var i=0;i<RetailChargesCustomSetting.length;i++)
        {
            if(dummyObj.Line_Item_Description__c == RetailChargesCustomSetting[i].Charge_Name__c
               && RetailChargesCustomSetting[i].Size__c == Service_Request_Case.Product_Size_Category__c)
            {
                dummyObj.customSettingFound=true;
                if(userType.Account.Delivery_Country__c=='Australia')
                {
                    dummyObj.Unit_List_Price__c=RetailChargesCustomSetting[i].Retail_Charge_AUD__c;
                    dummyObj.Unit_Cost__c=RetailChargesCustomSetting[i].AUD_Cost__c;
                }
                else
                {
                    dummyObj.Unit_Cost__c=RetailChargesCustomSetting[i].NZD_Cost__c;
                    dummyObj.Unit_List_Price__c=RetailChargesCustomSetting[i].Retail_Charge_NZD__c;
                    
                }
                dummyObj.Total_List_Price__c=dummyObj.Unit_List_Price__c*dummyObj.Quantity__c;
                break;
            }else
            {
                dummyObj.customSettingFound=false;
                dummyObj.Unit_Cost__c=0;
                dummyObj.Unit_List_Price__c=0;
                dummyObj.Total_List_Price__c=0;
                dummyObj.Quantity__c=1;
            }
        }
    }
})