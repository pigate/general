//connect from c#

using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;

SqlConnection connection = new SqlConnection("Data Source=localhost\\sqlexpress" + 
                  "user=testmimi; password='1234'; database='Test'; connection timeout = 5");
				  
				  https://msdn.microsoft.com/en-us/library/system.diagnostics.process.aspx
				  https://msdn.microsoft.com/en-us/library/windows/desktop/aa365574(v=vs.85).aspx
				  http://stackoverflow.com/questions/18437474/inter-process-communication-options  wcf pipes
				  
				  named pipes
				  https://msdn.microsoft.com/en-us/library/bb546085(v=vs.110).aspx
				  pipes in .NET
				  https://msdn.microsoft.com/en-us/library/bb762927(v=vs.110).aspx
				  
				  
				  
				  C# sql stored procedure
				  http://stackoverflow.com/questions/1260952/how-to-execute-a-stored-procedure-within-c-sharp-program
				  return value
				  http://stackoverflow.com/questions/706361/getting-return-value-from-stored-procedure-in-c-sharp
				  getting output value
				  https://msdn.microsoft.com/en-us/library/40959t6x%28v=vs.110%29.aspx
				  
				  
				  CREATE PROCEDURE GetCarInfo
@CarId INT,  
@CarModel varchar(50) OUTPUT,
@CarMake varchar(50) OUTPUT
AS
BEGIN
DECLARE @CarYear SMALLINT

SELECT @CarModel = Model, @CarMake = Make, @CarYear = CarYear
FROM Cars
WHERE CarID = @CarId

return @CarYear
END