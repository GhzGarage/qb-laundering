CREATE TABLE IF NOT EXISTS `qb_laundering` (
  `owner` varchar(50) NOT NULL DEFAULT '',
  `business` varchar(50) DEFAULT NULL,
  `worth` int(11) DEFAULT NULL,
  PRIMARY KEY (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
