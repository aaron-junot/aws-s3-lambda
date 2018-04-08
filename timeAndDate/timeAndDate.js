'use strict'

// Use the AWS sdk to write to the S3 bucket
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

// The lambda function itself
exports.timeAndDate = (event, context, callback) => {
  // Get the current date
  const current = new Date();

  // Convert the date into a string that has time and date
  const dateString = current.toLocaleString();

  // Create a new buffer from the dateString
  // This will be used to actually write the file in the bucket 
  const dateBuffer = Buffer.from(dateString);

  // Name of the file
  const key = Date.now().toString(); // The key just has to be something unique, so make it a timestamp

  // Get the bucket name from the environment variable
  const bucketName = process.env.BUCKET.replace(".s3.amazonaws.com", "");

  // The bucketname, name of the file (key), and the file (buffer) must be
  // passed in as parameters to the upload function 
  const params = { Bucket: bucketName, Key: key, Body: dateBuffer }

  // Perform the upload
  s3.upload(params, (err, data) => {
    // On error, call the callback function with the error object
    if (err) {
      callback(err);
    }
    // When there's no error, call the callback with a success message
    else {
      callback(null, "Success");
    }
  })
}
