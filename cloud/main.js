var Parse = require('parse-cloud-express').Parse;
var sendgrid = require('sendgrid')(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)

function sendWelcome(email) {
  var opts = {
    to: email,
    from: 'apps.plottwist@gmail.com',
    subject: 'Welcome to Plot Twist',
    text: 'Welcome, and thanks for signing up! Check out our website at https://plottwistapp.wordpress.com for inspiration!'
  }

  sendgrid.send(opts, function(err) {
    if (err) {
      console.error('unable to send via sendgrid: ', err.message);
      return;
    }

    console.info('sent to sendgrid for delivery')
  })
}

Parse.Cloud.afterSave('_User', function(request, response) {
  if (request.body.object.email) {
    sendWelcome(request.body.object.email);
  }

  response.success();
});


