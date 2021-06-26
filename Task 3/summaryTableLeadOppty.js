import { LightningElement,wire } from 'lwc';
import getSummaryData from '@salesforce/apex/OwnerLeadOpptySummary.getLeadOpptySummary';

export default class SummaryTableLeadOppty extends LightningElement {

    startDate = new Date("2015-01-01").toISOString().slice(0, 10);
    endDate =  new Date().toISOString().slice(0, 10);
    noRecordsToDisplay = false;
    isLoadingData = false;
    summaryData = [];

    columns = [
        { label: 'Owner', type: 'text',fieldName: 'owner'},
        { label: 'Total Leads', type:'number', fieldName: 'leadCount'},
        { label: 'Total Opps.', type:'number', fieldName: 'opptyCount' },
        { label: 'Conv Rate', type:'percent', fieldName: 'conversionRate'},
        { label: 'Max Created Date (Opp)', type:'date', fieldName: 'maxOppCreatedDate'},
        { label: 'Total Value (Opp)', type:'currency', fieldName: 'totalOpptyValue'}
    ];

    @wire(getSummaryData, { startDate: '$startDate', endDate: '$endDate' })
    wiredSummary({error,data}) {
        if (data) {
            this.summaryData = data;
            if(this.summaryData.length == 0) {
                this.noRecordsToDisplay = true;
            }else{
                this.noRecordsToDisplay = false;
            }
            this.isLoadingData = false;
        } else if (error) {
            this.isLoadingData = false;
            this.showMessage('ERROR OCCURED',JSON.stringify(error),'error','sticky');
        }
    }

    handleStartDate(event) {
        this.startDate = event.detail.value;
        this.isLoadingData = true;
    }

    handleEndDate(event) {
        this.endDate = event.detail.value;
        this.isLoadingData = true;
    }

    showMessage(title,message,variant,mode){
        const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
    }

}