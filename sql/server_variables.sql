SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `server_variables`
-- ----------------------------
DROP TABLE IF EXISTS `server_variables`;
CREATE TABLE `server_variables` (
  `name` varchar(50) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of server_variables
-- ----------------------------
