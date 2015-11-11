var Parse = require('parse-cloud-express').Parse;
var Sendgrid = require('sendgrid')(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)

function sendWelcome(email) {
  var opts = {
    to: email,
    from: 'app.plottwist@gmail.com',
    subject: 'Welcome to Plot Twist',
    text: 'Welcome, and thanks for signing up! Check out our website at https://plottwistapp.wordpress.com.'
  }
  sendgrid.send(opts, function(err) {
    if (err) {
      console.error('Unable to send via sendgrid: ', err.message);
      return;
    }

    console.info('Sent to sendgrid for delivery')
  })
}

Parse.Cloud.beforeSave('_User', function(request, response) {
  if (request.body.object.email) {
    sendWelcome(request.body.object.email);
  }
  response.success();
});


