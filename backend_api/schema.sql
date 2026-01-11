-- MySQL schema for Adoptive Pet Hero
CREATE DATABASE IF NOT EXISTS adoptive_pet_hero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE adoptive_pet_hero;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(191) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','user') NOT NULL DEFAULT 'user'
);

CREATE TABLE IF NOT EXISTS pets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(191) NOT NULL,
  age INT NOT NULL,
  gender VARCHAR(50) NOT NULL,
  description TEXT,
  status ENUM('available','adopted') NOT NULL DEFAULT 'available',
  breed VARCHAR(191) NULL,
  image_url TEXT NULL
);

-- Sample accounts (password: password)
INSERT INTO users (email, password, role) VALUES
('admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('user@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user');

-- Sample pets
INSERT INTO pets (name, age, gender, description, status, breed, image_url) VALUES
('Buddy', 2, 'Male', 'Friendly and loves fetch.', 'available', 'Golden Retriever', 'https://images.unsplash.com/photo-1507146426996-ef05306b995a'),
('Luna', 3, 'Female', 'Energetic husky.', 'available', 'Husky', 'https://images.unsplash.com/photo-1557970231-51b6ecfa0db9'),
('Milo', 1, 'Male', 'Calm indoor cat.', 'adopted', 'Tabby', 'https://images.unsplash.com/photo-1518791841217-8f162f1e1131');
