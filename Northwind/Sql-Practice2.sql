/*Using Dafesty database*/


--1)
CREATE TABLE MemberCategories
(
MemberCategory nvarchar(2) NOT NULL,
MemberCatDescription nvarchar(200) NOT NULL
PRIMARY KEY(MemberCategory)
)


--2)
INSERT INTO MemberCategories (MemberCategory, MemberCatDescription)
VALUES('A','Class A Members') 
INSERT INTO MemberCategories (MemberCategory, MemberCatDescription)
VALUES('B','Class B Members') 
INSERT INTO MemberCategories (MemberCategory, MemberCatDescription)
VALUES('C','Class C Members') 


--3) UNDS how to assign primary and foreign key!!!!!!!!!!
--Primary key assign it in 2). Then we link that primary key to the
--targeted foreign key from this new table.
CREATE TABLE GoodCustomers1
(
CustomerName nvarchar(50) NOT NULL,
Address nvarchar(65),
PhoneNumber nvarchar(9) NOT NULL,
MemberCategory nvarchar(2),
PRIMARY KEY(CustomerName, PhoneNumber),
FOREIGN KEY(MemberCategory) REFERENCES MemberCategories(MemberCategory)
)


--4) DAMN IMPT, Use INSERT-INTO-SELECT to copy paste entire cols into your new table
INSERT INTO GoodCustomers1(CustomerName, PhoneNumber, MemberCategory)
SELECT CustomerName, PhoneNumber, MemberCategory FROM Customers
WHERE MemberCategory = 'A' or MemberCategory = 'B'
--Or by using this:    WHERE MemberCategory in ('A','B')


--5) Inserting a new row into your newly created table
INSERT INTO GoodCustomers1(CustomerName, PhoneNumber, MemberCategory)
VALUES('Tracy Tan', 736572, 'B')


--6) Inserting a new row into your newly created table
INSERT INTO GoodCustomers1
VALUES('Grace Leong', '15 Bukit Purmei Road, Singapore 0904', 278865, 'A')


--7) Meant to get an error cos MemberCategory cannot be anything but A or B
-- violation of referential integrity
INSERT INTO GoodCustomers1
VALUES('Lynn Lim', '15 Bukit Purmei Road Singapore 0904', 278865, 'P')


--8) Updating(changing) a simple data in your table
UPDATE GoodCustomers1
SET Address = '22 Bukit Purmei Road, Singapore 0904'
WHERE CustomerName = 'Grace Leong'


--9) Finding specific customer by referring to another table and changing its value
UPDATE GoodCustomers1
SET MemberCategory = 'B'
WHERE CustomerName =  (SELECT CustomerName FROM Customers WHERE CustomerID = 5108)


--10) Deleting a single column
DELETE FROM GoodCustomers1
WHERE CustomerName = 'Grace Leong'


--11) Deleting based on condition so anything with that condition will be deleted.
DELETE FROM GoodCustomers1
WHERE MemberCategory = 'B'


--12) Adding a new column to the table
ALTER TABLE GoodCustomers1
ADD FaxNumber nvarchar(25)


--13) Modifying the datatype of a specific column. USEFUL!!!
ALTER TABLE GoodCustomers1
ALTER COLUMN Address nvarchar(80)


--14) Adding another column
ALTER TABLE GoodCustomers1
ADD ICNumber nvarchar(10)


--15) UNDS format of creating an index
--However both 15 and 16 cannot be ran cos as there are duplicate values in the 
--column ICNumber (null value in all columns)
CREATE INDEX ICINDEX
	ON GoodCustomers1(ICNumber)
--16)
CREATE INDEX FAXIndex
	ON GoodCustomers1(FaxNumber)

	--BONUS: This one below works cos PhoneNumber has values in it.
	CREATE INDEX PHIndex
	    ON GoodCustomers1(PhoneNumber)
		--Note: The way you retrieve info using index is pretty straightforward. Just use SELECT
		Select * from GoodCustomers1 where PhoneNumber = 7333100
			--It will easily retrieve all the desired info. VERY FAST AND EFFICIENT WAY    [GREAT]


--17) Since fax cant work, we use PHIndex. UNDS HOW TO DROP INDEX. MUST KNOW!!!
DROP INDEX GoodCustomers1.PHIndex


--18) Removing a column from your table. MUST KNOW!!!
ALTER TABLE GoodCustomers1
DROP COLUMN FaxNumber


--19) This deletes all rows and values within a table, without destroying the table.
--You will have just an empty table with headers.
DELETE FROM GoodCustomers1


--20) Dropping (deleting) an entire table.
DROP TABLE GoodCustomers1


	
--Use to check
SELECT * FROM GoodCustomers1

SELECT * FROM Customers 
