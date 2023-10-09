({
    doInit : function(component, event, helper) {
        var outputText = component.find("outputTextId");
        var outputURL = component.find("outputURL");

        var record = component.get('v.record');
        var FieldName = component.get('v.fieldApiName');
        var fieldType = component.get('v.fieldType');

        if(FieldName == 'Id') {
            component.set('v.isID', true)
            outputURL.set('v.title', record[FieldName]);

            FieldName = 'Name';
        }

        if(fieldType == 'REFERENCE') {
            var temp = FieldName.replace('__c', '__r');
            if(record.hasOwnProperty(temp) && typeof record[temp] === 'object') {
                FieldName = temp + '.Name';
            }
        }

        if (FieldName.indexOf(".") >= 0) {
            var ParentSobject = record[FieldName.split(".")[0]];
            if(ParentSobject != undefined){
                var val = ParentSobject[FieldName.split(".")[1]];
                outputText.set("v.value", val);
                component.set("v.value", val);
            }
        }
        else{
            var val = record[FieldName];
            outputText.set("v.value", val);
            component.set("v.value", val);
        }
    },

    handleNavigateEvent : function(component, event, helper) {
        var record = component.get('v.record');
        var target = component.get('v.target');
        var source = component.get('v.source');
        var comp = document.getElementById(source);

        helper.hideComponent(comp);

        var navigateEvent = $A.get('e.c:NavigateEvent');
        navigateEvent.setParams({
            'Target' : target,
            'Record' : JSON.stringify(record)
        });
        navigateEvent.fire();
    }
})