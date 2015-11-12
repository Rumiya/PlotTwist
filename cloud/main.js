var Parse = require('parse-cloud-express').Parse;
var sendgrid = require('sendgrid')(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)

function sendWelcome(email) {
  var opts = {
    to: email,
    from: 'apps.plottwist@gmail.com',
    subject: 'Welcome to Plot Twist'
    addFilter:('templates', 'enable', 1);
    addFilter:('templates', 'template_id', '29f38bef-30f5-4d5e-bbdc-b127b69a3254');
  }



  sendgrid.send(opts, function(err) {
    if (err) {
      console.error('unable to send via sendgrid: ', err.message);
      return;
    }

    console.info('sent to sendgrid for delivery')
  })
}

Parse.Cloud.beforeSave('_User', function(request, response) {
  if (request.body.object.email) {
    sendWelcome(request.body.object.email);
  }

  response.success();
});


