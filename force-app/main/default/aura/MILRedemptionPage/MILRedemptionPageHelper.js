({
	hideComponent : function(component) {
		$A.util.removeClass(component, 'slds-show');
        $A.util.addClass(component, 'slds-hide');
	},

	showComponent : function(component) {
		$A.util.removeClass(component, 'slds-hide');
        $A.util.addClass(component, 'slds-show');
	},

	navigateTo : function(component, target) {
		var navEvent = $A.get("e.c:NavigateEvent");
        navEvent.setParams({ "Target": target});
        navEvent.fire();
	},

	getURLParameter : function(name) {
		return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null;
	},

	navigateto : function(page) {
		//var address = '/register-new-product/';
    	var urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({
      			"url": page,
      			"isredirect" :false
    		});
    	urlEvent.fire();     
	}
})