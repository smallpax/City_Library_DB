-- 1. Book
CREATE TABLE Book (
  BookID           SERIAL     PRIMARY KEY,
  Title            VARCHAR(255) NOT NULL,
  ISBN             VARCHAR(20)  UNIQUE NOT NULL,
  PublicationYear  INTEGER      NOT NULL,
  TotalCopies      INTEGER      NOT NULL CHECK (TotalCopies >= 0)
  -- AvailableCopies derived, see view below
);

-- 2. Author
CREATE TABLE Author (
  AuthorID   SERIAL   PRIMARY KEY,
  FirstName  VARCHAR(100) NOT NULL,
  LastName   VARCHAR(100) NOT NULL,
);

-- 3. Genre
CREATE TABLE Genre (
  GenreID  SERIAL   PRIMARY KEY,
  Name     VARCHAR(100) UNIQUE NOT NULL
);

-- 4. Publisher
CREATE TABLE Publisher (
  PublisherID  SERIAL   PRIMARY KEY,
  Name         VARCHAR(255) NOT NULL,
  Address      TEXT,
);

-- 5. Member
CREATE TABLE Member (
  MemberID          SERIAL      PRIMARY KEY,
  FirstName         VARCHAR(100) NOT NULL,
  LastName          VARCHAR(100) NOT NULL,
  Email             VARCHAR(255) UNIQUE NOT NULL,
  Address           TEXT,
  MembershipDate    DATE        NOT NULL,
  Status            VARCHAR(20) NOT NULL
  -- MembershipDuration derived
);

-- 6. Librarian
CREATE TABLE Librarian (
  LibrarianID   SERIAL      PRIMARY KEY,
  Username      VARCHAR(50) UNIQUE NOT NULL,
  PasswordHash  VARCHAR(255) NOT NULL,
  FirstName     VARCHAR(100) NOT NULL,
  LastName      VARCHAR(100) NOT NULL,
  Role          VARCHAR(20) NOT NULL
);

-- 7. BookCopy (weak, identifies to Book)
CREATE TABLE BookCopy (
  CopyID     SERIAL    PRIMARY KEY,
  BookID     INTEGER   NOT NULL REFERENCES Book(BookID),
  Barcode    VARCHAR(50) UNIQUE NOT NULL,
  Status     VARCHAR(20) NOT NULL
);

-- 8. Loan (weak, identifies to Member & BookCopy)
CREATE TABLE Loan (
  LoanID      SERIAL     PRIMARY KEY,
  MemberID    INTEGER    NOT NULL REFERENCES Member(MemberID),
  CopyID      INTEGER    NOT NULL REFERENCES BookCopy(CopyID),
  LoanDate    DATE       NOT NULL,
  DueDate     DATE       NOT NULL,
  ReturnDate  DATE,
  -- OverdueDays derived
  CONSTRAINT chk_dates CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate)
);

-- 9. Reservation (weak, identifies to Member & Book)
CREATE TABLE Reservation (
  ReservationID   SERIAL     PRIMARY KEY,
  MemberID        INTEGER    NOT NULL REFERENCES Member(MemberID),
  BookID          INTEGER    NOT NULL REFERENCES Book(BookID),
  ReservationDate DATE       NOT NULL,
  Status          VARCHAR(20) NOT NULL
);

-- 10. Fine (weak, identifies to Loan)
CREATE TABLE Fine (
  FineID    SERIAL     PRIMARY KEY,
  LoanID    INTEGER    NOT NULL REFERENCES Loan(LoanID),
  Amount    DECIMAL(8,2) NOT NULL,
  PaidDate  DATE
);

-- 11. BookAuthor (associative M:N)
CREATE TABLE BookAuthor (
  BookID    INTEGER    NOT NULL REFERENCES Book(BookID),
  AuthorID  INTEGER    NOT NULL REFERENCES Author(AuthorID),
  PRIMARY KEY (BookID, AuthorID)
);

-- 12. BookGenre (associative M:N)
CREATE TABLE BookGenre (
  BookID   INTEGER    NOT NULL REFERENCES Book(BookID),
  GenreID  INTEGER    NOT NULL REFERENCES Genre(GenreID),
  PRIMARY KEY (BookID, GenreID)
);

-- Derived attribute example: a view for AvailableCopies
CREATE VIEW BookAvailability AS
SELECT
  b.BookID,
  b.TotalCopies - COUNT(l.LoanID) FILTER (WHERE l.ReturnDate IS NULL) AS AvailableCopies
FROM Book b
LEFT JOIN BookCopy bc ON bc.BookID = b.BookID
LEFT JOIN Loan l ON l.CopyID = bc.CopyID
GROUP BY b.BookID, b.TotalCopies;