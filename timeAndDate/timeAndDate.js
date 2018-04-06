'use strict'

const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.timeAndDate = (callback) => {
  const current = new Date();
  const dateString = current.toLocaleString();

  const dateBlob = new Blob([dateString], { type: "text/plain" });

  const params = { Bucket: 'terraform-20180405020804602800000001', Body: dateBlob }

  s3.upload(params, (err, data) => {
    if (err) console.log(err);
  }

  callback(null, "Success");
}
