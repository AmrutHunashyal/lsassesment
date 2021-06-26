import { LightningElement } from 'lwc';

export default class NewToDo extends LightningElement {
    loading;

    constructor(){
        super();
        this.loading = true;
    }

    handleSuccess(event){
        const selectedEvent = new CustomEvent("creation");
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