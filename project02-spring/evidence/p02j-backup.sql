
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `audit_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `workspace_id` bigint NOT NULL,
  `actor_id` bigint NOT NULL,
  `action` varchar(80) NOT NULL,
  `target` varchar(190) NOT NULL,
  `metadata` json NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_audit_ws` (`workspace_id`),
  KEY `fk_audit_user` (`actor_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_audit_ws` FOREIGN KEY (`workspace_id`) REFERENCES `workspaces` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `audit_events` WRITE;
/*!40000 ALTER TABLE `audit_events` DISABLE KEYS */;
INSERT INTO `audit_events` VALUES (1,9,14,'workspace.create','workspace:9','{}','2026-11-07 15:23:34'),(2,10,15,'workspace.create','workspace:10','{}','2026-11-07 15:43:39'),(3,11,16,'workspace.create','workspace:11','{}','2026-11-07 19:45:02'),(4,12,17,'workspace.create','workspace:12','{}','2026-11-07 19:45:38');
/*!40000 ALTER TABLE `audit_events` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invitations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `workspace_id` bigint NOT NULL,
  `email` varchar(190) NOT NULL,
  `role` varchar(20) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `expires_at` timestamp NOT NULL,
  `created_by` bigint NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `accepted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `fk_invite_ws` (`workspace_id`),
  KEY `fk_invite_user` (`created_by`),
  CONSTRAINT `fk_invite_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_invite_ws` FOREIGN KEY (`workspace_id`) REFERENCES `workspaces` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_invite_role` CHECK ((`role` in (_gbk'owner',_gbk'member'))),
  CONSTRAINT `chk_invite_status` CHECK ((`status` in (_gbk'pending',_gbk'accepted',_gbk'revoked')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `invitations` WRITE;
/*!40000 ALTER TABLE `invitations` DISABLE KEYS */;
/*!40000 ALTER TABLE `invitations` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `memberships` (
  `workspace_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `role` varchar(20) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`workspace_id`,`user_id`),
  KEY `fk_member_user` (`user_id`),
  CONSTRAINT `fk_member_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_member_ws` FOREIGN KEY (`workspace_id`) REFERENCES `workspaces` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_member_role` CHECK ((`role` in (_utf8mb4'owner',_utf8mb4'member')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `memberships` WRITE;
/*!40000 ALTER TABLE `memberships` DISABLE KEYS */;
INSERT INTO `memberships` VALUES (1,6,'owner','2026-11-07 14:21:52'),(2,7,'owner','2026-11-07 14:22:20'),(3,8,'owner','2026-11-07 14:46:18'),(4,9,'owner','2026-11-07 14:46:42'),(5,10,'owner','2026-11-07 14:51:54'),(6,11,'owner','2026-11-07 14:52:28'),(7,12,'owner','2026-11-07 15:03:15'),(8,13,'owner','2026-11-07 15:07:47'),(9,14,'owner','2026-11-07 15:23:34'),(10,15,'owner','2026-11-07 15:43:39'),(11,16,'owner','2026-11-07 19:45:02'),(12,17,'owner','2026-11-07 19:45:38');
/*!40000 ALTER TABLE `memberships` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `token_hash` char(64) NOT NULL,
  `user_id` bigint NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_hash`),
  KEY `fk_sessions_user` (`user_id`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('2b1a4e637396bde7cdff5edc4f8f58c08a5d998304c012b90898370233fc3f9b',13,'2026-11-07 19:07:47','2026-11-07 15:07:47'),('2d896405dc225768fad8717846bf095c91cac5e083eda0a2604c2cdb2ba55472',4,'2026-11-07 18:21:09','2026-11-07 14:21:09'),('422e4fd5f75290be36de2f9f5fe74afef07f89eb3de0e46d8f1b98d146522f62',6,'2026-11-07 18:21:53','2026-11-07 14:21:52'),('50bf706153541aef06303b59503ea3b5acfdce1ea06b71f513b6c9a51c827aa1',10,'2026-11-07 18:51:55','2026-11-07 14:51:54'),('52cd4b2190290804ae72d50522f0fc53115137fe956ecb8bee366aad746685eb',8,'2026-11-07 18:46:19','2026-11-07 14:46:18'),('6538ad71c75a0a1e39478c703d4726f093f85d9ea6c81257bce30562007b3920',14,'2026-11-07 19:23:34','2026-11-07 15:23:34'),('65d00c54a2824f43b4221ab4f2f873474e7bdc9c8b339914e15215042c10c619',2,'2026-11-07 18:20:16','2026-11-07 14:20:15'),('6c17ae3277fab7d240af4b285996effd1203b0a3aeb1a53731ca1330fc09bf72',16,'2026-11-07 23:45:02','2026-11-07 19:45:02'),('6c349645fa9dc8b04c133a6cbc1bf194f8465ff6bca3f4408c69c54b6cfcc828',3,'2026-11-07 18:20:56','2026-11-07 14:20:55'),('9763620d61e8e5767fd4b1d7edb8ea029e3ff162f9ecfdc4b86fa2ade0b47cf3',1,'2026-11-07 18:19:39','2026-11-07 14:19:38'),('aa0e019c7c42705fc3e2fd042b67a0962e75e1c8ad9e97d5101abc3b65f0ff56',11,'2026-11-07 18:52:28','2026-11-07 14:52:28'),('b112f47ae2616783441f0230cbef6c0ea0216d7611d8cab7beb2a808bfec88a9',15,'2026-11-07 19:43:40','2026-11-07 15:43:39'),('b301eadeabd1a949072815ad3cf08641ee4e8f9888606e767b98215d02eebbe3',5,'2026-11-07 18:21:16','2026-11-07 14:21:15'),('c33773d9b9ff5482c537f1daf22eef5a8b85a97ba95b5714912c6d2d7dda32c9',9,'2026-11-07 18:46:42','2026-11-07 14:46:42'),('c392a966b9dc69977a8abb07f03d6c52aa34e73710ab04cd899dc9c4015df350',7,'2026-11-07 18:22:20','2026-11-07 14:22:20'),('d780aa737d81593491b326311986b4cf25c20dc90e1e4dfa6759e17871f5f994',17,'2026-11-07 23:45:39','2026-11-07 19:45:38'),('fd2f1d2f9c0bf5b1ee8bb59717b1d00731ba5e50ff82e2079ffd5e159b30373c',12,'2026-11-07 19:03:16','2026-11-07 15:03:15');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `workspace_id` bigint NOT NULL,
  `title` varchar(200) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'todo',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_task_title` (`workspace_id`,`title`),
  CONSTRAINT `fk_task_ws` FOREIGN KEY (`workspace_id`) REFERENCES `workspaces` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_task_status` CHECK ((`status` in (_utf8mb4'todo',_utf8mb4'doing',_utf8mb4'done')))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,2,'contract-task','todo','2026-11-07 14:22:20'),(2,7,'contract-task','todo','2026-11-07 15:03:15'),(3,8,'contract-task','todo','2026-11-07 15:07:47'),(4,9,'contract-task','todo','2026-11-07 15:23:34'),(5,10,'contract-task','todo','2026-11-07 15:43:40'),(6,11,'contract-task','todo','2026-11-07 19:45:02'),(7,12,'contract-task','todo','2026-11-07 19:45:39');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(200) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'java-owner-1794061163@example.com','$2a$10$JzuAeKn7l2OLH0xfQXvNquULJ6qqRT/q8GZxg5w7DHWrcI9Fky2aK','2026-11-07 14:19:38'),(2,'diag-1794061215@example.com','$2a$10$2TjBXlzf3pcl91qPGd6IvO0rXU53U2C.x3yvE.8sWM8hfPQ5VUVau','2026-11-07 14:20:15'),(3,'java-owner-1794061239@example.com','$2a$10$kPlrQwtpfrsvLAEDu6Smf.KkoeNDwbiG8PuNENI/ERXXwGzkcnCt2','2026-11-07 14:20:55'),(4,'java-owner-1794061269@example.com','$2a$10$GdYB7w3BMRYzCy71K0MKvONBehry1qXH2CEuBfT9ZcUHFHd7ZGmmm','2026-11-07 14:21:09'),(5,'block-1794061275@example.com','$2a$10$ciVx6Kh5ug2xocA/DPlFWea3uxSvyiOgtBPuMktP/IJ8H5o8t9RpW','2026-11-07 14:21:15'),(6,'java-owner-1794061298@example.com','$2a$10$B1vZLZrX6sata7i7bo4mlOJxcDvPTQu69plMkWRrxfYGS0DYG0vJu','2026-11-07 14:21:52'),(7,'java-owner-1794061326@example.com','$2a$10$oelnlhjQDqvnshDgGCZj9upIitb.dGXP06hbe3ny7MPilzT5kagPy','2026-11-07 14:22:20'),(8,'diag-pool-1794062778@example.com','$2a$10$.hyih3PCnX0YEql9h46HfufxWK8gQOQ4CxL95o.EcwuhbB2KugROu','2026-11-07 14:46:18'),(9,'diag-pool-1794062802@example.com','$2a$10$ZxdlWOO5GaKxiXVvVFwpC.HBFYT4furON8ADnCchbu24KcKeOi9ji','2026-11-07 14:46:42'),(10,'diag-pool-1794063114@example.com','$2a$10$sQkFEZn27BImc0wB9rbale1Ivwxc3s.5iFoNridNv1upGkf74S8yC','2026-11-07 14:51:54'),(11,'diag-pool-1794063147@example.com','$2a$10$Kl1XSrwoUalQzb.Hz7UrXuth36zDNHjaniUy2A4qXVorTYxnlFh9G','2026-11-07 14:52:27'),(12,'java-owner-1794063777@example.com','$2a$10$d6ry6ly9E0obyXWzJyKIyu.27NTw8Dt6yyPVHC6QPeKBjGtjVTPhW','2026-11-07 15:03:15'),(13,'java-owner-1794064049@example.com','$2a$10$iqHapTsXwQXQmGrxp6wg3Okqa.gun/iYdaCeMmtcx2fhk.U.PtRvG','2026-11-07 15:07:46'),(14,'java-owner-1794064996@example.com','$2a$10$wz3HHkGXL7KlleoekIKKN.FZIljvDGyUKP9TrWOv4NEW1.klQs9re','2026-11-07 15:23:34'),(15,'java-owner-1794066205@example.com','$2a$10$jl2a8ldgMXVo.uX85DC4sucQP4ZsfZLnSaxjo1gzH4TcW1eF4jsii','2026-11-07 15:43:39'),(16,'java-owner-1794080683@example.com','$2a$10$DckpLr9vb8gWoSDW1YcioeP8V4JnJoMXkcoOphv0EoOddmt4B0eWS','2026-11-07 19:45:02'),(17,'java-owner-1794080721@example.com','$2a$10$m8S62AdcH/Iiwm5n3XvLNu6pZGmWCaKlIzC6i6W/ZQqegd3jqAeei','2026-11-07 19:45:38');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `workspaces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `workspaces` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `slug` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `workspaces` WRITE;
/*!40000 ALTER TABLE `workspaces` DISABLE KEYS */;
INSERT INTO `workspaces` VALUES (1,'Java Migration','c6105968-f7ea-4aba-893f-688ed086d4a1','2026-11-07 14:21:52'),(2,'Java Migration','a73f35f1-b191-485c-bfd4-83ad5c3e5506','2026-11-07 14:22:20'),(3,'Lock Diagnostics','ea375748-45d9-4055-8c09-630bc0d66e66','2026-11-07 14:46:18'),(4,'Lock Diagnostics','a1aed2d7-5243-424f-99ef-1ffa7317c5a5','2026-11-07 14:46:42'),(5,'Lock Diagnostics','142564ec-c200-4c83-9d4b-f11b8801fcb9','2026-11-07 14:51:54'),(6,'Lock Diagnostics','c8f00b6d-b889-497b-871a-ae629965e1f4','2026-11-07 14:52:28'),(7,'Java Migration','24d96c05-156e-46e4-bf77-6ae36fdcfee4','2026-11-07 15:03:15'),(8,'Java Migration','c598df56-3b10-41b2-8274-6271d280f897','2026-11-07 15:07:47'),(9,'Java Migration','df2275df-6ed1-4801-acc0-d93f81978245','2026-11-07 15:23:34'),(10,'Java Migration','4d026944-c3da-4121-b22b-f9cb9928747f','2026-11-07 15:43:39'),(11,'Java Migration','d1c504a1-9883-408c-bc29-05ee37fe1fa0','2026-11-07 19:45:02'),(12,'Java Migration','3dfc205d-a4c1-450b-a800-f81aebb6f46c','2026-11-07 19:45:38');
/*!40000 ALTER TABLE `workspaces` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

