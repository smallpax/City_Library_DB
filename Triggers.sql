-- 1) When a loan is created, mark that copy as “on loan”
CREATE OR REPLACE FUNCTION fn_mark_copy_on_loan()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE BookCopy
    SET Status = 'on loan'
    WHERE CopyID = NEW.CopyID;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_loan_insert
  AFTER INSERT ON Loan
  FOR EACH ROW
  EXECUTE FUNCTION fn_mark_copy_on_loan();
  
-- 2) When a loan is returned (ReturnDate set), mark that copy “available”
CREATE OR REPLACE FUNCTION fn_mark_copy_on_return()
RETURNS TRIGGER AS $$
BEGIN
  -- only fire if ReturnDate just went from NULL → non-NULL
  IF NEW.ReturnDate IS NOT NULL AND OLD.ReturnDate IS NULL THEN
    UPDATE BookCopy
      SET Status = 'available'
      WHERE CopyID = NEW.CopyID;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_loan_update
  AFTER UPDATE OF ReturnDate ON Loan
  FOR EACH ROW
  WHEN (NEW.ReturnDate IS NOT NULL AND OLD.ReturnDate IS NULL)
  EXECUTE FUNCTION fn_mark_copy_on_return();
