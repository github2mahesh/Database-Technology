/*Question 2*/

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS airport CASCADE;
DROP TABLE IF EXISTS year CASCADE;
DROP TABLE IF EXISTS week_day CASCADE;
DROP TABLE IF EXISTS weekly_schedule CASCADE;
DROP TABLE IF EXISTS flight_schedule CASCADE;
DROP TABLE IF EXISTS reservation CASCADE;
DROP TABLE IF EXISTS passenger CASCADE;
DROP TABLE IF EXISTS passenger_reservation CASCADE;
DROP TABLE IF EXISTS contact_person CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS payment_details CASCADE;
DROP TABLE IF EXISTS passenger_booking_ticket CASCADE;

SET FOREIGN_KEY_CHECKS=1;

SELECT 'Creating tables' AS 'Message';

CREATE TABLE route
   (route_id INT AUTO_INCREMENT,
   departure_airport VARCHAR(30) NOT NULL,
   arrival_airport VARCHAR(30) NOT NULL,
   Routeprice DOUBLE,
   year INT,
   CONSTRAINT pk_route PRIMARY KEY(route_id)) ENGINE=InnoDB;

CREATE TABLE airport
   (airport_code VARCHAR(3),
   airport_name VARCHAR(30),
   country VARCHAR(30),
   CONSTRAINT pk_airport PRIMARY KEY(airport_code)) ENGINE=InnoDB;

CREATE TABLE year
   (year INT,
   profit_factor DOUBLE,
   CONSTRAINT pk_year PRIMARY KEY(year)) ENGINE=InnoDB;

CREATE TABLE week_day
   (week_day VARCHAR(30),
   wk_day_factor DOUBLE,
   year INT NOT NULL,
   CONSTRAINT fk_year FOREIGN KEY (year) REFERENCES year(year),
   CONSTRAINT pk_week_day PRIMARY KEY(week_day,year)) ENGINE=InnoDB;

CREATE TABLE weekly_schedule
   (wk_sh_id INT AUTO_INCREMENT,
   year INT NOT NULL,
   week_day VARCHAR(10) NOT NULL,
   departure_time TIME,
   route_id INT NOT NULL,
   CONSTRAINT pk_weekly_schedule PRIMARY KEY(wk_sh_id)) ENGINE=InnoDB;

CREATE TABLE flight_schedule
   (flight_schedule_id INT AUTO_INCREMENT,
   week_no INT,
   wk_sh_id INT NOT NULL,
   CONSTRAINT pk_flight_schedule PRIMARY KEY(flight_schedule_id)) ENGINE=InnoDB;

CREATE TABLE reservation
   (res_id INT AUTO_INCREMENT,
   price INT,
   no_passengers INT,
   flight_schedule_id  INT NOT NULL,
   contact_person INT,
   CONSTRAINT pk_reservation PRIMARY KEY(res_id)) ENGINE=InnoDB;

CREATE TABLE passenger
   (passport_no INT,
   name VARCHAR(30),
   CONSTRAINT pk_passenger PRIMARY KEY(passport_no)) ENGINE=InnoDB;

CREATE TABLE passenger_reservation
   (passenger_id INT not NULL,
   res_id INT NOT NULL,
   CONSTRAINT fk_passenger_id FOREIGN KEY (passenger_id) REFERENCES passenger(passport_no),
   CONSTRAINT fk_res_id FOREIGN KEY (res_id) REFERENCES reservation(res_id),
   CONSTRAINT pk_passenger PRIMARY KEY(passenger_id, res_id)) ENGINE=InnoDB;

CREATE TABLE contact_person
   (passport_no INT,
   email VARCHAR(30),
   phone_number BIGINT,
   CONSTRAINT fk_contact_person_id FOREIGN KEY (passport_no) REFERENCES passenger(passport_no),
   CONSTRAINT pk_contact_person PRIMARY KEY(passport_no)) ENGINE=InnoDB;

CREATE TABLE booking
   (booking_id INT AUTO_INCREMENT,
   final_price DOUBLE,
   res_id INT NOT NULL,
   card_number BIGINT NOT NULL,
   CONSTRAINT pk_booking PRIMARY KEY(booking_id)) ENGINE=InnoDB;

CREATE TABLE payment_details
   (card_number BIGINT,
   card_holder VARCHAR(30),
   CONSTRAINT pk_payment_details PRIMARY KEY(card_number)) ENGINE=InnoDB;

CREATE TABLE passenger_booking_ticket
   (booking_id INT NOT NULL,
   passenger_id INT NOT NULL,
   ticket_no INT NOT NULL,
   CONSTRAINT fk_booking_id FOREIGN KEY (booking_id) REFERENCES reservation(res_id),
   CONSTRAINT fk_passenger_booking_ticket_passenger_id FOREIGN KEY (passenger_id) REFERENCES passenger(passport_no),
   CONSTRAINT pk_passenger_booking_ticket PRIMARY KEY(booking_id,passenger_id)) ENGINE=InnoDB;

-- Add foreign keys 
SELECT 'Creating foreign keys' AS 'Message';
ALTER TABLE route ADD CONSTRAINT fk_departure_airport FOREIGN KEY (departure_airport) REFERENCES airport(airport_code);
ALTER TABLE route ADD CONSTRAINT fk_arrival_airport FOREIGN KEY (arrival_airport) REFERENCES airport(airport_code);

ALTER TABLE week_day ADD CONSTRAINT fk_week_day_year FOREIGN KEY (year) REFERENCES year(year);

ALTER TABLE weekly_schedule ADD CONSTRAINT fk_wk_sh_year FOREIGN KEY (year) REFERENCES year(year);
ALTER TABLE weekly_schedule ADD CONSTRAINT fk_week_day FOREIGN KEY (week_day) REFERENCES week_day(week_day);
ALTER TABLE weekly_schedule ADD CONSTRAINT fk_route_id FOREIGN KEY (route_id) REFERENCES route(route_id);

ALTER TABLE flight_schedule ADD CONSTRAINT fk_wk_sh_id FOREIGN KEY (wk_sh_id) REFERENCES weekly_schedule(wk_sh_id);

ALTER TABLE reservation ADD CONSTRAINT fk_schedule_id FOREIGN KEY (flight_schedule_id) REFERENCES flight_schedule(flight_schedule_id);
ALTER TABLE reservation ADD CONSTRAINT fk_contact_person FOREIGN KEY (contact_person) REFERENCES contact_person(passport_no);

ALTER TABLE contact_person ADD CONSTRAINT fk_passport_no FOREIGN KEY (passport_no) REFERENCES passenger(passport_no);

ALTER TABLE booking ADD CONSTRAINT fk_booking_res_id FOREIGN KEY (res_id) REFERENCES reservation(res_id);
ALTER TABLE booking ADD CONSTRAINT fk_card_number FOREIGN KEY (card_number) REFERENCES payment_details(card_number);

/*Question 3*/

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;

DELIMITER //
CREATE PROCEDURE addYear(IN newYear INT, IN profit_factor DOUBLE)
BEGIN
    INSERT INTO year VALUES(newYear, profit_factor);
END //

CREATE PROCEDURE addDay(IN newYear INT, IN newDay VARCHAR(30), IN factor DOUBLE)
BEGIN
    INSERT INTO week_day VALUES (newDay, factor, newYear);
END //

CREATE PROCEDURE addDestination(IN airportCode VARCHAR(3), 
                                IN airportName VARCHAR(30), 
                                IN country VARCHAR(30))
BEGIN
    INSERT INTO airport  VALUES (airportCode, airportName, country);
END //

CREATE PROCEDURE addRoute(IN departureAirportCode VARCHAR(3), 
                            IN arrivalAirportCode VARCHAR(3), 
                            IN newYear INT, 
                            IN routePrice DOUBLE)
BEGIN
    INSERT INTO route VALUES (NULL, departureAirportCode, arrivalAirportCode, routePrice, newYear);
END //

CREATE PROCEDURE addFlight(IN departureAirportCode VARCHAR(3), 
                            IN arrivalAirportCode VARCHAR(3), 
                            IN newYear INT, 
                            IN newDay VARCHAR(30), 
                            IN departureTime TIME)
BEGIN
    DECLARE weekNumber INT DEFAULT 1;

    INSERT INTO weekly_schedule VALUES(NULL, newYear, newDay, departureTime, 
                                        (SELECT route_id FROM route 
                                        WHERE departure_airport = departureAirportCode 
                                        AND arrival_airport = arrivalAirportCode 
                                        AND year = newYear));

    
    WHILE weekNumber <= 52 DO
        INSERT INTO flight_schedule VALUES (NULL, weekNumber, 
                                            (SELECT wk_sh_id FROM weekly_schedule ORDER BY wk_sh_id DESC LIMIT 1));
        
        SET weekNumber = weekNumber + 1;
    END WHILE;
END //

DELIMITER ;

-- source 4_test_Question3.sql;


/*Question 4*/

DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

DELIMITER //

CREATE FUNCTION calculateFreeSeats(flightNumber INT) RETURNS INT
BEGIN
    DECLARE totalSeats INT DEFAULT 40;
    DECLARE bookedSeats INT;

    -- Get the number of booked seats for the flight
    SELECT COUNT(pr.passenger_id) INTO bookedSeats
    FROM passenger_reservation pr 
    JOIN reservation r ON r.res_id = pr.res_id
    WHERE r.flight_schedule_id = flightNumber 
    AND r.res_id IN(SELECT res_id from booking);

    -- Calculate the number of available seats
    RETURN totalSeats - bookedSeats;
END //

CREATE FUNCTION calculatePrice( flightNumber INT) RETURNS DOUBLE
BEGIN
    DECLARE RoutePrice DOUBLE;
    DECLARE freeSeats INT;
    DECLARE bookedSeats INT;
    DECLARE nextSeatPrice DOUBLE;
    DECLARE Weekdayfactor DOUBLE;
    DECLARE Profitfactor DOUBLE;
    

    -- Get the route price for the flight 
    SELECT r.Routeprice INTO RoutePrice
    FROM route r
    JOIN weekly_schedule ws ON ws.route_id = r.route_id
    JOIN flight_schedule fs ON fs.wk_sh_id = ws.wk_sh_id
    WHERE fs.flight_schedule_id = flightNumber
    LIMIT 1;

    -- Get week day factor
    SELECT wk_day_factor INTO Weekdayfactor
    FROM week_day w
    JOIN weekly_schedule ws ON ws.week_day = w.week_day
    JOIN flight_schedule fs ON fs.wk_sh_id = ws.wk_sh_id
    WHERE fs.flight_schedule_id = flightNumber;

    -- Get the number of booked seats for the flight    
    SELECT calculateFreeSeats(flightNumber) INTO freeSeats ;
    SET bookedSeats = 40 - freeSeats;

    -- Get profit Factor
    SELECT profit_factor INTO Profitfactor
    FROM year y
    JOIN weekly_schedule ws ON ws.year = y.year
    JOIN flight_schedule fs ON fs.wk_sh_id = ws.wk_sh_id
    WHERE fs.flight_schedule_id = flightNumber;


    -- Calculate the price of the next seat
    SET nextSeatPrice = RoutePrice * Weekdayfactor * ((bookedSeats+1)/40) * Profitfactor; 

    RETURN ROUND(nextSeatPrice, 2);
END //

DELIMITER ;

-- SELECT calculateFreeSeats(2);
-- SELECT calculatePrice(2);

/*Question 5*/

-- DROP TRIGGER IF EXISTS booking.issueTicket;

DELIMITER //

CREATE TRIGGER issueTicket
AFTER INSERT ON booking FOR EACH ROW
BEGIN
    -- DECLARE reservationId INT;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE passengerId BIGINT;
    DECLARE ticketNumber INT;

    -- Loop through passengers in the reservation
    DECLARE cur_passenger CURSOR FOR
    SELECT passenger_id
    FROM passenger_reservation
    WHERE res_id = NEW.res_id;

    -- Declare a handler for when no more rows are found
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_passenger;

    ticket_loop: LOOP
        FETCH cur_passenger INTO passengerId;

        -- Check if no more rows
        IF done THEN
            LEAVE ticket_loop;
        END IF;

        -- Generate an unguessable ticket number using rand()
        SET ticketNumber = FLOOR(1 + RAND() * 999999);

        -- Update the passenger_booking_ticket table with the generated ticket number
        INSERT INTO passenger_booking_ticket (booking_id, passenger_id, ticket_no)
        VALUES (NEW.booking_id, passengerId, ticketNumber);

    END LOOP;

    CLOSE cur_passenger;

END //

DELIMITER ;

/*Question 6*/

DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;

DELIMITER //

CREATE PROCEDURE addReservation(IN departureAirport VARCHAR(3),
                                IN arrivalAirport VARCHAR(3),
                                IN year INT,
                                IN weekNumber INT,
                                IN day VARCHAR(30),
                                IN time TIME,
                                IN numPassengers INT,
                                OUT reservationNumber INT)
BEGIN
    DECLARE flightNumber INT;
    DECLARE price DOUBLE;
    
    -- select flight schdule
    SELECT flight_schedule_id INTO flightNumber
    FROM flight_schedule fs
    JOIN weekly_schedule ws ON ws.wk_sh_id = fs.wk_sh_id
    JOIN route r ON ws.route_id = r.route_id
    WHERE fs.week_no = weekNumber AND ws.departure_time = time AND ws.week_day = day AND
    ws.year = year AND r.arrival_airport = arrivalAirport AND r.departure_airport = departureAirport;

    IF flightNumber IS NULL THEN
        -- Return error message for incorrect flightdetails
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = ' There exist no flight for the given route, date and time';
    ELSEIF calculateFreeSeats(flightNumber) >= numPassengers THEN
        -- caculate price per seat
        SELECT calculatePrice(flightNumber) * numPassengers INTO price;

        -- Insert into reservation table
        INSERT INTO reservation VALUES (NULL, price, numPassengers, flightNumber, NULL);

        -- Get the assigned reservation number
        SELECT res_id INTO reservationNumber
        FROM reservation ORDER BY res_id DESC LIMIT 1;
    ELSE
        -- Return error message for insufficient seats
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are not enough seats available on the chosen flight';
    END IF;
END //

CREATE PROCEDURE addPassenger(IN reservationNumber INT,
                                IN passportNumber INT,
                                IN passengerName VARCHAR(30))
BEGIN
    -- Check if the reservation exists
    IF NOT EXISTS (SELECT 1 FROM reservation WHERE res_id = reservationNumber) THEN
        -- Return error message for non-existent reservation
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The given reservation number does not exist';
    ELSEIF EXISTS (SELECT 1 FROM booking WHERE res_id = reservationNumber) THEN
        -- Return error message for non-existent reservation
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = ' The booking has already been payed and no further passengers can be added';
    ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM passenger WHERE passport_no = passportNumber) THEN
                -- Insert into passenger table
                INSERT INTO passenger VALUES (passportNumber, passengerName);
            END IF;

            -- Insert into passenger_reservation table
            INSERT INTO passenger_reservation VALUES (passportNumber, reservationNumber);
        END;
    END IF;
END //


CREATE PROCEDURE addContact(IN reservationNumber INT,
                            IN passportNumber INT,
                            IN contactEmail VARCHAR(30),
                            IN contactPhone BIGINT)
BEGIN
    -- Check if the reservation exists
    IF NOT EXISTS (SELECT 1 FROM reservation WHERE res_id = reservationNumber) THEN
        BEGIN
            -- Return error message for non-existent reservation
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The given reservation number does not exist.';
        END;
    ELSEIF NOT EXISTS (SELECT 1 FROM passenger_reservation WHERE passenger_id = passportNumber AND res_id = reservationNumber) THEN
        BEGIN
            -- Return error message for non-existent contact in the reservation
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = ' The person is not a passenger of the reservation.';
        END;
    ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM contact_person WHERE passport_no = passportNumber) THEN
                -- Insert into contact_person table
                INSERT INTO contact_person VALUES (passportNumber, contactEmail, contactPhone);
            END iF;

            -- Update resevation with contact person
            UPDATE reservation SET contact_person = passportNumber
            WHERE res_id = reservationNumber;
        END;
    END IF;
END //


CREATE PROCEDURE addPayment(IN reservationNumber INT,
                            IN cardholderName VARCHAR(30),
                            IN creditCardNumber BIGINT)
BEGIN
    DECLARE contactPassportNumber INT;
    DECLARE numPassengers INT;
    DECLARE flightNumber INT;
    DECLARE totalPrice DOUBLE;

    -- Check if the reservation has a contact
    SELECT contact_person INTO contactPassportNumber
    FROM reservation
    WHERE res_id = reservationNumber;

    -- Select no of passengers in reservation
    SELECT COUNT(*) INTO numPassengers
    FROM passenger_reservation
    WHERE res_id = reservationNumber;

    IF NOT EXISTS (SELECT 1 FROM reservation WHERE res_id = reservationNumber) THEN
        -- Return error message for non-existent reservation
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The given reservation number does not exist.';
    ELSEIF contactPassportNumber IS NULL THEN
        -- Return error message for no contact
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The reservation has no contact yet';
    ELSEIF calculateFreeSeats(flightNumber) < numPassengers THEN
        -- Return error message for no seat
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are not enough seats available on the flight anymore, deleting reservations.';
    ELSE
        -- Get flightNumber
        SELECT flight_schedule_id INTO flightNumber
        FROM reservation WHERE res_id = reservationNumber;

        -- Calculate total price or seats
        SELECT calculatePrice(flightNumber) * numPassengers INTO totalPrice;

        IF NOT EXISTS (SELECT 1 FROM payment_details WHERE card_number = creditCardNumber) THEN
            -- Insert into payment_details table
            INSERT INTO payment_details VALUES (creditCardNumber, cardholderName);
        END IF;

        -- Insert into payment_details table
        INSERT INTO booking VALUES (NULL, totalPrice, reservationNumber, creditCardNumber);
        
    END IF;
END //

DELIMITER ;

-- source 4_test_Question6.sql

/*Question 7*/

DROP VIEW IF EXISTS allFlights;

CREATE VIEW allFlights AS
SELECT
    a1.airport_name AS departure_city_name,
    a2.airport_name  AS destination_city_name,
    ws.departure_time AS departure_time, 
    ws.week_day AS departure_day, 
    fs.week_no AS departure_week, 
    ws.year AS departure_year, 
    calculateFreeSeats(fs.flight_schedule_id) AS nr_of_free_seats,
    calculatePrice(fs.flight_schedule_id) AS current_price_per_seat    
FROM weekly_schedule ws
JOIN flight_schedule fs ON ws.wk_sh_id = fs.wk_sh_id
JOIN route r ON r.route_id = ws.route_id
JOIN airport a1 ON a1.airport_code = r.departure_airport
JOIN airport a2 ON a2.airport_code = r.arrival_airport;


-- source 4_test_Question7.sql

/*Question 8*/

-- a) How can you protect the credit card information in the database from hackers?

-- Answer: To safeguard credit card information in the database, we can employ stringent access 
-- controls, encryption for data in transit and at rest, and regular audits to monitor user 
-- activity. We need to implement measures like inference control and flow control to prevent 
-- unauthorized access and information leakage. Classify data based on sensitivity, and balance 
-- security with precision, recognizing the role of the Database Administrator in managing 
-- overall security. Securely store user account details through encryption, obey applicable 
-- laws, and maintain a effective approach to database security.

-- b) Give three advantages of using stored procedures in the database (and thereby execute 
-- them on the server) instead of writing the same functions in the frontend of the system 
-- (in for example java-script on a web-page)?

-- Answer: 
-- - Improved Performance: Stored procedures optimize and execute on the server, reducing data 
-- transfer and enhancing overall system performance.
-- - Enhanced Security:  Controlled access to stored procedures enhances security, restricting 
-- database interactions and safeguarding sensitive information.
-- - Centralized Maintenance: Storing business logic in procedures streamlines updates, ensuring 
-- a more maintainable and organized system architecture.

/* Question 9 */

-- b)  Is this reservation visible in session B? Why? Why not?

-- Answer: No. The reservation made in session A is not visible in session B. The reason for this is 
-- MYSQL uses the Repeatale-Read isolation level. Until session A commits the transaction, the
-- changes made are not visible to other transactions.

-- c) What happens if you try to modify the reservation from A in B? Explain what 
-- happens and why this happens and how this relates to the concept of isolation 
-- of transactions.

-- Answer: Attempt to modify reservation in session B before session A commits the transaction will 
-- result in modification to the original state before starting transaction in session A. The
-- concept of isolation ensures that concurrent transaction do not affect the outcome of one
-- another.

/* Question 10 */

-- source 4_test_Question10FillWithFlights.sql


-- a)  Did overbooking occur when the scripts were executed? If so, why? If not, 
-- why not?

-- Answer: 

-- Some times Overbooking occured. This is due to lack of concurrency control. 'addPayment' is 
-- executed concurrently. Both sessions independently checks the no of available seats and proceed
-- to make payment and make the reservation, a booking.

-- Some times over booking did not occur. This depends on the time in between the execution of 
-- 2 sessions. If the session B tries to create a reservation just after payment was done in 
-- session A, then in session B reservation will not be created and over booking will not occur.

-- b)  Can an overbooking theoretically occur? If an overbooking is possible, in what 
-- order must the lines of code in your procedures/functions be executed.

-- Answer: Theoritically over booking is possible. For an overbooking to occur the functions calls in
-- session A and B should be in following order.

-- Session A addReservation
-- Session B addReservation
-- Sessin A and B addPassengers
-- Session A and B addContact
-- Session A addPayment
-- Session B addPayment

-- c)  Try to make the theoretical case occur in reality by simulating that multiple 
-- sessions call the procedure at the same time. To specify the order in which the 
-- lines of code are executed use the MySQL query SELECT sleep(5); which 
-- makes the session sleep for 5 seconds. Note that it is not always possible to 
-- make the theoretical case occur, if not, motivate why.

-- Answer: This depends on the time in between the execution of 
-- 2 sessions. If the session B tries to create a reservation just after payment was done in 
-- session A, then in session B reservation will not be created and over booking will not occur.

-- d)  Modify the testscripts so that overbookings are no longer possible using 
-- (some of) the commands START TRANSACTION, COMMIT, LOCK TABLES, UNLOCK 
-- TABLES, ROLLBACK, SAVEPOINT, and SELECT...FOR UPDATE. Motivate why your 
-- solution solves the issue, and test that this also is the case using the sleep 
-- implemented in 10c. Note that it is not ok that one of the sessions ends up in a 
-- deadlock scenario. Also, try to hold locks on the common resources for as 
-- short time as possible to allow multiple sessions to be active at the same time.

-- Answer: check q10d.sql

/* Answer for the Secondary Index */

-- In our database, adding a secondary index would really help speed up searches for flights based 
-- on where they leave from and where they land. We want to put this index on the departure_airport 
-- and arrival_airport columns in the route table.

-- Design: CREATE INDEX idx_departure_arrival_airport ON route (departure_airport, arrival_airport);
-- The above statement creates a composite index named 'idx_departure_arrival_airport' on the departure_airport
-- and 'arrival_airport' columns in the route table.

-- Adding a secondary index makes finding flights by airports faster, saving time compared to searching
-- through all flights each time, which gets slower as more flights are added. Retrieving flight
-- information becomes simpler with the index, especially for apps needing to find flights by departure 
-- and arrival points, making it easier to display the right flights. Ultimately, quicker searches improve 
-- the user experience by providing faster access to flight details, enhancing the system's overall 
-- user-friendliness and satisfaction.