({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
     testDelay: function (component, event, helpler) {
        console.log('---------HELLO');
     },
    handleLogin: function (component, event, helpler) {
            
        var username = component.get("v.usernameF");
        var password = component.get("v.password");
        
        console.log('-------------handleLogin:username:',username);
        console.log('-------------handleLogin:password:',password);
        
        var action = component.get("c.login");
        var startUrl = component.get("");
        
        //var ryobi = ".ryobi";
        console.log('------username: '+ username);
        console.log('------password: '+ password);
        //startUrl = decodeURIComponent(startUrl);
        
        //action.setParams({username:username+ryobi, password:password, startUrl:startUrl});
        action.setParams({username:username, password:password, startUrl:startUrl});
        console.log(username);
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            var errmessage = '';
            if((username == '' || username == null || username == 'undefined') && (password == '' || password == null || password== 'undefined')){
                errmessage= "Please enter Email and Password. If username and password were pre-filled, please type them in and try logging in again.";
                component.set("v.errorMessage",errmessage);
                component.set("v.showError",true);
            }
            else if(username!= null && (password == '' || password == null || password== 'undefined')){
                errmessage = "Enter a value in the Password field.";
                component.set("v.errorMessage",errmessage);
                component.set("v.showError",true);
            }
            else if((username == '' || username == null || username == 'undefined') && password != null){
                errmessage = "Enter a value in the Email field.";
                component.set("v.errorMessage",errmessage);
                component.set("v.showError",true);
            }
            else if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            console.log('----action FOrgotpassword: ', action);
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
         console.log('----action SelfRegister: ', action);
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    }
})