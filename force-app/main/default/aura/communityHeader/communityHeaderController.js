({
    doInit: function(component, event, helper) {
        if (component.get('v.UseStatic')){
            component.set("v.Header", component.get('v.StaticHeader'));
            component.set("v.Title", component.get('v.StaticTitle'));
        } else {
            helper.showHeaderAndTitle(component);
        }
    },
})