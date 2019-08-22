
const request = require('request');
var config = require('./config');

process.env.AWS_SDK_LOAD_CONFIG = 1

var AWS = require('aws-sdk');
var cognitoidentity = new AWS.CognitoIdentity();
var dynamodb = new AWS.DynamoDB();

AWS.config.update({ region: 'ap-southeast-2' });


function login(username, password, callback) {
  request.post({
    url: 'https://auth.makeuwa.com/api/login',
    form: {
      "user": username,
      "pass": password,
      "token": config.uwaApiToken
    }
  }, function (err, httpResponse, body) {
    
    var obj = JSON.parse(body);
    if (err) {
      // login did not succeed
      console.log('login failed');
      success = false;
      msg = 'log in failed'

    }
    else if (!obj['success']) {
      console.log('login failed ');
      console.log(obj['message']);
      success = false;
      msg = obj['message'];
    }
    else {
      // login successful
      console.log(body);

      console.log('login succeeded, creating or getting identity ');
      console.log(obj['success']);
      success = true;
      msg = obj['user']['username'];
    }

    callback(err, success, msg);
  })
}

function createIdentity(username, identityPoolId, callback) {
  //username = JSON.stringify('username')
  var params = {
    IdentityPoolId: identityPoolId,
    Logins: { /* required */
      'auth.ar.com': username, //change this to pass username 
      /* '<IdentityProviderName>': ... */
    }
  };
  console.log(params)
  console.log(JSON.stringify(params))
  cognitoidentity.getOpenIdTokenForDeveloperIdentity(params, function (err, data) {
    console.log('gotten response from openid ')
    console.log(data)

    if (err) {
      console.log('error getting open id');
      console.log(err, err.stack); // an error occurred

      response = {
        'statusCode': 200,
        'body': {
          message: 'failed'
        }
      }
      callback(err, response);
    }
    else {
      console.log('gotten identity id and token ');
      
      identityId = data['IdentityId']
      token = data['Token']
      response = {
        'statusCode': 200,
        'body': data
      }

      callback(err, response);
    }

  });
}

function getIdentityAndCredentials(username, identityPool, callback) {

  createIdentity(username, identityPool, function (err, resp) {
    console.log(resp);
    console.log('gotten identity id and token, in to main ');
    console.log(resp.body.IdentityId);
    console.log(resp.body.Token);

    // const identityId = resp['body']['IdentityId']
    // const token = resp['body']['Token']

    const identityId = resp.body.IdentityId;
    const token = resp.body.Token;

    if (resp) {

      getCredentials(identityId, token, function (err, credentials) {
        console.log('gotten credentials')
        console.log(credentials)

        callback(err, credentials);

      });

    }

  });

}

function getCredentials(id, token, callback) {
  console.log("getting credentials");
  console.log(id);
  var params = {
    IdentityId: id, /* required */
    Logins: {
      'cognito-identity.amazonaws.com': token,
      /* '<IdentityProviderName>': ... */
    }
  };
  cognitoidentity.getCredentialsForIdentity(params, function (err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else {
      console.log('gotten credentials ');
      console.log(data['Credentials']);
      credentials = data['Credentials'];    // successful response
    }

    callback(err, credentials);
  });
}

console.log('Loading function');

exports.handler  = function (event, context, callback) {
  
  username = event.username;
  password = event.password;

  console.log(username);
  console.log(password);

  try {

    //MAIN
    login(username, password, function(err, success, msg)  {
      console.log(success + " " + msg)
      if(success){
        // createIdentity(msg)
        var params = {
          Key: {
            "UserId": {
              S: username
            }
          },
          TableName: config.userTypeTable
        };
        dynamodb.getItem(params, function (err, data) {
          if (err) console.log(err, err.stack); // an error occurred
          else {
            // if is lecturer (1) add to / get lecturer identitypool 
            // else if is student (0) add to / get student identity
            // else if is empty add student to database  and then get student identity 
            if (Object.keys(data).length == 0) {
              console.log("user does not exist ");
    
              var params = {
                TableName: config.userTypeTable,
                Item: {
                  "UserId": {
                    S: username
                  },
                  "UserType": {
                    S: config.is_student
                  }
                }
              };
    
              console.log("Adding a new user...");
              dynamodb.putItem(params, function (err, data) {
                if (err) {
                  console.error("Unable to add item. Error JSON:", JSON.stringify(err, null, 2));
                } else {
                  console.log("Added item:", JSON.stringify(data));
    
                  getIdentityAndCredentials(username, config.identity_pool_id.student, function (err, resp) {
                    console.log("gotten identity and creds")
                    console.log(resp);
                    const response = {
                      statusCode: 200,
                      body: JSON.stringify(resp)
                    };
                    callback(err, response);
                  });
                }
              });
    
            }
            else {
              var userType = data['Item']['UserType']['S']
    
              if (userType == config.is_student) {
                console.log("student logging in ")
    
                getIdentityAndCredentials(username, config.identity_pool_id.student, function (err, resp) {
                  console.log("gotten identity and creds for student")

                  var payload = JSON.parse(JSON.stringify(resp));

                  console.log("resp");
                  console.log(resp);
                  console.log("payload");
                  console.log(payload);
                  
                  callback(err, resp);
                });
                
    
              }
              else if (userType == config.is_admin) {
    
                // change this to pass admin identity pool
                getIdentityAndCredentials(username, config.identity_pool_id.admin, function (err, resp) {
                  console.log("gotten identity and creds")
                  console.log(resp);
                  const response = {
                    statusCode: 200,
                    body: JSON.stringify(resp)
                  };
                  callback(err, resp);
                });
    
              }
            }
          }           
    
        });
        console.log("success!!");
      }
    });

    return;

  } catch (err) {
    console.log(err);
    return err;
  }

};
