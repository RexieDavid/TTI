({
    activatePanel : function(component, identifier) {
        let carouselStyle = component.get('v.carouselPanelStyle');
        const panels = JSON.parse(JSON.stringify(component.get('v.panels')));
        panels.forEach((el, idx) => {
            const isActive = el.id === identifier;
            el.indicatorClass = 'slds-carousel__indicator-action';
            if (isActive) {
                component.set('v.activeIndex', idx);
                el.indicatorClass += ' slds-is-active carousel-brand-indicator';
                carouselStyle = `transform:translateX(-${idx * 100}%)`;
            }
        });
        component.set('v.panels', panels);
        component.set('v.carouselPanelStyle', carouselStyle);
    },
    
    autoPlay: function(component, haveMultipleItems) {
        const isAutoPlay = component.get('v.isAutoPlay');
        if (isAutoPlay && haveMultipleItems) {
            const self = this;
            self.clearInterval(component);
            const intervalId = window.setInterval(
                $A.getCallback(function() { 
                    const activeIndex = component.get('v.activeIndex');
                    const panels = component.get('v.panels');
                    const index = (activeIndex + 1) < panels.length ? activeIndex + 1 : 0;
                    self.activatePanel(component, panels[index].id )
                }), 5000
            );
            component.set('v.intervalId', intervalId);
        }
    },

    clearInterval: function(component) {
        const currIntervalId = component.get('v.intervalId');
        if (currIntervalId) {
            window.clearInterval(currIntervalId);
        }
    }
})