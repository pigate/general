IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ArchiveRequest')
BEGIN
DROP PROCEDURE ArchiveRequest
PRINT 'DROPPED PROCEDURE: ArchiveRequest'
END
GO

CREATE PROCEDURE ArchiveRequest
  @ReqID varchar(50),
  @Followed bit,
  @NextReqID varchar(50),
  @Why int,
  @Option_FromAlloc int, --if == 0, from UnallocatedRequest Table, else from AllocatedRequest Table
  @ErrorMessage varchar(MAX) OUTPUT,
  @Status int OUTPUT
AS
BEGIN
  DECLARE @ID table(id varchar(50))
  DECLARE @S datetime
  DECLARE @E datetime
  DECLARE @RequestTime datetime
  DECLARE @EventID varchar(50)
  DECLARE @UserID varchar(50)

  --DECLARE @UnallocReqID varchar(50)
  DECLARE @NumRGID varchar(50)
  DECLARE @MinTotalArea int
  DECLARE @MinAreaBiggestRoom int
  DECLARE @IsHardRequest bit
  DECLARE @CanIWalkThrough bit
  DECLARE @MaxBudget decimal
  DECLARE @RefReqID varchar(50)

  --@Followed param
  --@Why param
  --@NextReqID param
  
  IF (@Option_FromAlloc = 0)
	BEGIN
	    SELECT @S = S, @E = E, @RequestTime = RequestTime, @EventID = EventID, @UserID = UserID, @NumRGID = NumRGID, @MinTotalArea = MinTotalArea, 
	      @MinAreaBiggestRoom = MinAreaBiggestRoom, @IsHardRequest = IsHardRequest, @CanIWalkThrough = CanIWalkThrough, @MaxBudget = MaxBudget
	    FROM UnallocatedRequest 
	    WHERE ReqID = @ReqID
	END
	ELSE 
	BEGIN
	    SELECT @S = S, @E = E, @RequestTime = RequestTime, @EventID = EventID, @UserID = UserID, @NumRGID = NumRGID, @MinTotalArea = MinTotalArea, 
	      @MinAreaBiggestRoom = MinAreaBiggestRoom, @IsHardRequest = IsHardRequest, @CanIWalkThrough = CanIWalkThrough, @MaxBudget = MaxBudget,
		  @RefReqID = RefReqID
	    FROM AllocatedRequest 
	    WHERE ReqID = @ReqID
	END
	
  BEGIN TRAN tx
  BEGIN TRY
 	IF @S IS NULL --check some field which cannot be null if row was successfully fetched.
	BEGIN 
      IF @Option_FromAlloc = 0
	    SET @ErrorMessage = 'No UnallocatedRequest exists for given ReqID: ' + @ReqID + '. '
	  ELSE
	    SET @ErrorMessage = 'No AllocatedRequest exists for given ReqID: ' + @ReqID + '. '

	  SET @Status = 0; --Fail.
	  THROW 51000, 'Either bad table or bad ReqID', 1;
	END 


	INSERT INTO ArchivedRequest (ReqID, S, E, RequestTime, EventID, UserID, NumRGID, 
	  MinTotalArea, MinAreaBiggestRoom, IsHardRequest, CanIWalkThrough, MaxBudget, 
	  Followed, Why, RefReqID, NextReqID)
	  OUTPUT INSERTED.ReqID INTO @ID
	  VALUES (@ReqID, @S, @E, @RequestTime, @EventID, @UserID, @NumRGID, 
	  @MinTotalArea, @MinAreaBiggestRoom, @IsHardRequest, @CanIWalkThrough, @MaxBudget,
	  @Followed, @Why, @RefReqID, @NextReqID) 
	  
    COMMIT TRAN tx
	SET @Status = 1
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN tx
	SET @ErrorMessage = 'Failed to archive request:' + ERROR_MESSAGE()
    SET @Status = 0
  END CATCH
END
RETURN
GO