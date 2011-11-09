SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `u2361_xem` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ;
USE `u2361_xem` ;

-- -----------------------------------------------------
-- Table `u2361_xem`.`locations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`locations` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`locations` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(16) NULL COMMENT 'the short name' ,
  `description` VARCHAR(256) NULL ,
  `url` VARCHAR(90) NULL ,
  `show_url` VARCHAR(128) NULL ,
  `movie_url` VARCHAR(128) NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`elements`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`elements` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`elements` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `type` ENUM('show','movie','episode') NOT NULL DEFAULT 'show' ,
  `main_name` VARCHAR(45) NOT NULL ,
  `entity_order` VARCHAR(90) NULL ,
  `lock_lvl` INT NULL DEFAULT 0 ,
  `note` TEXT NULL ,
  `forum_link` VARCHAR(512) NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `main_name_UNIQUE` (`main_name` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`seasons`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`seasons` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`seasons` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `location_id` INT NOT NULL ,
  `element_id` INT NOT NULL ,
  `identifier` VARCHAR(90) NULL COMMENT 'the tvdbid or anidb id.\n\nif this is not set use the identifier of the previous season is used\n\nif set this season has a separate id. absolute start should be 1' ,
  `season` INT NULL DEFAULT -1 COMMENT '-1 = global\nx>=0 = season number x' ,
  `season_size` INT NULL DEFAULT -1 COMMENT '-1 = has no size\n0 = size zero\nx>0 = size x' ,
  `absolute_start` INT NULL DEFAULT 0 COMMENT '-1 = dont calulate absolute numbers\n0 = use previous season \nx>0 = start at x' ,
  `episode_start` INT NULL DEFAULT 1 ,
  PRIMARY KEY (`id`) ,
  INDEX `location` (`location_id` ASC) ,
  UNIQUE INDEX `helper` (`location_id` ASC, `element_id` ASC, `season` ASC) ,
  INDEX `fk_elementLocations_elements1` (`element_id` ASC) ,
  CONSTRAINT `location`
    FOREIGN KEY (`location_id` )
    REFERENCES `u2361_xem`.`locations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_elementLocations_elements1`
    FOREIGN KEY (`element_id` )
    REFERENCES `u2361_xem`.`elements` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`languages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`languages` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`languages` (
  `id` VARCHAR(2) NOT NULL COMMENT 'the iso ISO3166-1 alpha-2 name' ,
  `name` VARCHAR(45) NULL COMMENT 'human name' ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`names`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`names` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`names` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `element_id` INT NOT NULL ,
  `season` INT NOT NULL DEFAULT -1 COMMENT '-1 = for all seasons' ,
  `name` VARCHAR(128) NULL ,
  `language` VARCHAR(2) NULL ,
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_names_elements1` (`element_id` ASC) ,
  INDEX `fk_names_languages1` (`language` ASC) ,
  CONSTRAINT `fk_names_elements1`
    FOREIGN KEY (`element_id` )
    REFERENCES `u2361_xem`.`elements` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_names_languages1`
    FOREIGN KEY (`language` )
    REFERENCES `u2361_xem`.`languages` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`directrules`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`directrules` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`directrules` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `origin_id` INT NOT NULL ,
  `destination_id` INT NOT NULL ,
  `element_id` INT NOT NULL COMMENT 'only to elements with type show' ,
  `name_id` INT NULL DEFAULT NULL COMMENT 'rev to a specific name if needed' ,
  `origin_season` INT NULL ,
  `origin_episode` INT NULL ,
  `destination_season` INT NULL ,
  `destination_episode` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_maps_locations1` (`origin_id` ASC) ,
  INDEX `fk_maps_locations2` (`destination_id` ASC) ,
  INDEX `fk_directrules_names1` (`name_id` ASC) ,
  INDEX `fk_directrules_elements1` (`element_id` ASC) ,
  CONSTRAINT `fk_maps_locations1`
    FOREIGN KEY (`origin_id` )
    REFERENCES `u2361_xem`.`locations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_maps_locations2`
    FOREIGN KEY (`destination_id` )
    REFERENCES `u2361_xem`.`locations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_directrules_names1`
    FOREIGN KEY (`name_id` )
    REFERENCES `u2361_xem`.`names` (`id` )
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_directrules_elements1`
    FOREIGN KEY (`element_id` )
    REFERENCES `u2361_xem`.`elements` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`users` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`users` (
  `user_id` INT NOT NULL AUTO_INCREMENT ,
  `user_nick` VARCHAR(45) NULL ,
  `user_email` VARCHAR(255) NOT NULL ,
  `user_pass` VARCHAR(60) NOT NULL ,
  `user_lvl` INT NULL DEFAULT 0 ,
  `user_date` DATETIME NOT NULL ,
  `user_modified` DATETIME NOT NULL ,
  `user_last_login` DATETIME NULL DEFAULT NULL ,
  PRIMARY KEY (`user_id`) ,
  UNIQUE INDEX `user_email` (`user_email` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `u2361_xem`.`passthru`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`passthru` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`passthru` (
  `id` INT NOT NULL ,
  `origin_id` INT NOT NULL ,
  `destination_id` INT NOT NULL ,
  `element_id` INT NOT NULL ,
  `type` ENUM('absolute','sxxexx') NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_passthru_elements1` (`element_id` ASC) ,
  INDEX `fk_passthru_locations1` (`origin_id` ASC) ,
  INDEX `fk_passthru_locations2` (`destination_id` ASC) ,
  CONSTRAINT `fk_passthru_elements1`
    FOREIGN KEY (`element_id` )
    REFERENCES `u2361_xem`.`elements` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_passthru_locations1`
    FOREIGN KEY (`origin_id` )
    REFERENCES `u2361_xem`.`locations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_passthru_locations2`
    FOREIGN KEY (`destination_id` )
    REFERENCES `u2361_xem`.`locations` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `u2361_xem`.`history`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `u2361_xem`.`history` ;

CREATE  TABLE IF NOT EXISTS `u2361_xem`.`history` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `user_id` INT NOT NULL ,
  `user_lvl` INT NULL COMMENT 'user lvl at time' ,
  `obj_id` INT NOT NULL COMMENT 'object id' ,
  `obj_type` VARCHAR(12) NOT NULL COMMENT 'object type' ,
  `element_id` INT NULL DEFAULT 0 ,
  `action` VARCHAR(12) NULL ,
  `time` DATETIME NULL COMMENT 'time of the action' ,
  `revision` INT NULL ,
  `old_data` TEXT NULL ,
  `new_data` TEXT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_history_users1` (`user_id` ASC) ,
  INDEX `fk_history_elements1` (`element_id` ASC) ,
  CONSTRAINT `fk_history_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `u2361_xem`.`users` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_history_elements1`
    FOREIGN KEY (`element_id` )
    REFERENCES `u2361_xem`.`elements` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `u2361_xem`.`locations`
-- -----------------------------------------------------
START TRANSACTION;
USE `u2361_xem`;
INSERT INTO `u2361_xem`.`locations` (`id`, `name`, `description`, `url`, `show_url`, `movie_url`) VALUES (1, 'scene', 'the SCENE', NULL, NULL, NULL);
INSERT INTO `u2361_xem`.`locations` (`id`, `name`, `description`, `url`, `show_url`, `movie_url`) VALUES (2, 'tvdb', 'thetvdb.com', 'www.thetvdb.com', 'http://thetvdb.com/?tab=series&id={tvdb}', NULL);
INSERT INTO `u2361_xem`.`locations` (`id`, `name`, `description`, `url`, `show_url`, `movie_url`) VALUES (3, 'anidb', 'anidb.net', 'www.anidb.net', 'http://anidb.net/perl-bin/animedb.pl?show=anime&aid={anidb}', NULL);
INSERT INTO `u2361_xem`.`locations` (`id`, `name`, `description`, `url`, `show_url`, `movie_url`) VALUES (4, 'rage', 'tv rage', 'www.tvrage.com', NULL, NULL);
INSERT INTO `u2361_xem`.`locations` (`id`, `name`, `description`, `url`, `show_url`, `movie_url`) VALUES (5, 'trakt', 'trakt is actively keeping a record of what TV shows and movies you are watching.', 'http://trakt.tv/', 'http://trakt.tv/search?q=tvdb:{tvdb}', 'http://trakt.tv/search?q=imdb:{imdb}');

COMMIT;

-- -----------------------------------------------------
-- Data for table `u2361_xem`.`elements`
-- -----------------------------------------------------
START TRANSACTION;
USE `u2361_xem`;
INSERT INTO `u2361_xem`.`elements` (`id`, `type`, `main_name`, `entity_order`, `lock_lvl`, `note`, `forum_link`) VALUES (1, 'show', 'Black Lagoon', NULL, NULL, NULL, NULL);
INSERT INTO `u2361_xem`.`elements` (`id`, `type`, `main_name`, `entity_order`, `lock_lvl`, `note`, `forum_link`) VALUES (2, 'show', 'American Dad!', NULL, NULL, NULL, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `u2361_xem`.`seasons`
-- -----------------------------------------------------
START TRANSACTION;
USE `u2361_xem`;
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (1, 2, 2, '73141', 1, 7, 1, NULL);
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (2, 2, 1, '', 1, 12, 1, NULL);
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (3, 2, 1, '', 2, 12, 0, NULL);
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (4, 2, 1, '', 3, 5, 0, NULL);
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (5, 3, 1, '3395', 1, 12, 1, NULL);
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (6, 3, 1, '4597', 2, 12, 1, NULL);
INSERT INTO `u2361_xem`.`seasons` (`id`, `location_id`, `element_id`, `identifier`, `season`, `season_size`, `absolute_start`, `episode_start`) VALUES (7, 3, 1, '6645', 3, 5, 1, NULL);

COMMIT;

-- -----------------------------------------------------
-- Data for table `u2361_xem`.`names`
-- -----------------------------------------------------
START TRANSACTION;
USE `u2361_xem`;
INSERT INTO `u2361_xem`.`names` (`id`, `element_id`, `season`, `name`, `language`) VALUES (1, 1, 2, 'Black Lagoon: The Second Barrage', NULL);
INSERT INTO `u2361_xem`.`names` (`id`, `element_id`, `season`, `name`, `language`) VALUES (2, 1, 3, 'Black Lagoon: Roberta`s Blood Trail', NULL);

COMMIT;