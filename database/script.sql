CREATE TABLE item (
id INT(8) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(300) NOT NULL,
description VARCHAR(3000) NOT NULL,
includes VARCHAR(300) NOT NULL,
intended VARCHAR(300) NOT NULL,
color VARCHAR(300) NOT NULL,
material VARCHAR(300) NOT NULL,
url VARCHAR(3000) NOT NULL,
price DECIMAL(12, 2) NOT NULL);

INSERT INTO item (title,description,includes,intended,color,material,url,price) VALUES ("2Top Paw Valentine's Day Single Dog Sweater","Top Paw Valentine's Day Single Dog Sweater is a cute and cozy way to show your dog some love this Valentine's Day. This sweater features a red heart on the back and a red bow on the front. It's made of soft, comfortable cotton and polyester blend fabric. It's machine washable for easy care. This sweater is available in sizes XS, S, M, L, XL and XXL...","1 Sweater","Dogs","Red, White, Black","100% Acrylic","https://www.pedigree.com/sites/g/files/fnmzdf1201/files/2022-09/PED-dog-age-NicoTwix-600.png",14.99);
INSERT INTO item (title,description,includes,intended,color,material,url,price) VALUES  ("2Arcadia Trail Dog Windbreaker","The right jacket for your pet while the two of you are out on the trail together can make all the difference when it comes to both warmth and comfort. This Arcadia Trail Windbreaker zippers shut, features a packable hood, has an opening for a leash, and even comes with a waste bag dispenser and waste bags. Comfortable and versatile, this unique jacket makes a great choice for the outdoor adventures you share with your pup","1 Windbreaker Jacket","Dogs","Available in Pink or Navy","No material","https://th-thumbnailer.cdn-si-edu.com/C4MIxDa_YxisZm2EtoTNHweBKZU=/fit-in/1600x0/filters:focal(3126x2084:3127x2085)/https://tf-cmsv2-smithsonianmag-media.s3.amazonaws.com/filer_public/ec/e6/ece69181-708a-496e-b2b7-eaf7078b99e0/gettyimages-1310156391.jpg",29.99);
INSERT INTO item (title,description,includes,intended,color,material,url,price) VALUES  ("2Top Paw Valentine's Day Kisses Dog Tee and Bandana","Dress your pup up appropriately for Valentine's Day with this Top Paw Valentine's Day Kisses Dog Tee and Bandana. This tee and bandana slip on and off easily while offering a comfortable fit, and offers kisses from your favorite furry friend","1 Tee and Bandana","Dogs","White, Red, Black","T-Shirt: 65% Polyester, 35% Cotton; Bandana: 100% Cotton","https://hips.hearstapps.com/hmg-prod/images/wolf-dog-breeds-siberian-husky-1570411330.jpg",7.47);


CREATE TABLE follow (
id INT(8) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
item_id INT(8) NOT NULL,
user_id VARCHAR(300) NOT NULL);

CREATE TABLE orders (
id INT(8) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
user_id VARCHAR(300) NOT NULL,
shipping DECIMAL(12, 2) NOT NULL,
tax DECIMAL(12, 2) NOT NULL,
card_name VARCHAR(300) NOT NULL,
card_number VARCHAR(20) NOT NULL,
card_date VARCHAR(6) NOT NULL,
card_cvv VARCHAR(3) NOT NULL,
date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);


CREATE TABLE orders_item (
id INT(8) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
order_id INT(8) NOT NULL,
item_id INT(8) NOT NULL,
quantity int(3) NOT NULL,
price DECIMAL(12, 2) NOT NULL);
