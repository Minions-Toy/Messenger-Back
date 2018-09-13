var Sequelize = require('sequelize');
var sequelize = require('../common/mysql');

var User = sequelize.define('user', {
	P_ID: {
		type: Sequelize.BIGINT(14),
		autoIncrement: true,
		primaryKey: true,
		unique: true,
		allowNull: false
	},
	USER_ID: {
		type: Sequelize.STRING(14),
		allowNull: false
	},
	USER_PW: {
		type: Sequelize.STRING(14),
		allowNull: false
	},
	USER_NICK: {
		type: Sequelize.STRING(14),
		allowNull: false
	},
	USER_STATE: {
		type: Sequelize.TINYINT(1),
		allowNull: true
	}
}, {
	underscored: true,
	timestamps: false,
	createAt: false,
	paranoid: false
});

module.exports = User;
