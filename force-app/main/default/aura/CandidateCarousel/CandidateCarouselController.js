({
	doInit : function(component, event, helper) {
		var action = component.get("c.findAll");
		action.setParams({
            "pageNumber": 1
    	});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log(result);
            component.set("v.contacts", result.contacts);
            setTimeout(function() {
                $A.run(function() {
					$('.carousel').slick();
                });
            });
            // prevent default "pull-to-refresh" behavior when running in S1
            $('.carousel').on("touchmove", function() {
                return false;
            });
        });
        $A.enqueueAction(action);
	}
})