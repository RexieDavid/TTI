({
    doInit : function(component, event, helper) {
        const objects = component.get('v.objectList');
        const panels = JSON.parse(JSON.stringify(objects));
        panels.forEach((el, idx) => {
            el.isActive = idx === 0;
            el.indicatorClass = `slds-carousel__indicator-action ${idx === 0 ? 'slds-is-active' : ''}`;
        }, []);
        component.set('v.objectsList', panels);
    },

    handleIndicatorChange: function(component, event, helper) {
        event.preventDefault();
        const { dataset } = event.currentTarget

    }
})