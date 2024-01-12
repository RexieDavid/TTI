import { LightningElement, track } from 'lwc';
import template from './aegWarrantyRepairMain.html';
import styles from './aegWarrantyRepairMain.css';

export default class aegWarrantyRepairMain extends LightningElement {
    @track showMessage = false;
    @track message = '';

    firstScreen = true;
    secondScreen = false;

    // Link the HTML template
    static template = template;

    // Link the CSS file
    static styles = styles;

    // Define a handler function for the button click event
    handleClick(event) {
        this.showMessage = true;
        this.message = 'Congratulations! Your LWC is successfully added on the home page.';

        // Hide the button after it's clicked
        const buttonElement = this.template.querySelector('.custom-button');
        buttonElement.style.display = 'none';
    }
}