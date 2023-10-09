({
    rerender: function(component, helper) {
        this.superRerender();
        helper.windowClick = $A.getCallback(function(event) {
            if (component.isValid()) {
                helper.closeDropdown(component, event);
            }
        });
        window.addEventListener('click', helper.windowClick);
    },
})