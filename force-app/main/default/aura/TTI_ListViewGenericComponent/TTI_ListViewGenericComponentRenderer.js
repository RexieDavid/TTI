({
    // Your renderer method overrides go here
    afterRender : function(component, helper){
        this.superAfterRender();
        
        component.handleData();
    },
})