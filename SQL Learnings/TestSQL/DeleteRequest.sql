USE EFTest;

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'DeleteRequest')
BEGIN
DROP PROCEDURE DeleteRequest
PRINT 'DROPPED PROCEDURE: DeleteRequest'
END
GO

CREATE PROCEDURE DeleteRequest
  @ReqID varchar(50),
  @Option_FromAlloc int, --if == 0, from UnallocatedRequest Table, else from AllocatedRequest Table
  @ErrorMessage varchar(MAX) OUTPUT,
  @Status int OUTPUT
AS
BEGIN
  BEGIN TRAN tx
  BEGIN TRY
    If (@Option_FromAlloc = 0)
	  DELETE FROM UnallocatedRequest WHERE ReqID = @ReqID
	ELSE 
	  DELETE FROM AllocatedRequest WHERE ReqID = @ReqID
	  
    COMMIT TRAN tx	
	SET @Status = 1
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN tx
    SET @Status = 0
	If (@Option_FromAlloc = 0)
	  SET @ErrorMessage = 'Cannot Delete UnallocatedRequest with ReqID' + @ReqID + '. ' + ERROR_MESSAGE()
	ELSE
	  SET @ErrorMessage = 'Cannot Delete AllocatedRequest with ReqID' + @ReqID + '. ' + ERROR_MESSAGE()
  END CATCH
END
RETURN
GO