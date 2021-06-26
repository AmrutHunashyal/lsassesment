import { LightningElement, wire, track } from 'lwc';
import getToDoList from "@salesforce/apex/ToDoController.getToDoList";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {refreshApex} from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';


export default class ToDo extends NavigationMixin(LightningElement) {

    @track toDoList = [];
    openNewToDo = false;
    loading = false;
    userId = Id;

    connectedCallback() {
        this.getToDo();
    }

    getToDo() {
        this.loading = true;
        getToDoList({userId: this.userId})
            .then((result) => {
                this.toDoList = result;
                this.loading = false;
                console.log(JSON.stringify(this.toDoList));
            })
            .catch((error) => {
                this.showMessage('ERROR OCCURED',JSON.stringify(error),'error','sticky');
            });
    }

    recordURL;
    goToRecord(event){
        console.log('eve '+event.target.dataset.value);
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: event.target.dataset.value,
        //         objectApiName: 'To_Do__c',
        //         actionName: 'view'
        //     },
        // });


        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.target.dataset.value,
                objectApiName: 'To_Do__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });

    }

    goToContact(event){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.target.dataset.value,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });

    }

    newTask(){
        this.openNewToDo = true;
        this.loading = true;
    }

    closeModal(){
        this.openNewToDo = false;
        this.loading = false;
        this.openEditToDo = false;
    }

    goToNewItem(event){
        const toast = new ShowToastEvent({
            title: 'NEW TO DO CREATED',
            variant: 'success',
        });
        this.dispatchEvent(toast);
        this.openNewToDo = false;
        refreshApex(this.getToDo());

        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: event.detail.id,
        //         objectApiName: 'To_Do__c',
        //         actionName: 'view'
        //     },
        // });
    }

    handleOnLoad() {
            this.loading = false;
    }

    openEditToDo = false;
    recordIdToBeEdited;

    handleEditRecord(event){
        this.loading = true;
        this.openEditToDo = true;
        this.recordIdToBeEdited = event.target.value;
    }

    handleEdit(){
        const toast = new ShowToastEvent({
            title: 'EDIT SAVED',
            variant: 'success',
        });
        this.dispatchEvent(toast);
        this.openEditToDo = false;
        refreshApex(this.getToDo());
    }

    handleDeleteRecord(event){
        deleteRecord(event.target.value)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'DELETE SUCCESS',
                        variant: 'success'
                    })
                );
                refreshApex(this.getToDo());
            })
            .catch(error => {
                this.showMessage('ERROR OCCURED',JSON.stringify(error),'error','sticky');
            });
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