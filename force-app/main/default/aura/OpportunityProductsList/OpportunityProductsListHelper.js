({
    fetchProducts : function(component) {
        let action = component.get('c.getProducts');
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let products = response.getReturnValue();
                component.set("v.options", products);
            } else if (state === 'ERROR') {
                let errors = response.getErrors();
                console.error(errors);
            }
        })

        $A.enqueueAction(action);
    },
    addProductToList : function(component) {
        let selectedProductId = component.get("v.selectedProduct");
        let products = component.get("v.options");
        let opportunityLineItems = component.get("v.opportunityLineItems");

        let selectedProduct = products.find(function(product) {
            return product.Id === selectedProductId;
        });

        if (selectedProduct) {
            let quantity = component.find("quantityInput").get("v.value");
            let unitPrice = component.find("unitPriceInput").get("v.value");

            let opportunityLineItemWithDetails = Object.assign({}, selectedProduct, {
                Name: selectedProduct.Name,
                Quantity: quantity,
                UnitPrice: unitPrice
            });

            opportunityLineItems = [...opportunityLineItems, opportunityLineItemWithDetails];
            component.set("v.opportunityLineItems", opportunityLineItems);

            component.set("v.selectedProduct", null);
            component.find("quantityInput").set("v.value", null);
            component.find("unitPriceInput").set("v.value", null);
        } else {
            console.log("Selected product not found");
        }
    },
    setColumns : function(component) {
        let columns = [
            {label: 'Product Name', fieldName: 'Name', type: 'text'},
            {label: 'Quantity', fieldName: 'Quantity', type: 'number', editable: "true"},
            {label: 'Sales Price', fieldName: 'UnitPrice', type: 'number', editable: "true"},
            {
                type: 'button',
                typeAttributes: {
                    iconName: 'utility:delete',
                    name: 'delete',
                    title: 'Delete',
                    disabled: false,
                    value: 'delete',
                    iconPosition: 'center'
                }
            }
        ];
        component.set("v.columns", columns);
    },
    productChange : function(component, event) {
        let selectedProductId = event.getSource().get("v.value");
        component.set("v.selectedProduct", selectedProductId);
    },
    quantityChange : function(component, event) {
        let quantity = event.getSource().get("v.value");
        component.set("v.quantity", quantity);
    },
    unitPriceChange : function(component, event) {
        let unitPrice = event.getSource().get("v.value");
        component.set("v.unitPrice", unitPrice);
    },
    deleteProductFromTheList : function(component, row) {
        let opportunityLineItems = component.get('v.opportunityLineItems');
        let indexToDelete = opportunityLineItems.findIndex(item => item.Id === row.Id);

        if (indexToDelete !== -1) {
            opportunityLineItems.splice(indexToDelete, 1);
            component.set("v.opportunityLineItems", opportunityLineItems);

            component.find("notifLib").showToast({
                "title": "Success",
                "message": "Successfully deleted product",
                "variant": "success"
            });
        }
    },
    productUpdate : function(component, event, draftValues) {
        let updatedProducts = [];
        draftValues.forEach(draft => {
            let recordToUpdate = {
                "sobjectType": "Product2",
                "Id": draft.Id,
                "Quantity": draft.Quantity,
                "UnitPrice": draft.UnitPrice
            }
            updatedProducts.push(recordToUpdate);
        });

        let action = component.get("c.updateProducts");
        action.setParams({products : updatedProducts});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let updatedItems = component.get("v.opportunityLineItems");
                draftValues.forEach(draft => {
                    let index = updatedItems.findIndex(item => item.Id === draft.Id);
                    if (index !== -1) {
                        if (draft.Quantity !== undefined) {
                            updatedItems[index].Quantity = draft.Quantity;
                        }
                        if (draft.UnitPrice !== undefined) {
                            updatedItems[index].UnitPrice = draft.UnitPrice;
                        }
                    }
                });
                component.set("v.opportunityLineItems", updatedItems);

                component.find("notifLib").showToast({
                    "title": "Success",
                    "message": "Successfuly updated fields",
                    "variant": "success"
                });

                component.set("v.draftValues", []);
            } else if (state === "ERROR") {
                let errors = response.getError();
                component.find("notifLib").showToast({
                    "title": "Failure",
                    "message": "Failed to update fields: " + errors[0].message,
                    "varaint": "error"
                });
            }
        });
        $A.enqueueAction(action);
    }
})