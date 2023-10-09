({
    doInit : function(component, event, helper) {
        const objects = component.get('v.objectList');
        if (objects) {
            const haveMultipleItems = objects.length > 1;
            component.set('v.panels', JSON.parse(JSON.stringify(objects)));
            helper.activatePanel(component, objects[0].id || '');
            helper.autoPlay(component, haveMultipleItems);
            component.set('v.haveMultipleItems', haveMultipleItems);
        }
        component.set('v.isLoaded', true);
    },

    handleIndicatorChange: function(component, event, helper) {
        event.preventDefault();
        const { dataset } = event.currentTarget;
        helper.activatePanel(component, dataset.id);
    },

    handleAutoPlayReset: function(component, event, helper) {
        helper.clearInterval(component);
    },

    handleDestroy: function(component, event, helper) {
        helper.clearInterval(component)
    }
})