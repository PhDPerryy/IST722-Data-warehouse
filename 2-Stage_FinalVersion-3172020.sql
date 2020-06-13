----------------------------------------------------------------------
-- THIS SCRIPT DOES STAGE AND DATA LOAD
----------------------------------------------------------------------

--Run 2nd

---------------------------------
-- Setting up the dynamic db name
---------------------------------

--Make sure using the corect database
--USE ist722_grblock_oa2_stage;
--USE ist722_grblock_oa2_stage;

USE  ist722_grblock_oa2_stage;

GO

/*Dropping staged tables in order to re-create them*/

/* Drop table  stgFudgemartSales*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'stgFudgemartSales') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE stgFudgemartSales;

/* Drop table  stgFudgemartInventory*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'stgFudgemartInventory') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE stgFudgemartInventory;

/* Drop table stgFudgemartOrder*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'stgFudgemartOrders') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE stgFudgemartOrders;

/* Drop table stgFudgemartProducts*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'stgFudgemartProducts') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE stgFudgemartProducts;

/*Drop table  stgFudgemartDates*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'stgFudgemartDates') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE stgFudgemartDates;

/* Drop table stgFudgemartTitle*/
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'stgFudgemartTitles') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE stgFudgemartTitles;



/*End of deleteing tables*/


----------------------------------------------------------------------
--BEGIN CREATING TABLES
----------------------------------------------------------------------

PRINT 'Start Table Creation'

/*Creating  stgFudgemartOrders*/
SELECT [order_id],
       [customer_id],
       [order_date],
       [shipped_date]
  INTO [dbo].[stgFudgemartOrders]
  FROM [fudgemart_v3].[dbo].[fm_orders]
  ;

/*Creating  stgFudgemartProducts*/
SELECT [product_id],
       [product_name],
       [product_retail_price],
       [product_is_active]
  INTO [dbo].[stgFudgemartProducts]
  FROM [fudgemart_v3].[dbo].[fm_products]
;


/*Creating  stgFudgemartDates*/
SELECT [DateKey],
	   [Date], 
	   [FullDateUSA], 
	   [DayOfWeekUSA], 
	   [DayName], 
	   [DayOfMonth], 
	   [DayOfYear], 
	   [WeekOfYear], 
	   [MonthName], 
	   [MonthYear], 
	   [Quarter], 
	   [QuarterName],
	   [Year], 
	   [IsWeekday]
INTO [dbo].[stgFudgemartDates]
FROM [ExternalSources2].[dbo].[date_dimension]
/*WHERE Year between 1996 and 1998*/

USE ist722_grblock_oa2_stage;
/* Create table stgFudgemartTitles */
SELECT [title_id],
       [title_name],
       [title_bluray_available],
       [title_dvd_available]
INTO [dbo].[stgFudgemartTitles]
FROM [fudgeflix_v3].[dbo].[ff_titles]
;


/* Create table stgFudgemartSales */
SELECT 
  p.[product_id],
  p.[product_name],
  p.[product_retail_price],
  p.[product_wholesale_price],
  o.[order_id],
  [customer_id],
  [order_date],
  [shipped_date],
  [order_qty]
INTO [dbo].[stgFudgemartSales]
FROM [fudgemart_v3].[dbo].[fm_order_details] d
	join [fudgemart_v3].[dbo].[fm_orders] o
		on o.[order_id] = d.[order_id]
			join [fudgemart_v3].[dbo].[fm_products] p
				on d.[product_id] = p.[product_id]



/*Creating stgFudgemartInventory*/
SELECT [title_id],
       [title_name],
       [title_type],
       [title_bluray_available],
       [title_dvd_available],
       [title_date_modified]
INTO [dbo].[stgFudgemartInventory]
FROM [fudgeflix_v3].[dbo].[ff_titles];



