CREATE DATABASE  IF NOT EXISTS `COS20031_bitdrawnmy` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `COS20031_bitdrawnmy`;
-- MySQL dump 10.13  Distrib 9.3.0, for macos15.4 (arm64)
--
-- Host: 7sz9y.h.filess.io    Database: COS20031_bitdrawnmy
-- ------------------------------------------------------
-- Server version	11.6.2-MariaDB-ubu2404

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Attachment`
--

DROP TABLE IF EXISTS `Attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Attachment` (
  `attachmentID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `postID` int(10) unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('text','image','video','audio','document') NOT NULL DEFAULT 'text',
  `url` varchar(255) NOT NULL,
  `uploadedBy` int(10) unsigned DEFAULT NULL,
  `uploadedAt` datetime NOT NULL,
  PRIMARY KEY (`attachmentID`),
  KEY `idx_uploadedBy` (`uploadedBy`),
  KEY `idx_post_type` (`postID`,`type`) USING BTREE,
  KEY `idx_uploadedAt` (`uploadedAt`) USING BTREE,
  KEY `idx_postID` (`postID`) USING BTREE,
  CONSTRAINT `Attachment_Post_FK` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE,
  CONSTRAINT `Attachment_User_FK` FOREIGN KEY (`uploadedBy`) REFERENCES `User` (`userID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Comment`
--

DROP TABLE IF EXISTS `Comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Comment` (
  `commentID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  `postID` int(10) unsigned NOT NULL,
  `commentText` text NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  PRIMARY KEY (`commentID`),
  KEY `Comment_Post_FK` (`postID`),
  KEY `Comment_User_FK` (`userID`),
  CONSTRAINT `Comment_Post_FK` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE,
  CONSTRAINT `Comment_User_FK` FOREIGN KEY (`userID`) REFERENCES `User` (`userID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Community`
--

DROP TABLE IF EXISTS `Community`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Community` (
  `communityID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `desc` varchar(300) DEFAULT NULL,
  `createdBy` int(10) unsigned NOT NULL,
  `createdAt` date NOT NULL,
  `visibility` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`communityID`),
  KEY `idx_createdBy` (`createdBy`),
  KEY `idx_name` (`name`) USING BTREE,
  CONSTRAINT `Community_User_FK` FOREIGN KEY (`createdBy`) REFERENCES `User` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Incident`
--

DROP TABLE IF EXISTS `Incident`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Incident` (
  `incidentID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `postID` int(10) unsigned NOT NULL,
  `severity` enum('low','medium','high') NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `status` enum('open','closed') NOT NULL,
  `openedBy` int(10) unsigned DEFAULT NULL,
  `openedAt` datetime DEFAULT NULL,
  `closedBy` int(10) unsigned DEFAULT NULL,
  `closedAt` datetime DEFAULT NULL,
  `secondsToClose` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`incidentID`),
  KEY `fk_postID` (`postID`),
  KEY `Incident_User_FK` (`openedBy`),
  KEY `Incident_User_FK_1` (`closedBy`),
  KEY `idx_severity` (`severity`) USING BTREE,
  KEY `idx_location` (`location`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  CONSTRAINT `Incident_User_FK` FOREIGN KEY (`openedBy`) REFERENCES `User` (`userID`) ON DELETE SET NULL,
  CONSTRAINT `Incident_User_FK_1` FOREIGN KEY (`closedBy`) REFERENCES `User` (`userID`) ON DELETE SET NULL,
  CONSTRAINT `fk_postID` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Notification`
--

DROP TABLE IF EXISTS `Notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notification` (
  `notificationID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `senderID` int(10) unsigned NOT NULL,
  `notificationText` varchar(255) NOT NULL,
  `targetType` enum('post','comment','poll') NOT NULL,
  `targetID` int(10) unsigned NOT NULL,
  `createdAt` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`notificationID`),
  KEY `fk_sender` (`senderID`),
  CONSTRAINT `fk_sender` FOREIGN KEY (`senderID`) REFERENCES `User` (`userID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Poll`
--

DROP TABLE IF EXISTS `Poll`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Poll` (
  `pollID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `postID` int(10) unsigned NOT NULL,
  `title` varchar(100) NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`options`)),
  `duration` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`pollID`),
  KEY `Poll_Post_FK` (`postID`),
  CONSTRAINT `Poll_Post_FK` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PollVote`
--

DROP TABLE IF EXISTS `PollVote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PollVote` (
  `pollID` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `optionID` int(11) DEFAULT NULL,
  PRIMARY KEY (`pollID`,`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Post`
--

DROP TABLE IF EXISTS `Post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Post` (
  `postID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned DEFAULT NULL,
  `communityID` int(10) unsigned NOT NULL,
  `postType` enum('feed','poll','incident') NOT NULL,
  `title` varchar(50) NOT NULL,
  `body` varchar(500) NOT NULL,
  `createdAt` datetime NOT NULL,
  `tagList` varchar(50) DEFAULT NULL,
  `isPinned` tinyint(1) NOT NULL,
  `viewCount` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`postID`),
  KEY `Post_Community_FK` (`communityID`),
  KEY `idx_postType` (`postType`) USING BTREE,
  KEY `idx_title` (`title`) USING BTREE,
  KEY `idx_createdAt` (`createdAt`) USING BTREE,
  KEY `idx_isPinned` (`isPinned`) USING BTREE,
  KEY `idx_viewCount` (`viewCount`) USING BTREE,
  KEY `Post_User_FK` (`userID`),
  CONSTRAINT `Post_Community_FK` FOREIGN KEY (`communityID`) REFERENCES `Community` (`communityID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Post_User_FK` FOREIGN KEY (`userID`) REFERENCES `User` (`userID`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Question`
--

DROP TABLE IF EXISTS `Question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Question` (
  `questionID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `postID` int(10) unsigned NOT NULL,
  `answerID` int(10) unsigned DEFAULT NULL,
  `questionText` text NOT NULL,
  `isResolved` tinyint(1) NOT NULL DEFAULT 0,
  `resolvedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`questionID`),
  KEY `Question_Post_FK` (`postID`),
  KEY `Question_User_FK` (`answerID`),
  KEY `idx_isResolved` (`isResolved`) USING BTREE,
  CONSTRAINT `Question_Post_FK` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`) ON DELETE CASCADE,
  CONSTRAINT `Question_User_FK` FOREIGN KEY (`answerID`) REFERENCES `User` (`userID`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Reaction`
--

DROP TABLE IF EXISTS `Reaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Reaction` (
  `reactionID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userID` int(10) unsigned NOT NULL,
  `targetType` varchar(100) DEFAULT NULL,
  `postID` int(10) unsigned DEFAULT NULL,
  `createAt` date NOT NULL,
  `emoji` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`reactionID`),
  KEY `Reaction_Post_FK` (`postID`),
  KEY `Reaction_User_FK` (`userID`),
  CONSTRAINT `Reaction_Post_FK` FOREIGN KEY (`postID`) REFERENCES `Post` (`postID`),
  CONSTRAINT `Reaction_User_FK` FOREIGN KEY (`userID`) REFERENCES `User` (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `User` (
  `userID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('user','admin') NOT NULL DEFAULT 'user',
  `department` varchar(100) DEFAULT NULL,
  `avatarURL` varchar(100) DEFAULT 'exampleURL',
  `createdAt` datetime NOT NULL,
  `status` enum('active','blocked') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`userID`),
  UNIQUE KEY `User_UNIQUE` (`email`),
  KEY `idx_role` (`role`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UserCommunity`
--

DROP TABLE IF EXISTS `UserCommunity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UserCommunity` (
  `userID` int(10) unsigned NOT NULL,
  `communityID` int(10) unsigned NOT NULL,
  `joinedAt` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`userID`,`communityID`),
  KEY `communityID` (`communityID`),
  CONSTRAINT `UserCommunity_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `User` (`userID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `UserCommunity_ibfk_2` FOREIGN KEY (`communityID`) REFERENCES `Community` (`communityID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-30 22:58:59
