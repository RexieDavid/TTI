({
    initializeOther: function(component, event, helper) {
        helper.colourIconInit(component);
        helper.isLockedInit(component);
        helper.calculateTotalTime(component);
    },

    toggleSection: function(component, event, helper) {
        $A.util.toggleClass(component.find('otherSection'), 'slds-is-open')
    },

    handleDecrement: function(component, event, helper) {
        let totalMinutes = component.get('v.record.timeTaken')
        let hours = 0;
        let curMins = 0;
        if (totalMinutes != 0) {
            hours = Math.floor(totalMinutes / 60);
            let minutes = totalMinutes % 60;
            if (minutes > 0 && minutes <= 45) {
                curMins = minutes - 15;
                totalMinutes = curMins + (hours * 60);
            }
            if (totalMinutes === 0) {
                $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_task');
                $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_event');
                component.set('v.iconState', 'standard:event');
            }

            if (hours == 7 && curMins <= 0) {
                component.set('v.isButtonDisabledHour', false);
            }
        }
        let totalTime = hours + ' hrs ' + curMins + ' mins ';
        component.set('v.setHours', hours);
        component.set('v.setMinutes', curMins);
        component.set('v.totalTime', totalTime);
        component.set('v.record.timeTaken', totalMinutes);
    },

    handleHourDecrement: function(component, event, helper) {
        let totalMinutes = component.get('v.record.timeTaken');
        let curHours = '0';
        let curMins = '0';
        if (totalMinutes > 0 && totalMinutes <= 480) {
            curHours = Math.floor(totalMinutes / 60);
            curMins = totalMinutes % 60;
            if (curHours > 0 && curHours <= 8) {
                curHours = curHours - 1;
                totalMinutes = curMins + (curHours * 60);
            }
        }
        if (totalMinutes === 0) {
            $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_task');
            $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_event');
            component.set('v.iconState', 'standard:event');
        }
        let totalTime = curHours + ' hrs ' + curMins + ' mins ';
        component.set('v.totalTime', totalTime);
        component.set('v.setHours', curHours);
        if (curHours < 8) {
            component.set('v.isButtonDisabled', false);
        }
        component.set('v.setMinutes', curMins);
        totalMinutes = curMins + (curHours * 60);
        component.set('v.record.timeTaken', totalMinutes);
    },

    handleHourIncrement: function(component, event, helper) {
        var cmpEvent = component.getEvent("onChangeTime");
        cmpEvent.setParams({ "firedFrom": "HourIncrement" });
        cmpEvent.fire();
        let isTimeIncrease = component.get("v.isTimeIncrease");
        if (isTimeIncrease == false) {
            return;
        }

        let totalMinutes = component.get('v.record.timeTaken');
        let curHours = '0';
        let curMins = '0';
        let totalTime = '0';
        if (totalMinutes >= 0 && totalMinutes < 480) {
            if (totalMinutes === 0) {
                curHours = totalMinutes + 1;
                $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_event');
                $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_task');
                component.set('v.iconState', 'standard:task');
            }
            else {
                curHours = Math.floor(totalMinutes / 60);
                curMins = totalMinutes % 60;
                if (curHours >= 0 && curHours < 8) {
                    curHours = curHours + 1;
                    totalMinutes = curMins + (curHours * 60);
                    $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_event');
                    $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_task');
                    component.set('v.iconState', 'standard:task');
                }
            }
            if (curHours == 7 && curMins > 0) {
                component.set('v.isButtonDisabledHour', true);
            }
            if (curHours == 8) {
                curMins = 0;
                component.set('v.setMinutes', curMins);
                component.set('v.isButtonDisabled', true);
                totalTime = curHours + ' hrs ' + curMins + ' mins ';
            } else {
                component.set('v.setMinutes', curMins);
                component.set('v.isButtonDisabled', false);
                totalTime = curHours + ' hrs ' + curMins + ' mins ';
            }

            component.set('v.totalTime', totalTime);
            component.set('v.setHours', curHours);
            totalMinutes = parseInt(curMins + (curHours * 60));
            component.set('v.record.timeTaken', totalMinutes);
        }
    },

    handleIncrement: function(component, event, helper) {
        var cmpEvent = component.getEvent("onChangeTime");
        cmpEvent.setParams({ "firedFrom": "MinuteIncrement" });
        cmpEvent.fire();
        let isTimeIncrease = component.get("v.isTimeIncrease");
        if (!isTimeIncrease) {
            return;
        }

        let totalMinutes = component.get('v.record.timeTaken');
        let hours = Math.floor(totalMinutes / 60);
        let minutes = totalMinutes % 60;
        if (minutes >= 0 && minutes < 45) {
            let curMins = minutes + 15;

            $A.util.removeClass(component.find('otherSection'), 'slds-timeline__item_event');
            $A.util.addClass(component.find('otherSection'), 'slds-timeline__item_task');
            component.set('v.iconState', 'standard:task');
            let totalTime = hours + ' hrs ' + curMins + ' mins ';
            if (hours == 7 && curMins > 0) {
                component.set('v.isButtonDisabledHour', true);
            }
            component.set('v.totalTime', totalTime);
            component.set('v.setHours', hours);
            component.set('v.setMinutes', curMins);
            totalMinutes = curMins + (hours * 60);
            component.set('v.record.timeTaken', totalMinutes);
        }
    },

    handleRemove: function(component, event, helper) {
        component.set('v.record.isDeleted', true);
        component.set('v.isVisible', false)
    }
})