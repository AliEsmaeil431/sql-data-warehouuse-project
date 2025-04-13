use master;
go

-- Drop and recreate the database "DWH"
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DWH')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO


-- create database "DWH"
create database DWH;

use DWH;
go

-- create schema
create schema bronze;
go
create schema silver;
go
create schema gold;
go
