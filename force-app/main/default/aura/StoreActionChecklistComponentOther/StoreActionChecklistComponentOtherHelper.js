({
    colourIconInit: function(component) {
        const minutes = component.get('v.record.timeTaken');
        if ($A.util.isUndefinedOrNull(minutes)) {
            component.set('v.record.timeTaken', 0);
            component.set(minutes, 0);
            $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_task');
            $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_event');
            component.set('v.iconState', 'standard:event');
        }

        if (minutes === 0) {
            $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_task');
            $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_event');
            component.set('v.iconState', 'standard:event');
        } else {
            $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_event');
            $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_task');
            component.set('v.iconState', 'standard:task');
        }
    },

    isLockedInit: function(component) {
        const isLocked = component.get('v.record.IsLocked__c');
        if (isLocked) {
            $A.util.removeClass(component.find('expId'), 'slds-is-open');
        }
    },

    calculateTotalTime: function(component) {
        const totalMinutes = component.get('v.record.timeTaken');
        var totalTime = ' 0 hrs 0 mins ';
        var hours = '0';
        var minutes = '0';

        if (totalMinutes > 0) {
            hours = Math.floor(totalMinutes / 60);
            minutes = totalMinutes % 60;
            totalTime = hours + ' hrs ' + minutes + ' mins ';
        }
        component.set('v.totalTime', totalTime);
        component.set('v.setMinutes', minutes);
        component.set('v.setHours', hours);
    }
})