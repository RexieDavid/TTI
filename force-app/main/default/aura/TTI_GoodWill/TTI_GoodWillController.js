({
	doInit : function(component, event, helper) {
		var userType = component.get("v.userType");
        
        if(!($A.util.isUndefinedOrNull(userType) || $A.util.isEmpty(userType))){
            var UserTypeRole = userType.UserRole.Name;
            if(UserTypeRole.includes("Customer Manager")){
                component.set("v.Manager",true);
            }else{
                component.set("v.Manager",false);
            }
        }
        
	},
    changeGoodWill : function(component, event, helper) {
		helper.clearpercentagewhengoodwillunchecked(component);
        helper.uncheckgoodwillparts(component);
        helper.ValidateGoodWill(component);
        
	},
    partsdiscountblur : function(component, event, helper) {
        helper.ValidateGoodWill(component);
        helper.Validatepartpercentage(component);
	},
    retaildiscountblur : function(component, event, helper) {
        helper.ValidateGoodWill(component);
        helper.Validateretailpercentage(component);
	},
    changeGoodWillParts : function(component, event, helper) {
		helper.uncheckgoodwill(component);
	},
    toggleSection:function(component,event,helper)
    {
        var acc = component.find("section");
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    }
})