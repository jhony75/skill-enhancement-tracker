import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShowToastFlowAction extends LightningElement {
  @api title;
  @api message;
  @api variant;

  @api
  invoke() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: this.title || 'Success',
        message: this.message,
        variant: this.variant || 'success'
      })
    );
  }
}