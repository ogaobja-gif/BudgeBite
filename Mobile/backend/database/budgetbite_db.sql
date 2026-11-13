CREATE DATABASE IF NOT EXISTS budgetbite_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE budgetbite_db;

CREATE TABLE IF NOT EXISTS users (
  user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone_number VARCHAR(25) NOT NULL,
  username VARCHAR(20) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,                 -- password_hash() output, never plain text
  account_type ENUM('customer','seller','admin') NOT NULL DEFAULT 'customer',
  account_status ENUM('Active','Pending','Rejected') NOT NULL DEFAULT 'Active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS password_resets (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  code_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS auth_tokens (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  selector CHAR(24) NOT NULL UNIQUE,
  validator_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Administrator account (created here, never through the app). Login: admin / Admin@12345 -- change it later.
INSERT IGNORE INTO users (full_name,email,phone_number,username,password,account_type,account_status)
VALUES ('System Administrator','admin@budgetbite.local','09000000000','admin',
'$2y$10$SmXE0Z2qSUkOAotxAK9y0.BKPpehSWkxTpwHZO9aWRIQyOyQE9/6a','admin','Active');
