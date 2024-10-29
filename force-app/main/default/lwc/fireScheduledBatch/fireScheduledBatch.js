import { LightningElement } from 'lwc';
import callSchedule  from '@salesforce/apex/OpportunitySummaryMetricsSchedule.callSchedule';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FireScheduledBatch extends LightningElement {
    handleScheduleCall() {
        callSchedule()
        .then(() => {
            console.log("Success block");
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Scheduled Successfuly',
                variant: 'success',
                mode: 'dismissable'
            }));
        })
        .catch(error => {
            console.log("Error block");
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Error scheduling batch: ' + error,
                variant: 'error',
                mode: 'dismissable'
            }));
        });
    }
}