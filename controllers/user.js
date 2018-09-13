var User = require('../services').User;

exports.signUp = (req, res, next) => {
  // 에러 코드는 공통적으로 정할 필요성이 있음
  console.log(req.body);
  // 사용자 아이디 유효성 검사
  if (req.body.user_id === undefined || req.body.user_id === '' || req.body.user_id.length >= 15) {
    res.json({ 'code': '1001', 'msg': 'Invalid Id' });
    return;
  }

  // 사용자 패스워드 유효성 검사
  if (req.body.user_pw === undefined || req.body.user_pw === '' || req.body.user_pw.length >= 15) {
    // 에러 코드는 공통적으로 정할 필요성이 있음
    res.json({ 'code': '1002', 'msg': 'Invalid Password' });
    return;
  }

  // 사용자 닉네임 유효성 검사
  if (req.body.user_nick === undefined || req.body.user_nick === '' || req.body.user_nick.length >= 15) {
    // 에러 코드는 공통적으로 정할 필요성이 있음
    res.json({ 'code': '1003', 'msg': 'Invalid NickName' });
    return;
  }

  User.signUp(req.body, (ret) => {
    if (ret) {
      res.json({ 'code': '0000', 'msg': 'Success' });
    }
  });
};
