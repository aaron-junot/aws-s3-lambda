'use strict'

const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.timeAndDate = (event, context, callback) => {
  const current = new Date();
  const dateString = current.toLocaleString();

  const dateBuffer = Buffer.from(dateString);

  const key = Date.now().toString(); // The key just has to be something unique, so make it a timestamp

  const bucketName = process.env.BUCKET.replace(".s3.amazonaws.com", "");
  const params = { Bucket: bucketName, Key: key, Body: dateBuffer }

  s3.upload(params, (err, data) => {
    if (err) {
      callback(err);
    }
    else {
      callback(null, "Success");
    }
  })
}
