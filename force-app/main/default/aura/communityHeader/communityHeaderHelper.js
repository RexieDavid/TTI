({
    showHeaderAndTitle: function(component) {
        const action = component.get("c.getCommunityHeader");
        action.setParams({pageName: component.get("v.PageName")});
        action.setCallback(this, function(response) {
            this.setHeaderDetails(response, component);
        });
        $A.enqueueAction(action);
    },

    setHeaderDetails: function(response, component) {
        const retValue = response.getReturnValue();
        component.set("v.Header", retValue[0]);
        component.set("v.Title", retValue[1]);
        component.set("v.ImageURL", retValue[2]);
    }
})