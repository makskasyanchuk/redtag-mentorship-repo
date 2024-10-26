import { LightningElement, api } from 'lwc';

export default class ConfirmDeleteModal extends LightningElement {
    @api closeModal = false;
    isDisabled = true;

    handleCheckboxChange() {
        this.isDisabled = !this.isDisabled;
    }
    
    handleModalClose() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    confirmDelete() {
        this.dispatchEvent(new CustomEvent('confirmdelete'));
    }
}