import { LightningElement,api } from 'lwc';

export default class EditToDo extends LightningElement {
    loading;
    @api recordIdToBeEdited;

    constructor(){
        super();
        this.loading = true;
    }

    handleSuccess(event){
        const selectedEvent = new CustomEvent("edit");
        this.dispatchEvent(selectedEvent);
    }

    handleOnLoad() {
        this.loading = false;
    }

    closepopup(){
        const selectedEvent = new CustomEvent("closemodal");
        this.dispatchEvent(selectedEvent);
    }

}