'use strict'

const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.timeAndDate = (event, context, callback) => {
  const current = new Date();
  const dateString = current.toLocaleString();

  const dateBuffer = Buffer.from(dateString);

  const key = Date.now().toString(); // The key just has to be something unique, so make it a timestamp

  const params = { Bucket: 'terraform-20180405020804602800000001', Key: key, Body: dateBuffer }

  s3.upload(params, (err, data) => {
    if (err) {
      callback(err);
    }
    else {
      callback(null, "Success");
    }
  })
}
