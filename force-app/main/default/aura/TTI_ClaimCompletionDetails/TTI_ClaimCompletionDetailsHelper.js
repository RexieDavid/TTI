({
	populateRepairType : function(component) {
		let faultCode = component.get("v.Service_Request_Case.Fault_Codes__c");
        let repairTypePicklistValuesMap=component.get("v.RepairTypePicklistValuesMap");

        if(faultCode == 'BATTERY' || faultCode == 'CHARGER') 
            component.set("v.RepairTypePicklistValues", ['Battery / Charger']);
        else 
            component.set("v.RepairTypePicklistValues", 
                repairTypePicklistValuesMap[component.get("v.Service_Request_Case.Product_Payment_Category__c")]);

        component.set("v.RepairTypePicklistValuesActive",true);
	}
})