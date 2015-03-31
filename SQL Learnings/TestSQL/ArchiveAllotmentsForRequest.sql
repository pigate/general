IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ArchiveAllotmentsForRequest')
BEGIN
DROP PROCEDURE ArchiveAllotmentForRequest
PRINT 'DROPPED PROCEDURE: ArchiveAllotmentsForRequest'
END
GO

CREATE PROCEDURE ArchiveAllotmentsForRequest
  @ReqID varchar(50),
  @Why int,
  @ErrorMessage varchar(MAX) OUTPUT,
  @Status int OUTPUT
AS
BEGIN
  DECLARE @ALLOT table(ID int identity(1, 1), AllotID varchar(50), HotelID varchar(50), RGID varchar(50), ReqID varchar(50), ArrangementID varchar(50))
  
  INSERT INTO @ALLOT
  SELECT AllotID, HotelID, RGID, ReqID, ArrangementID 
  FROM Allotment
  WHERE ReqID = @ReqID
  
  DECLARE @minID int
  SET @minID = (SELECT min(ID) FROM @ALLOT)

  DECLARE @AllotID varchar(50)
  DECLARE @HotelID varchar(50)
  DECLARE @RGID varchar(50)
  DECLARE @ArrangementID varchar(50) 

  BEGIN TRAN tx
  BEGIN TRY
    WHILE @minID IS NOT NULL
    BEGIN
      --Archive the allotment
	  SELECT @AllotID = AllotID, @HotelID = HotelID, @RGID = RGID, @ArrangementID = ArrangementID 
	  FROM @ALLOT WHERE ID = @minID

	  INSERT INTO ArchivedAllotment(AllotID, HotelID, RGID, ReqID, ArrangementID)
	  VALUES(@AllotID, @HotelID, @RGID, @ReqID, @ArrangementID)

	  SELECT @minID = min(ID) FROM @ALLOT WHERE @minID < ID
    END
    COMMIT TRAN tx
	SET @Status = 1
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN tx
    SET @Status = 0
	SET @ErrorMessage = 'Allotment: Failed to insert. ' + ERROR_MESSAGE()
  END CATCH
END
RETURN
GO
  