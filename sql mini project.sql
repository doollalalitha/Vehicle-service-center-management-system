CREATE TABLE Customers (
customer_id INT PRIMARY KEY AUTO_INCREMENT,
customer_name VARCHAR(50),
phone VARCHAR(15),
city VARCHAR(30));

INSERT INTO Customers(customer_name,phone,city)
VALUES
('Rahul','9876543210','Chennai'),
('Priya','9876543211','Bangalore'),
('Arun','9876543212','Hyderabad'),
('Sneha','9876543213','Coimbatore'),
('Karthik','9876543214','Mumbai');
select * from Customers;

-- TABLE-2

CREATE TABLE Vehicles (
vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
customer_id INT,
vehicle_number VARCHAR(15),
vehicle_model VARCHAR(50),
vehicle_type VARCHAR(30),
FOREIGN KEY(customer_id)
REFERENCES Customers(customer_id)
);
INSERT INTO Vehicles(customer_id,vehicle_number,vehicle_model,vehicle_type)
VALUES
(1,'TN10AB1234','Hyundai i20','Car'),
(2,'KA05XY5678','Honda City','Car'),
(3,'TS08PQ4321','Royal Enfield','Bike'),
(4,'TN22KL9090','Maruti Swift','Car'),
(5,'MH12AA1111','TVS Apache','Bike');
select * from vehicles;

-- TABLE - 3

CREATE TABLE Mechanics (
mechanic_id INT PRIMARY KEY AUTO_INCREMENT,
mechanic_name VARCHAR(50),
specialization VARCHAR(50),
experience INT
);
INSERT INTO Mechanics(mechanic_name,specialization,experience)
VALUES
('Ramesh','Engine',10),
('Suresh','Electrical',8),
('Mahesh','General Service',6),
('Ganesh','Painting',12);
select * from mechanics;

-- TABLE - 4

CREATE TABLE Service_Records ( service_id INT PRIMARY KEY AUTO_INCREMENT, vehicle_id INT, mechanic_id INT,
service_type VARCHAR(50), service_date DATE, cost DECIMAL(10,2), FOREIGN KEY(vehicle_id)
REFERENCES Vehicles(vehicle_id), FOREIGN KEY(mechanic_id)
REFERENCES Mechanics(mechanic_id));
INSERT INTO Service_Records(vehicle_id,mechanic_id,service_type,service_date,cost)
VALUES
(1,1,'Engine Repair','2026-07-10',8000),
(1,2,'Electrical Repair','2026-07-20',3000),
(2,3,'General Service','2026-07-21',2500),
(3,1,'Engine Repair','2026-07-15',5000),
(4,3,'General Service','2026-07-18',2200),
(5,2,'Electrical Repair','2026-06-30',1800),
(2,4,'Painting','2026-07-25',7000),
(3,3,'General Service','2026-07-27',2000);
SELECT * FROM SERVICE_RECORDS;

-- TABLE- 5

CREATE TABLE Bills ( bill_id INT PRIMARY KEY AUTO_INCREMENT, service_id INT, total_amount DECIMAL(10,2),
payment_status VARCHAR(20), FOREIGN KEY(service_id) REFERENCES Service_Records(service_id));

INSERT INTO Bills(service_id,total_amount,payment_status)
VALUES
(1,8000,'Paid'),
(2,3000,'Paid'),
(3,2500,'Pending'),
(4,5000,'Paid'),
(5,2200,'Paid'),
(6,1800,'Pending'),
(7,7000,'Paid'),
(8,2000,'Pending');
SELECT * FROM BILLS
COMMIT;

-- 1. Display vehicles serviced today.
SELECT vehicle_number, vehicle_model, service_type, service_date FROM Vehicles
JOIN Service_Records ON Vehicles.vehicle_id=Service_Records.vehicle_id WHERE service_date=CURDATE();

-- 2. Find the mechanic handling the most services
SELECT mechanic_name, COUNT(service_id) AS Total_Services FROM Mechanics JOIN Service_Records
ON Mechanics.mechanic_id=Service_Records.mechanic_id GROUP BY mechanic_name ORDER BY Total_Services DESC LIMIT 1;

-- 3. Calculate customer-wise bill amount.
SELECT customer_name, SUM(total_amount) AS Total_Bill FROM Customers JOIN Vehicles 
ON Customers.customer_id=Vehicles.customer_id  JOIN Service_Records ON Vehicles.vehicle_id=Service_Records.vehicle_id
JOIN BillS ON Service_Records.service_id=Bills.service_id GROUP BY customer_name;

-- 4. Find vehicles not serviced in the last year.
SELECT vehicle_number,
vehicle_model
FROM Vehicles
WHERE vehicle_id NOT IN (
SELECT vehicle_id
FROM Service_Records
WHERE service_date>=DATE_SUB(CURDATE(),INTERVAL 1 YEAR)
);

-- 5. Display service history for a vehicle.
SELECT vehicle_number, service_type, service_date, cost FROM Vehicles JOIN Service_Records
ON Vehicles.vehicle_id=Service_Records.vehicle_id WHERE vehicle_number='TN10AB1234'
ORDER BY service_date;

-- 6. Count services by type.

SELECT service_type, COUNT(*) AS Total FROM Service_Records GROUP BY service_type;

-- 7. Find customers with more than three visits.

SELECT customer_name, COUNT(service_id) AS Visits FROM Customers JOIN Vehicles
ON Customers.customer_id=Vehicles.customer_id JOIN Service_Records
ON Vehicles.vehicle_id=Service_Records.vehicle_id GROUP BY customer_name HAVING COUNT(service_id)>3;


-- 8. Display pending payments.

SELECT customer_name, vehicle_number, total_amount FROM Customers JOIN Vehicles
ON Customers.customer_id=Vehicles.customer_id JOIN Service_Records
ON Vehicles.vehicle_id=Service_Records.vehicle_id JOIN Bills
ON Service_Records.service_id=Bills.service_id WHERE payment_status='Pending';

-- 9. Find the most common service.

SELECT service_type, COUNT(*) AS Frequency FROM Service_Records GROUP BY service_type
ORDER BY Frequency DESC LIMIT 1;

-- 10. Calculate monthly service revenue.

SELECT MONTH(service_date) AS Month, SUM(total_amount) AS Revenue FROM Service_Records
JOIN Bills ON Service_Records.service_id=Bills.service_id GROUP BY MONTH(service_date);

-- 11. Find the highest bill.

SELECT * FROM Bills ORDER BY total_amount DESC LIMIT 1;

-- 12. Find the mechanic with the highest revenue.

SELECT mechanic_name, SUM(total_amount) AS Revenue FROM Mechanics JOIN Service_Records
ON Mechanics.mechanic_id=Service_Records.mechanic_id JOIN Bills ON Service_Records.service_id=Bills.service_id
GROUP BY mechanic_name ORDER BY Revenue DESC;

-- 13. Display customers who own more than one vehicle.

SELECT customer_name, COUNT(vehicle_id) AS Vehicles
FROM Customers JOIN Vehicles ON Customers.customer_id=Vehicles.customer_id
GROUP BY customer_name HAVING COUNT(vehicle_id)>1;

-- 14. Find the average service cost.

SELECT AVG(cost) AS Average_Cost FROM Service_Records;

-- 15. Find the most experienced mechanic.

SELECT * FROM Mechanics ORDER BY experience DESC LIMIT 1;

-- 16. Display all engine repairs.

SELECT *FROM Service_Records WHERE service_type='Engine Repair';

-- 17. Find customers from Chennai.

SELECT * FROM Customers WHERE city='Chennai';

-- 18. Find all services performed by a particular mechanic.
SELECT mechanic_name, service_type, service_date FROM Mechanics JOIN Service_Records
ON Mechanics.mechanic_id=Service_Records.mechanic_id WHERE mechanic_name='Ramesh';

-- 19. Display unpaid bill details with service information.

SELECT bill_id, customer_name, vehicle_number, service_type, service_date, total_amount FROM Bills
JOIN Service_Records ON Bills.service_id=Service_Records.service_id JOIN Vehicles
ON Service_Records.vehicle_id=Vehicles.vehicle_id JOIN Customers ON Vehicles.customer_id=Customers.customer_id
WHERE payment_status='Pending';

-- 20. Rank mechanics based on the number of services handled.
SELECT mechanic_name, COUNT(service_id) AS Total_Services, RANK() OVER(ORDER BY COUNT(service_id) DESC) AS Service_Rank

FROM Mechanics LEFT

JOIN Service_Records ON Mechanics.mechanic_id=Service_Re cords.mechanic_id

GROUP BY mechanic_name;