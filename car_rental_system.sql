-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 14, 2024 at 03:13 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `car_rental_system`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddReservation` (IN `user_id` INT, IN `car_id` INT, IN `start_date` DATE, IN `end_date` DATE, OUT `total_amount` DECIMAL(10,2))   BEGIN
    DECLARE rental_days INT;
    DECLARE daily_rate DECIMAL(10, 2);

    SET rental_days = DATEDIFF(end_date, start_date) + 1;
    SELECT rental_price_per_day INTO daily_rate FROM Cars WHERE car_id = car_id;

    SET total_amount = rental_days * daily_rate;

    INSERT INTO Reservations (user_id, car_id, start_date, end_date, total_amount, status)
    VALUES (user_id, car_id, start_date, end_date, total_amount, 'pending');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveReservationsByBranch` ()   BEGIN
    SELECT branch_name, COUNT(*) AS active_reservations
    FROM ActiveBranchReservations
    GROUP BY branch_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCarAvailability` ()   BEGIN
    UPDATE Cars
    SET availability_status = 'available'
    WHERE car_id IN (
        SELECT car_id
        FROM Reservations
        WHERE status = 'confirmed' AND end_date < CURDATE()
    );
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `activebranchreservations`
-- (See below for the actual view)
--
CREATE TABLE `activebranchreservations` (
`branch_name` varchar(100)
,`brand` varchar(50)
,`model` varchar(50)
,`start_date` date
,`end_date` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `activereservations`
-- (See below for the actual view)
--
CREATE TABLE `activereservations` (
`reservation_id` int(11)
,`car_id` int(11)
,`brand` varchar(50)
,`model` varchar(50)
,`start_date` date
,`end_date` date
);

-- --------------------------------------------------------

--
-- Table structure for table `appliedinsurance`
--

CREATE TABLE `appliedinsurance` (
  `applied_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `plan_id` int(11) DEFAULT NULL,
  `total_cost` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `appliedpromotions`
--

CREATE TABLE `appliedpromotions` (
  `applied_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `promo_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `branches`
--

CREATE TABLE `branches` (
  `branch_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `branches`
--

INSERT INTO `branches` (`branch_id`, `name`, `address`, `city`, `phone`) VALUES
(1, 'Downtown Branch', '123 Main St', 'Los Angeles', '5551234567'),
(2, 'Airport Branch', '456 Airport Rd', 'Los Angeles', '5559876543'),
(3, 'Suburban Branch', '789 Suburb Ln', 'Los Angeles', '5556543210'),
(4, 'City Center Branch', '101 City Plaza', 'New York', '5551122334'),
(5, 'Uptown Branch', '202 Uptown Ave', 'New York', '5553344556'),
(6, 'Downtown Branch', '303 Downtown Blvd', 'Chicago', '5557788990'),
(7, 'Mall Branch', '404 Mall Rd', 'Chicago', '5554455667'),
(8, 'Seaside Branch', '505 Seaside Dr', 'Miami', '5552233445'),
(9, 'Beach Branch', '606 Beach Ave', 'Miami', '5556677889'),
(10, 'Tech Park Branch', '707 Tech Park Ln', 'San Francisco', '5555566778');

-- --------------------------------------------------------

--
-- Table structure for table `carimages`
--

CREATE TABLE `carimages` (
  `image_id` int(11) NOT NULL,
  `car_id` int(11) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `carinventory`
--

CREATE TABLE `carinventory` (
  `inventory_id` int(11) NOT NULL,
  `car_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `stock_count` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `carinventory`
--

INSERT INTO `carinventory` (`inventory_id`, `car_id`, `branch_id`, `stock_count`) VALUES
(1, 1, 1, 5),
(2, 2, 1, 4),
(3, 3, 2, 3),
(4, 4, 3, 6),
(5, 5, 4, 2),
(6, 6, 5, 7),
(7, 7, 6, 1),
(8, 8, 7, 4),
(9, 9, 8, 5),
(10, 10, 9, 3);

-- --------------------------------------------------------

--
-- Table structure for table `carmaintenance`
--

CREATE TABLE `carmaintenance` (
  `maintenance_id` int(11) NOT NULL,
  `car_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `maintenance_date` date DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `carmaintenance`
--

INSERT INTO `carmaintenance` (`maintenance_id`, `car_id`, `description`, `cost`, `maintenance_date`, `branch_id`) VALUES
(1, 1, 'Oil change', 50.00, '2024-11-15', 1),
(2, 2, 'Brake pad replacement', 120.00, '2024-11-20', 2),
(3, 3, 'Tire rotation', 30.00, '2024-11-25', 3),
(4, 4, 'Engine tune-up', 200.00, '2024-12-01', 4),
(5, 5, 'Battery replacement', 100.00, '2024-12-05', 5),
(6, 6, 'Air filter replacement', 25.00, '2024-12-10', 6),
(7, 7, 'Wheel alignment', 70.00, '2024-12-15', 7),
(8, 8, 'Transmission repair', 300.00, '2024-12-20', 8),
(9, 9, 'AC recharge', 90.00, '2024-12-25', 9),
(10, 10, 'Fuel system cleaning', 120.00, '2024-12-30', 10);

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `car_id` int(11) NOT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `license_plate` varchar(20) DEFAULT NULL,
  `car_type` varchar(50) DEFAULT NULL,
  `rental_price_per_day` decimal(10,2) DEFAULT NULL,
  `availability_status` enum('available','rented','maintenance') DEFAULT 'available'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`car_id`, `brand`, `model`, `year`, `license_plate`, `car_type`, `rental_price_per_day`, `availability_status`) VALUES
(1, 'Toyota', 'Camry', 2021, 'ABC123', 'Sedan', 50.00, 'available'),
(2, 'Honda', 'Civic', 2020, 'DEF456', 'Sedan', 45.00, 'available'),
(3, 'Ford', 'Explorer', 2019, 'GHI789', 'SUV', 70.00, 'available'),
(4, 'Chevrolet', 'Tahoe', 2022, 'JKL012', 'SUV', 90.00, 'maintenance'),
(5, 'Tesla', 'Model 3', 2023, 'MNO345', 'Electric', 100.00, 'rented'),
(6, 'BMW', 'X5', 2021, 'PQR678', 'SUV', 120.00, 'available'),
(7, 'Audi', 'A4', 2020, 'STU901', 'Sedan', 80.00, 'available'),
(8, 'Mercedes', 'C-Class', 2022, 'VWX234', 'Sedan', 85.00, 'rented'),
(9, 'Hyundai', 'Tucson', 2021, 'YZA567', 'SUV', 60.00, 'available'),
(10, 'Kia', 'Sportage', 2020, 'BCD890', 'SUV', 55.00, 'available');

-- --------------------------------------------------------

--
-- Table structure for table `cartypes`
--

CREATE TABLE `cartypes` (
  `type_id` int(11) NOT NULL,
  `type_name` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customeraddress`
--

CREATE TABLE `customeraddress` (
  `address_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `postal_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customerfeedback`
--

CREATE TABLE `customerfeedback` (
  `feedback_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comments` text DEFAULT NULL,
  `feedback_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `highperformingcustomers`
-- (See below for the actual view)
--
CREATE TABLE `highperformingcustomers` (
`user_id` int(11)
,`full_name` varchar(100)
,`total_spent` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `insuranceplans`
--

CREATE TABLE `insuranceplans` (
  `plan_id` int(11) NOT NULL,
  `plan_name` varchar(100) DEFAULT NULL,
  `cost_per_day` decimal(10,2) DEFAULT NULL,
  `coverage_details` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `paymentlogs`
--

CREATE TABLE `paymentlogs` (
  `log_id` int(11) NOT NULL,
  `payment_id` int(11) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `log_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `amount_paid` decimal(10,2) DEFAULT NULL,
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `payment_method` enum('credit_card','debit_card','cash','bank_transfer') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `promotions`
--

CREATE TABLE `promotions` (
  `promo_id` int(11) NOT NULL,
  `promo_code` varchar(20) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `discount_percent` decimal(5,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reservationlogs`
--

CREATE TABLE `reservationlogs` (
  `log_id` int(11) NOT NULL,
  `reservation_id` int(11) DEFAULT NULL,
  `old_status` enum('pending','confirmed','cancelled') DEFAULT NULL,
  `new_status` enum('pending','confirmed','cancelled') DEFAULT NULL,
  `change_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `changed_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reservations`
--

CREATE TABLE `reservations` (
  `reservation_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `car_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `status` enum('pending','confirmed','cancelled') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reservations`
--

INSERT INTO `reservations` (`reservation_id`, `user_id`, `car_id`, `start_date`, `end_date`, `total_amount`, `status`, `created_at`) VALUES
(2, 1, 1, '2024-12-20', '2024-12-25', 250.00, 'confirmed', '2024-12-14 02:03:55'),
(3, 2, 2, '2024-12-15', '2024-12-18', 135.00, 'confirmed', '2024-12-14 02:03:55'),
(4, 3, 3, '2024-12-10', '2024-12-14', 280.00, 'cancelled', '2024-12-14 02:03:55'),
(5, 4, 5, '2024-12-21', '2024-12-23', 200.00, 'pending', '2024-12-14 02:03:55'),
(6, 6, 6, '2024-12-12', '2024-12-15', 360.00, 'confirmed', '2024-12-14 02:03:55'),
(7, 7, 8, '2024-12-11', '2024-12-13', 170.00, 'confirmed', '2024-12-14 02:03:55'),
(8, 8, 9, '2024-12-09', '2024-12-10', 120.00, 'cancelled', '2024-12-14 02:03:55'),
(9, 9, 10, '2024-12-18', '2024-12-22', 275.00, 'pending', '2024-12-14 02:03:55'),
(10, 10, 4, '2024-12-16', '2024-12-20', 360.00, 'confirmed', '2024-12-14 02:03:55'),
(11, 1, 7, '2024-12-22', '2024-12-26', 400.00, 'confirmed', '2024-12-14 02:03:55');

--
-- Triggers `reservations`
--
DELIMITER $$
CREATE TRIGGER `LogReservationStatusChange` AFTER UPDATE ON `reservations` FOR EACH ROW BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO ReservationLogs (reservation_id, old_status, new_status, change_date, changed_by)
        VALUES (NEW.reservation_id, OLD.status, NEW.status, CURRENT_TIMESTAMP, NEW.user_id);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `PreventOverbooking` BEFORE INSERT ON `reservations` FOR EACH ROW BEGIN
    DECLARE active_count INT;
    SELECT COUNT(*) INTO active_count
    FROM Reservations
    WHERE car_id = NEW.car_id
      AND status = 'confirmed'
      AND (NEW.start_date BETWEEN start_date AND end_date OR NEW.end_date BETWEEN start_date AND end_date);

    IF active_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Car is already booked for the selected dates.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `UpdateCarStatusAfterReservation` AFTER UPDATE ON `reservations` FOR EACH ROW BEGIN
    IF NEW.status = 'completed' THEN
        UPDATE Cars
        SET availability_status = 'available'
        WHERE car_id = NEW.car_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `staff_id` int(11) NOT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `salary` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`staff_id`, `branch_id`, `name`, `email`, `phone`, `position`, `salary`) VALUES
(1, 1, 'Alice Green', 'alice@staff.com', '9988776655', 'Manager', 50000.00),
(2, 2, 'Bob Brown', 'bob@staff.com', '8899776655', 'Supervisor', 40000.00),
(3, 3, 'Charlie White', 'charlie@staff.com', '7788996655', 'Mechanic', 35000.00),
(4, 4, 'David Black', 'david@staff.com', '6677885544', 'Salesperson', 30000.00),
(5, 5, 'Eve Blue', 'eve@staff.com', '5566774433', 'Accountant', 45000.00),
(6, 6, 'Frank Gray', 'frank@staff.com', '4455663322', 'Technician', 37000.00),
(7, 7, 'Grace Pink', 'grace@staff.com', '3344552211', 'Cleaner', 25000.00),
(8, 8, 'Hank Purple', 'hank@staff.com', '2233441100', 'Manager', 52000.00),
(9, 9, 'Ivy Yellow', 'ivy@staff.com', '1122334455', 'Assistant', 29000.00),
(10, 10, 'Jack Orange', 'jack@staff.com', '6677889900', 'Security', 28000.00);

-- --------------------------------------------------------

--
-- Table structure for table `systemnotifications`
--

CREATE TABLE `systemnotifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` enum('sent','read') DEFAULT 'sent',
  `sent_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `role` enum('customer','staff','admin') DEFAULT 'customer',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password_hash`, `full_name`, `email`, `phone`, `role`, `created_at`) VALUES
(1, 'john_doe', 'password123', 'John Doe', 'john@example.com', '1234567890', 'customer', '2024-12-14 02:03:31'),
(2, 'jane_smith', 'password456', 'Jane Smith', 'jane@example.com', '9876543210', 'customer', '2024-12-14 02:03:31'),
(3, 'admin1', 'adminpassword', 'Admin User', 'admin@example.com', '1122334455', 'admin', '2024-12-14 02:03:31'),
(4, 'staff1', 'staffpassword', 'Alice Green', 'alice@staff.com', '9988776655', 'staff', '2024-12-14 02:03:31'),
(5, 'staff2', 'staffpassword', 'Bob Brown', 'bob@staff.com', '8899776655', 'staff', '2024-12-14 02:03:31'),
(6, 'jake_lee', 'password789', 'Jake Lee', 'jake@example.com', '7766554433', 'customer', '2024-12-14 02:03:31'),
(7, 'sara_connor', 'password007', 'Sara Connor', 'sara@example.com', '6655443322', 'customer', '2024-12-14 02:03:31'),
(8, 'mike_tyson', 'password888', 'Mike Tyson', 'mike@example.com', '2233445566', 'customer', '2024-12-14 02:03:31'),
(9, 'emma_watson', 'password111', 'Emma Watson', 'emma@example.com', '3344556677', 'customer', '2024-12-14 02:03:31'),
(10, 'elizabeth_roy', 'password222', 'Elizabeth Roy', 'elizabeth@example.com', '4455667788', 'customer', '2024-12-14 02:03:31');

-- --------------------------------------------------------

--
-- Table structure for table `vehiclefeatures`
--

CREATE TABLE `vehiclefeatures` (
  `feature_id` int(11) NOT NULL,
  `car_id` int(11) DEFAULT NULL,
  `feature_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `activebranchreservations`
--
DROP TABLE IF EXISTS `activebranchreservations`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `activebranchreservations`  AS SELECT `b`.`name` AS `branch_name`, `c`.`brand` AS `brand`, `c`.`model` AS `model`, `r`.`start_date` AS `start_date`, `r`.`end_date` AS `end_date` FROM (((`reservations` `r` join `cars` `c` on(`r`.`car_id` = `c`.`car_id`)) join `carinventory` `ci` on(`ci`.`car_id` = `c`.`car_id`)) join `branches` `b` on(`ci`.`branch_id` = `b`.`branch_id`)) WHERE `r`.`status` = 'confirmed' AND `r`.`end_date` >= curdate() ;

-- --------------------------------------------------------

--
-- Structure for view `activereservations`
--
DROP TABLE IF EXISTS `activereservations`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `activereservations`  AS SELECT `r`.`reservation_id` AS `reservation_id`, `c`.`car_id` AS `car_id`, `c`.`brand` AS `brand`, `c`.`model` AS `model`, `r`.`start_date` AS `start_date`, `r`.`end_date` AS `end_date` FROM (`reservations` `r` join `cars` `c` on(`r`.`car_id` = `c`.`car_id`)) WHERE `r`.`status` = 'confirmed' AND `r`.`end_date` >= curdate() ;

-- --------------------------------------------------------

--
-- Structure for view `highperformingcustomers`
--
DROP TABLE IF EXISTS `highperformingcustomers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `highperformingcustomers`  AS SELECT `u`.`user_id` AS `user_id`, `u`.`full_name` AS `full_name`, sum(`r`.`total_amount`) AS `total_spent` FROM (`users` `u` join `reservations` `r` on(`u`.`user_id` = `r`.`user_id`)) GROUP BY `u`.`user_id` HAVING `total_spent` > 5000 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `appliedinsurance`
--
ALTER TABLE `appliedinsurance`
  ADD PRIMARY KEY (`applied_id`),
  ADD KEY `reservation_id` (`reservation_id`),
  ADD KEY `plan_id` (`plan_id`);

--
-- Indexes for table `appliedpromotions`
--
ALTER TABLE `appliedpromotions`
  ADD PRIMARY KEY (`applied_id`),
  ADD KEY `reservation_id` (`reservation_id`),
  ADD KEY `promo_id` (`promo_id`);

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`branch_id`);

--
-- Indexes for table `carimages`
--
ALTER TABLE `carimages`
  ADD PRIMARY KEY (`image_id`),
  ADD KEY `car_id` (`car_id`);

--
-- Indexes for table `carinventory`
--
ALTER TABLE `carinventory`
  ADD PRIMARY KEY (`inventory_id`),
  ADD KEY `car_id` (`car_id`),
  ADD KEY `branch_id` (`branch_id`);

--
-- Indexes for table `carmaintenance`
--
ALTER TABLE `carmaintenance`
  ADD PRIMARY KEY (`maintenance_id`),
  ADD KEY `car_id` (`car_id`),
  ADD KEY `branch_id` (`branch_id`);

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
  ADD PRIMARY KEY (`car_id`),
  ADD UNIQUE KEY `license_plate` (`license_plate`);

--
-- Indexes for table `cartypes`
--
ALTER TABLE `cartypes`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `customeraddress`
--
ALTER TABLE `customeraddress`
  ADD PRIMARY KEY (`address_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `customerfeedback`
--
ALTER TABLE `customerfeedback`
  ADD PRIMARY KEY (`feedback_id`),
  ADD KEY `reservation_id` (`reservation_id`);

--
-- Indexes for table `insuranceplans`
--
ALTER TABLE `insuranceplans`
  ADD PRIMARY KEY (`plan_id`);

--
-- Indexes for table `paymentlogs`
--
ALTER TABLE `paymentlogs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `payment_id` (`payment_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `reservation_id` (`reservation_id`);

--
-- Indexes for table `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`promo_id`),
  ADD UNIQUE KEY `promo_code` (`promo_code`);

--
-- Indexes for table `reservationlogs`
--
ALTER TABLE `reservationlogs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `reservation_id` (`reservation_id`),
  ADD KEY `changed_by` (`changed_by`);

--
-- Indexes for table `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`reservation_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `car_id` (`car_id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`staff_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `branch_id` (`branch_id`);

--
-- Indexes for table `systemnotifications`
--
ALTER TABLE `systemnotifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `vehiclefeatures`
--
ALTER TABLE `vehiclefeatures`
  ADD PRIMARY KEY (`feature_id`),
  ADD KEY `car_id` (`car_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `appliedinsurance`
--
ALTER TABLE `appliedinsurance`
  MODIFY `applied_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appliedpromotions`
--
ALTER TABLE `appliedpromotions`
  MODIFY `applied_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `branch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `carimages`
--
ALTER TABLE `carimages`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `carinventory`
--
ALTER TABLE `carinventory`
  MODIFY `inventory_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `carmaintenance`
--
ALTER TABLE `carmaintenance`
  MODIFY `maintenance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `car_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `cartypes`
--
ALTER TABLE `cartypes`
  MODIFY `type_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customeraddress`
--
ALTER TABLE `customeraddress`
  MODIFY `address_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customerfeedback`
--
ALTER TABLE `customerfeedback`
  MODIFY `feedback_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `insuranceplans`
--
ALTER TABLE `insuranceplans`
  MODIFY `plan_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `paymentlogs`
--
ALTER TABLE `paymentlogs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `promotions`
--
ALTER TABLE `promotions`
  MODIFY `promo_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reservationlogs`
--
ALTER TABLE `reservationlogs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `reservations`
--
ALTER TABLE `reservations`
  MODIFY `reservation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `staff_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `systemnotifications`
--
ALTER TABLE `systemnotifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `vehiclefeatures`
--
ALTER TABLE `vehiclefeatures`
  MODIFY `feature_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appliedinsurance`
--
ALTER TABLE `appliedinsurance`
  ADD CONSTRAINT `appliedinsurance_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`),
  ADD CONSTRAINT `appliedinsurance_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `insuranceplans` (`plan_id`);

--
-- Constraints for table `appliedpromotions`
--
ALTER TABLE `appliedpromotions`
  ADD CONSTRAINT `appliedpromotions_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`),
  ADD CONSTRAINT `appliedpromotions_ibfk_2` FOREIGN KEY (`promo_id`) REFERENCES `promotions` (`promo_id`);

--
-- Constraints for table `carimages`
--
ALTER TABLE `carimages`
  ADD CONSTRAINT `carimages_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`car_id`);

--
-- Constraints for table `carinventory`
--
ALTER TABLE `carinventory`
  ADD CONSTRAINT `carinventory_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`car_id`),
  ADD CONSTRAINT `carinventory_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`);

--
-- Constraints for table `carmaintenance`
--
ALTER TABLE `carmaintenance`
  ADD CONSTRAINT `carmaintenance_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`car_id`),
  ADD CONSTRAINT `carmaintenance_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`);

--
-- Constraints for table `customeraddress`
--
ALTER TABLE `customeraddress`
  ADD CONSTRAINT `customeraddress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `customerfeedback`
--
ALTER TABLE `customerfeedback`
  ADD CONSTRAINT `customerfeedback_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`);

--
-- Constraints for table `paymentlogs`
--
ALTER TABLE `paymentlogs`
  ADD CONSTRAINT `paymentlogs_ibfk_1` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`);

--
-- Constraints for table `reservationlogs`
--
ALTER TABLE `reservationlogs`
  ADD CONSTRAINT `reservationlogs_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`reservation_id`),
  ADD CONSTRAINT `reservationlogs_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`car_id`) REFERENCES `cars` (`car_id`);

--
-- Constraints for table `staff`
--
ALTER TABLE `staff`
  ADD CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`);

--
-- Constraints for table `systemnotifications`
--
ALTER TABLE `systemnotifications`
  ADD CONSTRAINT `systemnotifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `vehiclefeatures`
--
ALTER TABLE `vehiclefeatures`
  ADD CONSTRAINT `vehiclefeatures_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`car_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
