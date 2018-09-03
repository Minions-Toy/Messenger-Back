//USER_INFO
CREATE TABLE `CHATTING_ROOM` (
  `C_ID` varchar(14) NOT NULL DEFAULT '',
  `CREATE_DATE` date DEFAULT NULL,
  `LAST_UPDATED` date DEFAULT NULL,
  `ROOM_NAME` varchar(14) DEFAULT NULL,
  PRIMARY KEY (`C_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


//MESSAGE
CREATE TABLE `MESSAGE` (
  `M_ID` varchar(14) NOT NULL,
  `C_ID` varchar(14) DEFAULT NULL,
  `P_ID` varchar(14) DEFAULT NULL,
  `CONTENT` text,
  `REG_DATE` date DEFAULT NULL,
  PRIMARY KEY (`M_ID`),
  KEY `FK_C_ID_MESSAGE` (`C_ID`),
  KEY `FK_P_ID_MESSAGE` (`P_ID`),
  CONSTRAINT `FK_C_ID_MESSAGE` FOREIGN KEY (`C_ID`) REFERENCES `CHATTING_ROOM` (`C_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_P_ID_MESSAGE` FOREIGN KEY (`P_ID`) REFERENCES `USER_INFO` (`P_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

//PARTICIPANT
CREATE TABLE `PARTICIPANT` (
  `P_ID` varchar(14) DEFAULT NULL,
  `C_ID` varchar(14) DEFAULT NULL,
  `JOIN_DATE` datetime DEFAULT NULL,
  `SEEN_DATE` datetime DEFAULT NULL,
  KEY `FK_P_ID_PARTICIPANT` (`P_ID`),
  KEY `FK_C_ID_PARTICIPANT` (`C_ID`),
  CONSTRAINT `FK_C_ID_PARTICIPANT` FOREIGN KEY (`C_ID`) REFERENCES `CHATTING_ROOM` (`C_ID`) ON DELETE CASCADE,
  CONSTRAINT `FK_P_ID_PARTICIPANT` FOREIGN KEY (`P_ID`) REFERENCES `USER_INFO` (`P_ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

//USER_INFO
CREATE TABLE `USER_INFO` (
  `P_ID` varchar(14) NOT NULL DEFAULT '',
  `USER_ID` varchar(14) DEFAULT NULL,
  `USER_PW` varchar(14) DEFAULT NULL,
  `USER_NICK` varchar(14) DEFAULT NULL,
  `USER_STATE` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`P_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
