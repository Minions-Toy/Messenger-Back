var models = require('../models');
var sequelize = require('../common/mysql');
var User = models.User;

exports.signUp = (params, cb) => {
  var data = {};
  data.USER_ID = params.user_id;
  data.USER_PW = params.user_pw;
  data.USER_NICK = params.user_nick;
  console.log(data);
  User.build(data).save()
    .then((data) => {
      console.log(data.dataValues);
      cb(data.dataValues);
    }).catch((err) => {
      cb(err);
    });
};
