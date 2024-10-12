/* From: https://www.w3schools.com/howto/howto_js_copy_clipboard.asp */
function copyToClipboard(element) {
    // Get the text field
    var copyText = element.parentElement.parentElement.querySelector(".script-input");

    // Select the text field
    copyText.select();
    copyText.setSelectionRange(0, 99999); // For mobile devices

    // Copy the text inside the text field
    navigator.clipboard.writeText(copyText.value);
}
