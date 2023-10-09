({
    populateNonWarrantyLineItemsMethod:function(component,event,helper){
        if(component.get("v.Service_Request_Case")==null || component.get("v.Service_Request_Case")==undefined)
            return;
        var action = component.get("c.getNonWarrantyServiceReqLineItem");
        action.setParams({
            "caseNumber":component.get("v.Service_Request_Case").Id
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS' && response.getReturnValue()!=null)
            {
                var NonWarrantyLineItemsList=JSON.parse(response.getReturnValue());
                var RetailChargesCustomSetting=component.get("v.RetailChargesCustomSetting");
                var Service_Request_Case=component.get("v.Service_Request_Case");
                for(var i=0;i<NonWarrantyLineItemsList.length;i++){
                    for(var j=0;j<RetailChargesCustomSetting.length;j++){
                        if(NonWarrantyLineItemsList[i].Line_Item_Description__c == RetailChargesCustomSetting[j].Charge_Name__c
                           && RetailChargesCustomSetting[j].Size__c == Service_Request_Case.Product_Size_Category__c){
                            NonWarrantyLineItemsList[i].customSettingFound=true;
                            break;
                        }
                    }
                }
                component.set("v.NonWarrantyLineItemsList",NonWarrantyLineItemsList);
            }
        });
        var getRetailChargesCustomSetting=component.get("c.getRetailChargesCustomSetting");
        getRetailChargesCustomSetting.setCallback(this,function(response){
            component.set("v.RetailChargesCustomSetting",JSON.parse(response.getReturnValue()));
            $A.enqueueAction(action);
        }); 
        $A.enqueueAction(getRetailChargesCustomSetting);   
      
    },
    addRow:function(component,event,helper){
        var NonWarrantyLineItemsList=component.get("v.NonWarrantyLineItemsList");
        var dummyObj={};
        dummyObj.Unit_Cost__c=0;
        dummyObj.Unit_List_Price__c=0;
        dummyObj.Quantity__c=1;
        dummyObj.Total_List_Price__c=0;
        dummyObj.Line_Item_Description__c="Labour";
        helper.setRecordValueAsPerCustomSetting(component,dummyObj);
        NonWarrantyLineItemsList.push(dummyObj);
        component.set("v.NonWarrantyLineItemsList",NonWarrantyLineItemsList);
    },
    LineItemDescriptionChange:function(component,event,helper){
        var index=event._source.get("v.class");
        var NonWarrantyLineItemsList=component.get("v.NonWarrantyLineItemsList");
        helper.setRecordValueAsPerCustomSetting(component,NonWarrantyLineItemsList[index]);
        component.set("v.NonWarrantyLineItemsList",NonWarrantyLineItemsList);
    },
    RemoveRow:function(component,event,helper){
        var source=event.getSource();
        var value=source.get("v.value");
        var index=source.get("v.labelClass");
        var NonWarrantyLineItemsList=component.get("v.NonWarrantyLineItemsList");
        var NonWarrantyLineItemsListToDelete=component.get("v.NonWarrantyLineItemsListToDelete");
        NonWarrantyLineItemsListToDelete.push(NonWarrantyLineItemsList[index]);
        component.set("v.NonWarrantyLineItemsListToDelete",NonWarrantyLineItemsListToDelete);
        NonWarrantyLineItemsList.splice(index,1);
        component.set("v.NonWarrantyLineItemsList",NonWarrantyLineItemsList);
        
    },
    quanityChanged:function(component,event,helper){
        var source = event.getSource();
        var index=source.get("v.labelClass");
        var NonWarrantyLineItemsList=component.get("v.NonWarrantyLineItemsList");
        NonWarrantyLineItemsList[index].Total_List_Price__c=NonWarrantyLineItemsList[index].Unit_List_Price__c * NonWarrantyLineItemsList[index].Quantity__c;
        component.set("v.NonWarrantyLineItemsList",NonWarrantyLineItemsList);
    },
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    }
})