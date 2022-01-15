-- --------------------------------------------------------
-- Sunucu:                       127.0.0.1
-- Sunucu sürümü:                10.4.19-MariaDB - mariadb.org binary distribution
-- Sunucu İşletim Sistemi:       Win64
-- HeidiSQL Sürüm:               11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- essentialmode2 için veritabanı yapısı dökülüyor


-- tablo yapısı dökülüyor essentialmode2.bounties
CREATE TABLE IF NOT EXISTS `bounties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) DEFAULT NULL,
  `target` varchar(255) DEFAULT NULL,
  `reason` longtext DEFAULT NULL,
  `bountyReward` int(11) DEFAULT NULL,
  `createdAt` varchar(255) DEFAULT NULL,
  `hunters` longtext DEFAULT '[]',
  `target_name` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4;

-- essentialmode2.bounties: ~13 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `bounties` DISABLE KEYS */;
/*!40000 ALTER TABLE `bounties` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
