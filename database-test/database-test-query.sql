-- DDL: Membuat tabel-tabel utama
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama_kategori VARCHAR(255) NOT NULL
);

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(255) NOT NULL,
    alamat TEXT,
    no_ktp VARCHAR(50) UNIQUE,
    no_hp VARCHAR(20),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    judul VARCHAR(255) NOT NULL,
    pengarang VARCHAR(255),
    penerbit VARCHAR(255),
    isbn VARCHAR(50) UNIQUE,
    tahun_terbit INT,
    jumlah_tersedia INT DEFAULT 0,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE borrowings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    book_id INT,
    tanggal_pinjam DATE NOT NULL,
    tanggal_batas_kembali DATE NOT NULL,
    tanggal_kembali DATE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- ==========================================
-- DML: Insert Initial Data
-- ==========================================

-- 1. Buatlah 5 Kategori
INSERT INTO categories (nama_kategori) VALUES 
('Fiksi'), ('Sains'), ('Sejarah'), ('Teknologi'), ('Biografi');

-- 2. Buatlah 5 User
INSERT INTO users (nama, alamat, no_ktp, no_hp, email) VALUES
('User 1', 'Alamat 1', '12345678901', '08111', 'user1@email.com'),
('User 2', 'Alamat 2', '12345678902', '08112', 'user2@email.com'),
('User 3', 'Alamat 3', '12345678903', '08113', 'user3@email.com'),
('User 4', 'Alamat 4', '12345678904', '08114', 'user4@email.com'),
('User 5', 'Alamat 5', '12345678905', '08115', 'user5@email.com');

-- 3. Masukkan 10 Buku
INSERT INTO books (judul, pengarang, penerbit, isbn, tahun_terbit, jumlah_tersedia, category_id) VALUES
('Buku 1', 'Pengarang 1', 'Penerbit 1', 'ISBN-01', 2020, 10, 1),
('Buku 2', 'Pengarang 2', 'Penerbit 2', 'ISBN-02', 2020, 10, 1),
('Buku 3', 'Pengarang 3', 'Penerbit 3', 'ISBN-03', 2020, 10, 2),
('Buku 4', 'Pengarang 4', 'Penerbit 4', 'ISBN-04', 2021, 10, 2),
('Buku 5', 'Pengarang 5', 'Penerbit 5', 'ISBN-05', 2021, 10, 3),
('Buku 6', 'Pengarang 6', 'Penerbit 6', 'ISBN-06', 2021, 10, 3),
('Buku 7', 'Pengarang 7', 'Penerbit 7', 'ISBN-07', 2022, 10, 4),
('Buku 8', 'Pengarang 8', 'Penerbit 8', 'ISBN-08', 2022, 10, 4),
('Buku 9', 'Pengarang 9', 'Penerbit 9', 'ISBN-09', 2023, 10, 5),
('Buku 10', 'Pengarang 10', 'Penerbit 10', 'ISBN-10', 2023, 10, 5);

-- 4. Masukkan 9 Data Peminjaman
-- User 1 pinjam Buku 1, 2, 3 (Tepat Waktu)
INSERT INTO borrowings (user_id, book_id, tanggal_pinjam, tanggal_batas_kembali, tanggal_kembali) VALUES
(1, 1, '2023-10-01', '2023-10-08', '2023-10-08'),
(1, 2, '2023-10-01', '2023-10-08', '2023-10-08'),
(1, 3, '2023-10-01', '2023-10-08', '2023-10-08');

-- User 2 pinjam Buku 4, 5, 6 (Tepat Waktu)
INSERT INTO borrowings (user_id, book_id, tanggal_pinjam, tanggal_batas_kembali, tanggal_kembali) VALUES
(2, 4, '2023-10-01', '2023-10-08', '2023-10-08'),
(2, 5, '2023-10-01', '2023-10-08', '2023-10-08'),
(2, 6, '2023-10-01', '2023-10-08', '2023-10-08');

-- User 3 pinjam Buku 7, 8, 9 (1 Buku telat 5 hari)
-- Buku 7 terlambat 5 hari (Misal dari batas tanggal 8, kembali tanggal 13)
INSERT INTO borrowings (user_id, book_id, tanggal_pinjam, tanggal_batas_kembali, tanggal_kembali) VALUES
(3, 7, '2023-10-01', '2023-10-08', '2023-10-13'),  -- Telat 5 hari
(3, 8, '2023-10-01', '2023-10-08', '2023-10-08'),
(3, 9, '2023-10-01', '2023-10-08', '2023-10-08');


-- ==========================================
-- Required Queries
-- ==========================================

-- 2. Tampilkan daftar buku yang tidak pernah dipinjam oleh siapapun
-- Expected Output: Buku 10
SELECT b.judul AS Buku
FROM books b
LEFT JOIN borrowings br ON b.id = br.book_id
WHERE br.id IS NULL;

-- 3. Tampilkan user yang pernah mengembalikan buku terlambat beserta dendanya (Denda = telat hari * Rp1000)
-- Function DATEDIFF mengembalikan selisih hari. (Asumsi format MySQL)
SELECT 
    u.nama AS User,
    CONCAT('Rp', SUM(DATEDIFF(br.tanggal_kembali, br.tanggal_batas_kembali) * 1000)) AS Denda
FROM users u
JOIN borrowings br ON u.id = br.user_id
WHERE br.tanggal_kembali > br.tanggal_batas_kembali
GROUP BY u.id, u.nama;

-- 4. Tampilkan user dengan daftar buku yang dipinjamnya
-- Menggunakan GROUP_CONCAT untuk menggabungkan string judul buku.
SELECT 
    ROW_NUMBER() OVER(ORDER BY u.id) AS No,
    u.nama AS User,
    GROUP_CONCAT(b.judul ORDER BY b.judul DESC SEPARATOR ', ') AS Buku
FROM users u
JOIN borrowings br ON u.id = br.user_id
JOIN books b ON br.book_id = b.id
GROUP BY u.id, u.nama
ORDER BY No;
