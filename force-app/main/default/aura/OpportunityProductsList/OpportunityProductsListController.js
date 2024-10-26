({
    doInit : function(component, event, helper) {
        helper.fetchProducts(component);
        helper.setColumns(component);
    },

    handleProductChange : function(component, event, helper) {
        helper.productChange(component, event);
    },

    handleQuantityChange : function(component, event, helper) {
        helper.quantityChange(component, event);
    },

    handleUnitPriceChange : function(component, event, helper) {
        helper.unitPriceChange(component, event);
    },

    handleProductUpdate : function(component, event, helper) {
        let draftValues = event.getParam("draftValues");
        helper.productUpdate(component, event, draftValues);  
    },

    handleRowAction : function(component, event, helper) {
        let action = event.getParam('action');
        let row = event.getParam('row');

        if(action.name === 'delete') {
            helper.deleteProductFromTheList(component, row);
        }
    },

    addToList : function(component, event, helper) {
        helper.addProductToList(component);
    }
})