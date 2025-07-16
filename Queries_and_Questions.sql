
1. --**List all books published after 2010**
   --*Simple SELECT … WHERE*

   SELECT Title, PublicationYear
   FROM Book
   WHERE PublicationYear > 2010;
   
2. --**Find all members whose status is ‘active’**
   --*Simple SELECT … WHERE*

   SELECT FirstName, LastName, Email
   FROM Member
   WHERE Status = 'active';
   
3. --**Show each book’s title alongside its author(s)**
   --*JOIN of two tables*

   SELECT b.Title,
          a.FirstName || ' ' || a.LastName AS AuthorName
   FROM Book b
   JOIN BookAuthor ba ON b.BookID = ba.BookID
   JOIN Author a     ON ba.AuthorID = a.AuthorID;
   
4. --**Retrieve currently on-loan items with member name and due date**
   --*JOIN of three tables*

   SELECT m.FirstName || ' ' || m.LastName AS Member,
          b.Title,
          l.DueDate
   FROM Loan l
   JOIN Member m   ON l.MemberID = m.MemberID
   JOIN BookCopy bc ON l.CopyID   = bc.CopyID
   JOIN Book b     ON bc.BookID   = b.BookID
   WHERE l.ReturnDate IS NULL;
   
5. --**Count the number of books in each genre**
   --*GROUP BY with aggregation*

   SELECT g.Name    AS Genre,
          COUNT(*)  AS BookCount
   FROM Genre g
   JOIN BookGenre bg ON g.GenreID = bg.GenreID
   GROUP BY g.Name;
   
6. --**Find genres that have more than 5 books**
   --*GROUP BY with HAVING*

   SELECT g.Name    AS Genre,
          COUNT(*)  AS BookCount
   FROM Genre g
   JOIN BookGenre bg ON g.GenreID = bg.GenreID
   GROUP BY g.Name
   HAVING COUNT(*) > 5;
   
7. --**List members who have never borrowed a book**
   --*Nested query*

   SELECT FirstName, LastName
   FROM Member
   WHERE MemberID NOT IN (
     SELECT MemberID
     FROM Loan
   );
   
8. --**Find titles of books that have never been loaned**
   --*Nested query*

   
   SELECT Title
   FROM Book
   WHERE BookID NOT IN (
     SELECT bc.BookID
     FROM BookCopy bc
     JOIN Loan l      ON bc.CopyID = l.CopyID
   );

9. --**Check out copy 5 to member 1 (fires the “on loan” trigger)**
   --*Data‐modifying query that fires your AFTER INSERT trigger*

   INSERT INTO Loan (MemberID, CopyID, LoanDate, DueDate)
   VALUES (1, 5, CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days');

   --This will invoke `fn_mark_copy_on_loan()` to set that copy’s status to “on loan.”&#x20;
10. --**Return loan 123 (fires the “on return” trigger)**
    --*Data‐modifying query that fires your AFTER UPDATE trigger*

    UPDATE Loan
    SET ReturnDate = CURRENT_DATE
    WHERE LoanID = 123;
    
    --This will invoke `fn_mark_copy_on_return()` to set the related copy’s status to “available.”&#x20;
11. --**Show total fines incurred by each member**
    --*JOIN + GROUP BY aggregation*

    SELECT m.FirstName || ' ' || m.LastName AS Member,
           SUM(f.Amount)                 AS TotalFines
    FROM Member m
    JOIN Loan l  ON m.MemberID = l.MemberID
    JOIN Fine f  ON l.LoanID   = f.LoanID
    GROUP BY m.FirstName, m.LastName;
    

