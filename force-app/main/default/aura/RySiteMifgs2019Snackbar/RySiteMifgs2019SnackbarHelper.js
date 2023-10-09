({
    showSnackbar : function(component) {

        console.log('DBG: inside helper.showSnackbar');

        // Get the snackbar DIV
        //var x = document.getElementById("snackbar");
        var x = component.find('snackbar');
        console.log('DBG: snackbar found');

        // Add the "show" class to DIV
        //x.className = "show";
        $A.util.addClass(x, 'show');
        console.log('DBG: snackbar shown');

        // After 3 seconds, remove the show class from DIV
        //setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
        
        setTimeout($A.getCallback(function() {
            $A.util.removeClass(x, 'show');
            component.set('v.openthesnacks', false);
            console.log('DBG: snackbar hidden');
        }), 3000);
    }
})