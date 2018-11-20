--============================--
---------- MEDIA TYPE ----------
--============================--
DROP TABLE IF EXISTS media_type;
CREATE TABLE media_type (
  mediaTypeID integer not null primary key autoincrement,
  mediaName text not null
);

INSERT INTO media_type (mediaName)
SELECT DISTINCT MediaType
FROM hw5_original;


--===========================--
------------ GENRE ------------
--===========================--
DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
  genreID integer primary key autoincrement,
  name text not null
);

INSERT INTO genre (name)
SELECT DISTINCT Genre
FROM hw5_original;


--============================--
------------ ARTIST ------------
--============================--
DROP TABLE IF EXISTS artist;
CREATE TABLE artist (
  artistID integer primary key autoincrement,
  artistName text not null unique
);

INSERT INTO artist (artistName)
SELECT DISTINCT ArtistName
FROM hw5_original;


--===========================--
------------ ALBUM ------------
--===========================--
DROP TABLE IF EXISTS album;
CREATE TABLE album (
  albumID integer primary key autoincrement,
  albumTitle text not null,
  artistID integer not null references artist (artistID)
);

INSERT INTO album (albumTitle, artistID)
SELECT AlbumTitle, artistID
FROM hw5_original o
JOIN artist ON o.artistName = artist.artistName
GROUP BY o.AlbumTitle;


--===========================--
------------ TRACK ------------
--===========================--
DROP TABLE IF EXISTS track;
CREATE TABLE track (
  trackID integer primary key autoincrement,
  trackName text not null,
  composer text,
  trackSizeBytes integer,
  trackLength integer not null,
  trackPrice real not null,
  genreID integer not null references genre (genreID),
  mediaTypeID integer not null references media_type (mediaTypeID),
  albumID integer references album (albumID),
  UNIQUE (trackName, trackLength)
);

INSERT INTO track (trackName, composer, trackSizeBytes, trackLength, trackPrice, genreID, mediaTypeID, albumID)
SELECT o.TrackName, o.Composer, o.TrackSizeBytes, o.TrackLength, o.TrackPrice, g.genreID, m.mediaTypeID, a.albumID
FROM hw5_original o
JOIN genre g ON g.name = o.Genre
JOIN media_type m ON m.mediaName = o.MediaType
JOIN album a ON a.albumTitle = o.AlbumTitle
GROUP BY TrackName, TrackLength;


--============================--
----------- CUSTOMER -----------
--============================--
DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
  customerID integer primary key autoincrement,
  firstName text not null,
  lastName text not null unique,
  address text,
  city text,
  state text,
  country text,
  postalCode integer,
  phoneNumber integer,
  faxNumber integer,
  email text not null
);

INSERT INTO customer (firstName, lastName, address, city, state, country, postalCode, phoneNumber, faxNumber, email)
SELECT CustomerFirstName, CustomerLastName, CustomerAddress, CustomerCity, CustomerState,
       CustomerCity, CustomerPostalCode, CustomerPhone, CustomerFax, CustomerEmail
FROM hw5_original
GROUP BY CustomerEmail
HAVING CustomerFirstName NOT NULL;


--=============================--
------------ INVOICE ------------
--=============================--
DROP TABLE IF EXISTS invoice;
CREATE TABLE invoice (
  invoiceID integer primary key autoincrement,
  date date not null default current_date,
  billingAddress text,
  billingCity text,
  billingState text,
  billingCountry text,
  billingPostalCode integer,
  customerID integer not null references customer (customerID)
);

INSERT INTO invoice
SELECT InvoiceId, InvoiceDate, InvoiceBillingAddress, InvoiceBillingCity, InvoiceBillingState, InvoiceBillingCountry, InvoiceBillingPostalCode, c.customerID
FROM hw5_original o
JOIN customer c ON c.lastName = o.CustomerLastName
GROUP BY InvoiceId;


--============================--
--------- INVOICE_ITEM ---------
--============================--
DROP TABLE IF EXISTS invoice_item;
CREATE TABLE invoice_item (
  invoiceItemID integer primary key autoincrement,
  invoiceID integer not null references invoice (invoiceID),
  trackID integer not null references track (trackID),
  quantity integer not null,
  unitPrice numeric not null
);

INSERT INTO invoice_item (invoiceID, trackID, quantity, unitPrice)
SELECT o.InvoiceId, t.trackID, o.InvoiceItemQuantity, o.InvoiceItemUnitPrice
FROM hw5_original o
JOIN track t ON (t.trackName, t.trackLength) = (o.TrackName, o.TrackLength)
WHERE o.InvoiceId NOT NULL
ORDER BY o.TrackName;
