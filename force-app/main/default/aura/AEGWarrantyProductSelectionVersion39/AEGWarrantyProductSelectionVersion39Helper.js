({
    getSiteBrand: function(component) {
        var action2 = component.get("c.getSiteBrand");
        action2.setCallback(this, function(response) {
            this.receiveSiteBrand(response, component);
        });
        $A.enqueueAction(action2);
    },

    receiveSiteBrand: function(response, component) {
        component.set('v.siteBrand', response.getReturnValue());
    },

    getProductCategoryImages: function(component) {
        var action2 = component.get("c.getCategoryImages");

        action2.setCallback(this, function(response) {
            this.setupProductCategoryImages(response, component);

        });
        $A.enqueueAction(action2);
    },

    setupProductCategoryImages: function(response, component) {
        var categoryImageList = response.getReturnValue(); //List<Category_Images__c> 
        var categoryImageMap = {};
        var categoryOrderMap = {};

        for (var i = 0; i < categoryImageList.length; i++) {
            categoryImageMap[categoryImageList[i].External_Id__c] = categoryImageList[i].Image_URL__c;
            categoryOrderMap[categoryImageList[i].External_Id__c] = categoryImageList[i].Display_Order__c;
        }

        component.set("v.categoryImageMap", categoryImageMap);
        component.set("v.categoryOrderMap", categoryOrderMap);
    },

    //call the apex controlled method to retrieve the applicable products from the database
    getProducts: function(component) {
        var action = component.get("c.getProducts");
        action.setCallback(this, function(response) {
            this.setupProducts(response, component);
        });
        $A.enqueueAction(action);

    },

    setupProducts: function(response, component) {
        var productList = response.getReturnValue();

        var productArray = [{ id: '', text: '' }];
        var productMapById = {};
        var kitProductsMapByKitId = {};


        for (var i = 0; i < productList.length; i++) {
            var currentProduct = productList[i];
            productArray.push({ id: currentProduct.Id, text: currentProduct.Customer_Facing_Name__c + ' - ' + currentProduct.ProductCode });
            productMapById[currentProduct.Id] = currentProduct;

            //see if this is a kit & if so build map
            if (currentProduct.Kit_Products__r != undefined) {
                kitProductsMapByKitId[currentProduct.Id] = currentProduct.Kit_Products__r;
            }
        }

        var that = this;
        $("#productSearch")
            .select2({
                data: productArray,
                placeholder: 'Type the model number or name of tool here....',
                allowClear: false
            })
            .prop("disabled", false)
            .on("change", function(evt) {
                that.productSelected(component, productMapById[this.value]);

            });

        component.set("v.productListFull", productList);
        component.set("v.kitProductsMapByKitId", kitProductsMapByKitId);

        this.buildCategoryList(component, '', 1);
    },

    //generic function to build the next level of required category or product list
    buildCategoryList: function(component, selectedCategory, newLevel) {
        var catLevelNextMap = {};
        var catLevelNextArray = [];

        var productListFull = component.get("v.productListFull");
        var categoryImageMap = component.get("v.categoryImageMap");
        var categoryOrderMap = component.get("v.categoryOrderMap");
        var level1Selected = component.get("v.level1Selected");
        var level2Selected = component.get("v.level2Selected");
        var level3Selected = component.get("v.level3Selected");

        for (var i = 0; i < productListFull.length; i++) {
            var product = productListFull[i];
            var isMatch = false;
            if (newLevel === 2) {
                if (product.Category_Customer_Level1__c != undefined && ~selectedCategory.indexOf(product.Category_Customer_Level1__c))
                    isMatch = true;
            }
            if (newLevel === 3) {
                if (product.Category_Customer_Level1__c != undefined && product.Category_Customer_Level2__c != undefined && ~selectedCategory.indexOf(product.Category_Customer_Level2__c) && ~level1Selected.indexOf(product.Category_Customer_Level1__c))
                    isMatch = true;
            }
            if (newLevel === 4) {
                if (product.Category_Customer_Level1__c != undefined && product.Category_Customer_Level2__c != undefined) {
                    if (product.Customer_Category_Level3__c != undefined) {
                        if (~product.Customer_Category_Level3__c.indexOf(selectedCategory) && ~product.Category_Customer_Level2__c.indexOf(level2Selected) && ~product.Category_Customer_Level1__c.indexOf(level1Selected)) {
                            isMatch = true;
                        }
                    } else if (level3Selected === '' && ~product.Category_Customer_Level2__c.indexOf(level2Selected) && ~product.Category_Customer_Level1__c.indexOf(level1Selected)) {
                        //this is the case where cat1 & cat 2 match & there is no cat3 propulated so return all the products
                        isMatch = true;
                    }
                }
            }

            if (newLevel === 1 || isMatch) {
                var nextCategory = '';
                var categoryImageRef = '';
                //TODO: maybe brand selection dynamic
                var brand = component.get('v.siteBrand');

                if (newLevel === 1) {
                    nextCategory = product.Category_Customer_Level1__c;
                    categoryImageRef = brand + "_LVL1_";
                }
                if (newLevel === 2) {
                    nextCategory = product.Category_Customer_Level2__c;
                    categoryImageRef = brand + "_LVL2_";

                }
                if (newLevel === 3) {
                    nextCategory = product.Customer_Category_Level3__c;
                    categoryImageRef = brand + "_LVL3_";

                }

                if (newLevel === 4) {
                    //actual products here
                    catLevelNextArray.push({ "name": product.Customer_Facing_Name__c, "imageUrl": product.Image_URL__c, "Id": product.Id, "ProductCode": product.ProductCode })
                } else if (nextCategory != undefined && catLevelNextMap[nextCategory] === null) { //check if the category has been added to avoid dupes
                    //categories could be semi-colon split in the same field, e.g. Corded;Battery;Pneumatic;Hybrid
                    var splitCat = nextCategory.split(';');
                    for (var i = 0; i < splitCat.length; i++) {

                        if (catLevelNextMap[splitCat[i]] === null) { //another check to see if the split has already been added to avoid dupes
                            catLevelNextMap[splitCat[i]] = product;
                            var catImgKey = categoryImageRef + splitCat[i];
                            var orderNum = categoryOrderMap[catImgKey] != null ? categoryOrderMap[catImgKey] : 99; //if order is undefine place last.
                            catLevelNextArray.push({ "name": splitCat[i], "imageUrl": categoryImageMap[catImgKey], "displayOrder": orderNum });
                        }
                    }
                    catLevelNextMap[nextCategory] = product;
                }
            }
        }

        var orderedCatLevelNextArray = catLevelNextArray.slice(0);
        orderedCatLevelNextArray.sort(function(a, b) {
            return a.displayOrder - b.displayOrder;
        });
        //set the new category list to the appropriate viewstate variable
        switch (parseInt(newLevel)) {
            case 1:
                component.set("v.level1", orderedCatLevelNextArray);
                $('#crumb1').hide();
                $('#crumb2').hide();
                $('#crumb3').hide();
                break;
            case 2:

                $('#crumb1').html(selectedCategory).show();
                $('#crumb2').hide();
                $('#crumb3').hide();
                component.set("v.level2", orderedCatLevelNextArray);
                break;
            case 3:
                $('#crumb2').html(selectedCategory).show();
                $('#crumb3').hide();
                component.set("v.level3", orderedCatLevelNextArray);
                break;
            case 4:
                if (selectedCategory != '') {
                    //this shouldn't happen when we skip the final category
                    $('#crumb3').html(selectedCategory).show();
                }
                component.set("v.productListCategory", orderedCatLevelNextArray);
                break;
        }
    },

    setActiveCrumb: function(crumbNumber) {
        var newActiveCrumb = (parseInt(crumbNumber) - 1);
        $('#crumb0').removeClass('active');
        $('#crumb1').removeClass('active');
        $('#crumb2').removeClass('active');
        $('#crumb3').removeClass('active');
        $('#crumb' + newActiveCrumb).addClass('active');
    },

    productSelected: function(component, selectedProduct) {
        if (selectedProduct === undefined) {
            component.set("v.selectedProduct", undefined);
            component.set("v.buttonDisabled", true);
            $("#selectedImage").html('');
            $("#selectedText").html('');
            $(".basket").hide();
        }
        else {
            //get selected product
            component.set("v.selectedProduct", selectedProduct);
            component.set("v.buttonDisabled", false);

            //see if selected product is a kit
            var kitProductsMapByKitId = component.get("v.kitProductsMapByKitId");
            var kitProductsList = kitProductsMapByKitId[selectedProduct.Id];

            var productImageHTML = '<img class="categoryImage" src="' + selectedProduct.Image_URL__c + '">';
            var listHtml = '<p>' + selectedProduct.Customer_Facing_Name__c + ' - ' + selectedProduct.ProductCode + '</p> ';


            if (kitProductsList != undefined) {
                var fullList = listHtml;
                fullList = fullList + "<p>which includes:</p>";
                for (var i = 0; i < kitProductsList.length; i++) {
                    fullList = fullList + "<li>"
                        + '<img width="40" height="40" src="' + kitProductsList[i].Kit_Tool__r.Small_Image_URL__c + '">' + kitProductsList[i].Quantity__c + " X " + kitProductsList[i].Kit_Tool__r.Customer_Facing_Name__c + ' - ' + kitProductsList[i].Kit_Tool__r.ProductCode + ' ';

                    fullList = fullList + "</li>";

                }
                $("#selectedImage").html(productImageHTML);
                $("#selectedText").html(fullList);

            } else {
                $("#selectedImage").html(productImageHTML);
                $("#selectedText").html(listHtml);
            }

        }
        $(".basket").show();
    },

    getDefaultSNDisplay: function(component) {
        var action = component.get("c.getDefaultSerialNumerDisplay");
        action.setCallback(this, function(response) {
            this.setupDefaulSNDisplay(response, component);
        });
        $A.enqueueAction(action);

    },

    setupDefaulSNDisplay: function(response, component) {
        var defualtSNDisplay = response.getReturnValue(); //default serial number display
        component.set("v.defaultSerialNumberDisplay", defualtSNDisplay);
    },
})