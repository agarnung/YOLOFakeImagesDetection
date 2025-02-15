// Function to handle loading the original image when the user selects a file
document.getElementById('imageInput').addEventListener('change', function(event) {
    const file = event.target.files[0];  // Get the first file from the input

    if (file) {
        const reader = new FileReader();  // Create a new FileReader to read the file

        // When the file is loaded, this function is triggered
        reader.onload = function(e) {
            const originalImage = document.getElementById('originalImage');  // Get the element to display the image
            originalImage.src = e.target.result;  // Set the source of the image to the loaded data URL (the original image)
        }

        reader.readAsDataURL(file);  // Read the file as a Data URL (base64 encoded string)
    }
});

// Function to upload the image for processing (such as detection or editing)
function uploadImage() {
    const fileInput = document.getElementById('imageInput');  // Get the input element where the user selects the image

    if (!fileInput.files.length) {  // If no file is selected, show an alert
        alert('Please select an image to upload.');
        return;  // Exit the function if no file is selected
    }

    const formData = new FormData();  // Create a new FormData object to hold the image file
    formData.append('image', fileInput.files[0]);  // Append the selected image to the FormData

    // Send the image to the server for processing via a POST request
    fetch('/detect', {
        method: 'POST',  // HTTP method POST to send data to the server
        body: formData   // Attach the image data as the request body
    })
    .then(response => response.json())  // Parse the JSON response from the server
    .then(data => {
        // Display the processed image on the page once the response is received
        const resultImage = document.getElementById('resultImage');  // Get the element to display the processed image
        resultImage.src = data.image_url;  // Set the source to the processed image URL returned from the server
    })
    .catch(error => {
        console.error('Error:', error);  // Log any errors that occur during the request
    });
}

// Clear the file input when the page loads to reset the input field
window.onload = function() {
    document.getElementById('imageInput').value = '';  // Reset the input field to ensure no file is pre-selected
};
