DROP TABLE IF EXISTS `daily_rewards`;
CREATE TABLE IF NOT EXISTS `daily_rewards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `day` int(11) NOT NULL,
  `lastClaim` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;