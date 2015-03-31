IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'BirthRequest')
BEGIN
DROP PROCEDURE BirthRequest
PRINT 'DROPPED PROCEDURE: BirthRequest'
END
GO

CREATE PROCEDURE BirthRequest
  @ReqID varchar(50),
  @Option_FromAlloc int, --if == 0, from UnallocatedRequest Table, else from AllocatedRequest Table
  @NewReqID varchar(50) OUTPUT,
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

  BEGIN TRAN tx
  BEGIN TRY
    If (@Option_FromAlloc = 0)
	BEGIN
	    SELECT @S = S, @E = E, @RequestTime = RequestTime, @EventID = EventID, @UserID = UserID, @NumRGID = NumRGID, @MinTotalArea = MinTotalArea, 
	      @MinAreaBiggestRoom = MinAreaBiggestRoom, @IsHardRequest = IsHardRequest, @CanIWalkThrough = CanIWalkThrough, @MaxBudget = MaxBudget
	    FROM UnallocatedRequest 
	    WHERE ReqID = @ReqID
	END
	ELSE 
	BEGIN
	    SELECT @S = S, @E = E, @RequestTime = RequestTime, @EventID = EventID, @UserID = UserID, @NumRGID = NumRGID, @MinTotalArea = MinTotalArea, 
	      @MinAreaBiggestRoom = MinAreaBiggestRoom, @IsHardRequest = IsHardRequest, @CanIWalkThrough = CanIWalkThrough, @MaxBudget = MaxBudget
	    FROM AllocatedRequest 
	    WHERE ReqID = @ReqID
	END

	IF @S IS NULL --check some field which cannot be null if row was successfully fetched.
	BEGIN 
      IF @Option_FromAlloc = 0
	    SET @ErrorMessage = 'No UnallocatedRequest exists for given ReqID: ' + @ReqID + '. '
	  ELSE
	    SET @ErrorMessage = 'No AllocatedRequest exists for given ReqID: ' + @ReqID + '. '

	  SET @Status = 0; --Fail.
	  THROW 51000, 'Either bad table or bad ReqID', 1;
	END

	IF @Option_FromAlloc = 0
	BEGIN
	  INSERT INTO AllocatedRequest (S, E, RequestTime, EventID, UserID, NumRGID, MinTotalArea, MinAreaBiggestRoom, IsHardRequest, CanIWalkThrough, MaxBudget)
	  OUTPUT INSERTED.ReqID INTO @ID
	  VALUES (@S, @E, @RequestTime, @EventID, @UserID, @NumRGID, @MinTotalArea, @MinAreaBiggestRoom, @IsHardRequest, @CanIWalkThrough, @MaxBudget) 
	END
    ELSE
	BEGIN
	  INSERT INTO AllocatedRequest (S, E, RequestTime, EventID, UserID, NumRGID, MinTotalArea, MinAreaBiggestRoom, IsHardRequest, CanIWalkThrough, MaxBudget, RefReqID, Why)
	  OUTPUT INSERTED.ReqID INTO @ID
	  VALUES (@S, @E, @RequestTime, @EventID, @UserID, @NumRGID, @MinTotalArea, @MinAreaBiggestRoom, @IsHardRequest, @CanIWalkThrough, @MaxBudget, @ReqID, 1) 
	END
    
  
    SELECT  TOP 1 @NewReqID = ID FROM @ID
	SET @Status = 1

    COMMIT TRAN tx
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN tx
	  --did not insert
	SET @ErrorMessage = @ErrorMessage + 'AllocatedRequest Table failed to insert. ' + ERROR_MESSAGE()
	SET @Status = 0
  END CATCH
END
RETURN
