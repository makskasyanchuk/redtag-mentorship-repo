import { LightningElement, api, track, wire } from 'lwc';
import getOpportunitiesWithProducts from '@salesforce/apex/OpportunityListViewController.getOpportunitiesWithProducts';
import massDeleteOpportunities from '@salesforce/apex/OpportunityListViewController.massDeleteOpportunities';
import { subscribe, MessageContext } from 'lightning/messageService';
import OPPORTUNITY_CREATED_CHANNEL from '@salesforce/messageChannel/OpportunityCreatedChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns = [
    {label: "Opportunity Name", fieldName: "opportunityName", type: "text", hideDefaultActions: true},
    {label: "Account", fieldName: "accountUrl", type: "url",
        typeAttributes: {label: { fieldName: "accountName" }, target: "_blank"},
        iconName: 'standard:account',
        hideDefaultActions: true
    },
    {label: "Contact", fieldName: "contactUrl", type: "url",
        typeAttributes: {label: { fieldName: "contactName" }, target: "_blank"},
        iconName: 'standard:contact',
        hideDefaultActions: true
    },
    {label: "Stage", fieldName: "stageName", type: "text", hideDefaultActions: true},
    {label: "Close Date", fieldName: "closeDate", type: "date", hideDefaultActions: true},
]

export default class OpportunityListView extends LightningElement {
    columns = columns;
    @track opportunities = [];
    @track _wiredOpportunities = [];
    @track opportunityIds = [];
    showDeleteModal = false;
    errors;
    isSelected = false;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }
    
    subscribeToMessageChannel() {
        if(!this.subscription) {
            this.subscription = subscribe(this.messageContext, OPPORTUNITY_CREATED_CHANNEL, (message) => {
                this.handleMessage(message);
            });
        }
    }

    handleMessage(message) {
        console.log('Recieved Message: ' + JSON.stringify(message));
        return refreshApex(this._wiredOpportunities);
    }
    
    @wire(getOpportunitiesWithProducts)
    fetchData(value) {
        this._wiredOpportunities = value;
        const { data, error } = value;

        if(data) {
            this.opportunities = data;
        }
        if(error) {
            this.errors = error;
            console.log("Error" + error);
        }
    }
    
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;

        this.isSelected = true;
        if(this.selectedRows.length < 1) {
            this.isSelected = false;
        }

        this.opportunityIds = new Set();
        this.selectedRows.forEach(element => {
            this.opportunityIds = [...this.opportunityIds, element.opportunityId];
        });
        
        if(this.isSelected === false) {
            this.opportunityIds = [];
        }
    }   
    
    handleDelete() {
        massDeleteOpportunities({opportunityIds: this.opportunityIds})
        .then(() => {
            this.clearSelection();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successfuly deleted record(s)',
                    message: 'Email notification will be sent within 24 hours',
                    variant: 'success'
                })
            );
            return refreshApex(this._wiredOpportunities);
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed to delete records',
                    message: 'Message: ' + JSON.stringify(error),
                    variant: 'error'
                })
            );
        })
        this.showDeleteModal = false;
    }

    openDeleteModal() {
        this.showDeleteModal = true;
    }
    
    handleModalClose() {
        this.showDeleteModal = false;
    }

    clearSelection() {
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.opportunityIds = [];
        this.isSelected = false;
    }
}