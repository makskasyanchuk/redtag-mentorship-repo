import { LightningElement, api, track, wire } from 'lwc';
import getOpportunityProducts from '@salesforce/apex/OpportunityProductListViewController.getOpportunityProducts'

const columns = [
    {label: "Product Name", fieldName: "productName", type: "text", hideDefaultActions: true, fixedWidth: 258},
    {label: "Opportunity", fieldName: "opportunityUrl", type: "url",
        typeAttributes: {label: { fieldName: "opportunityName" }, target: "_blank"},
        iconName: 'standard:opportunity',
        hideDefaultActions: true,
        fixedWidth: 260
    },
    {label: "Quantity", fieldName: "quantity", type: "number", hideDefaultActions: true, 
        cellAttributes: { alignment: 'left' }, fixedWidth: 260
    },
    {label: "Sales Price", fieldName: "unitPrice", type: "number", hideDefaultActions: true,
        cellAttributes: { alignment: 'left' },
        typeAttributes: { currencyCode: 'USD' }, fixedWidth: 260
    },
    {label: "Discount Price", fieldName: "discountPrice", type: "number", hideDefaultActions: true,
        cellAttributes: { alignment: 'left' }, fixedWidth: 260
    },
]

export default class OpportunityProductListView extends LightningElement {
    @api opportunityIds; // Accepts the list of opportunity ids from parent
    
    columns = columns;
    errors;
    
    @track opportunityProducts = [];

    @wire(getOpportunityProducts, {opportunityIds: '$opportunityIds'})
    fetchData({data, error}) {
        if(data) {
            this.opportunityProducts = data;
            this.error = undefined;
        }
        if(error) {
            this.errors = error;
            this.opportunityProducts = undefined;
        }
    }
}