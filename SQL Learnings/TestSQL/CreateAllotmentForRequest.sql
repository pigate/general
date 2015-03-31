IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'CreateAllotmentForRequest')
BEGIN
DROP PROCEDURE CreateAllotmentForRequest
PRINT 'DROPPED PROCEDURE: CreateAllotmentForRequest'
END
GO

CREATE PROCEDURE CreateAllotmentForRequest
  @ReqID varchar(50), @HotelID varchar(50), @RGID varchar(50), @ArrangementID varchar(MAX),
  @NewAllotID varchar(50) OUTPUT,
  @ErrorMessage varchar(MAX) OUTPUT,
  @Status int OUTPUT
AS
BEGIN
  DECLARE @ID table(ID varchar(50))
  DECLARE @S datetime
  DECLARE @E datetime  
  
  BEGIN TRAN tx
  BEGIN TRY
    INSERT INTO Allotment(ReqID, HotelID, RGID, ArrangementID)
	OUTPUT INSERTED.AllotID INTO @ID
    VALUES (@ReqID, @HotelID, @RGID, @ArrangementID)
    SELECT TOP 1 @NewAllotID = ID FROM @ID
    SET @Status = 1
	
    COMMIT TRAN tx
	
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN tx
    SET @Status = 0
	SET @ErrorMessage = 'Allotment: Failed to insert. ' + ERROR_MESSAGE()
  END CATCH
END
RETURN
GO
  
