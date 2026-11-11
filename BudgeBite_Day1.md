**DBMS FINAL PROJECT – DAY 1**

**Project Title**: BUDGETBITE: Budget-Based Meal Recommendation and Scheduled Food Reservation System for Local Carinderias with Web and Mobile Integration

**Project Members**:

1. Jeward P. Benlot
2. GR Miles D. Malooy
3. John Aaron Oga-ob
4. Netchelle Talledo
5. Nicole Gomez

**Course**: BS Information Technology (BSIT)

**Subject**: Database Management Systems

**Instructor**: James Paul Pandan

**TASK 1 – SYSTEM IDENTIFICATION**

**Proposed System Title:**

**BUDGETBITE**: Budget-Based Meal Recommendation and Scheduled Food Reservation System for Local Carinderias with Web and Mobile Integration.

Organization or Intended Environment:

Local carinderias that provide affordable meals to students, employees, and other customers.

**System Description:**

BUDGETBITE is a web and mobile integrated system that helps customers find affordable meals based on their available budget. It allows customers to select meals, specify quantities, reserve food in advance, and schedule their expected arrival or pickup time. Carinderia sellers can manage food menus, prices, availability, reservations, payments, and food preparation schedules.

**Existing Process:**

Customers usually visit carinderias, check available meals and prices, and place orders at the counter. Sellers manually manage customer orders, food availability, reservations, and preparation schedules.

**Problems Encountered:**

1. Difficulty finding meals that match customers' budgets.
2. Long waiting times, especially during busy hours.
3. Lack of advance food reservation.
4. Difficulty organizing food preparation schedules.
5. Uncertainty about food availability.
6. Manual management of orders and payments.

**Why the System Is Necessary:**

BUDGETBITE is necessary to make meal selection and reservation more convenient for customers while helping local carinderias organize their daily operations. It provides budget-based meal recommendations, advance reservations, payment monitoring, and centralized record management.

**TASK 2 – PROBLEM IDENTIFICATION**

| **Problems**                        | **Who Is Affected?**       | **Consequences**                                                                 | **How BUDGETBITE Addresses It**                        |
| ----------------------------------- | -------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Difficulty finding affordable meals | Customers                  | Customers spend more time checking prices and finding meals within their budget. | Provides budget-based meal recommendations.            |
| Long waiting times                  | Customers and sellers      | Customers experience delays, especially during peak hours.                       | Allows customers to reserve meals in advance.          |
| Lack of advance reservations        | Customers and sellers      | Customers cannot conveniently reserve meals before arriving.                     | Provides scheduled food reservation.                   |
| Inefficient food preparation        | Carinderia sellers         | Orders may become difficult to organize.                                         | Provides suggested food preparation schedules.         |
| Uncertainty of food availability    | Customers                  | Customers may visit without knowing whether their preferred meals are available. | Allows sellers to update food availability.            |
| Manual order and payment management | Sellers and administrators | Records may become disorganized and transactions difficult to monitor.           | Maintains centralized reservation and payment records. |

**TASK 3 – PROJECT OBJECTIVES**

General Objective

To develop BUDGETBITE, a budget-based meal recommendation and scheduled food reservation system with web and mobile integration that helps customers find affordable meals, reserve food in advance, schedule pickup times, and pay through supported payment methods while helping local carinderias manage their daily operations efficiently.

**Specific Objectives**

1. To develop a centralized database for storing customer, carinderia, food menu, reservation, and payment information.
2. To provide budget-based meal recommendations according to customers' available budgets.
3. To allow customers to browse food items, view prices, and check food availability.
4. To enable customers to reserve meals and select their preferred pickup times.
5. To allow sellers to manage food menus, prices, and availability.
6. To provide reservation and food preparation scheduling features.
7. To integrate online payment and cash-on-pickup options.
8. To maintain accurate reservation, payment, and transaction records.

**TASK 4 – TARGET USERS**

| **User Type**           | **Primary Responsibilities**                                                                 | **Access Level / Permissions** |
| ----------------------- | -------------------------------------------------------------------------------------------- | ------------------------------ |
| Administrator           | Manages user accounts, participating carinderias, system activities, and reports.            | Full administrative access     |
| Regular User / Customer | Browses meals, enters a budget, reserves food, selects payment methods, and tracks orders.   | Customer access                |
| Carinderia Seller       | Manages food menus, prices, availability, reservations, preparation schedules, and payments. | Seller access                  |

**TASK 5 – INITIAL DATABASE PLANNING**

The following are the proposed initial database entities for BUDGETBITE.

| **Entity Name**       | **Business Purpose**                      | **Information to Be Stored (Key Attributes)**                                 |
| --------------------- | ----------------------------------------- | ----------------------------------------------------------------------------- |
| Users                 | Stores system accounts.                   | user_id, username, email, password_hash, role                                 |
| Customers             | Stores customer information.              | customer_id, user_id, full_name, contact_number                               |
| Carinderias           | Stores participating food establishments. | carinderia_id, seller_id, business_name, address                              |
| Food Categories       | Organizes food items.                     | category_id, category_name, description                                       |
| Food Items            | Stores meal information and prices.       | food_id, carinderia_id, category_id, food_name, price, availability           |
| Reservations          | Stores customer food reservations.        | reservation_id, customer_id, carinderia_id, pickup_time, total_amount, status |
| Reservation Items     | Stores meals included in reservations.    | reservation_item_id, reservation_id, food_id, quantity, subtotal              |
| Payments              | Records customer payments.                | payment_id, reservation_id, amount, payment_method, payment_status            |
| Notifications         | Stores customer updates.                  | notification_id, user_id, message, created_at, read_status                    |
| Preparation Schedules | Stores food preparation schedules.        | schedule_id, reservation_id, preparation_start, estimated_completion          |
| Order History         | Tracks reservation status changes.        | history_id, reservation_id, previous_status, new_status, changed_at           |

**TASK 6 – DBMS SELECTION**

**Database Name and Classification:**

- Database Name: budgetbite_db
- DBMS: MariaDB (MySQL-compatible)
- Classification: Relational Database Management System (RDBMS)
- Database Package: XAMPP
- Management Tool: phpMyAdmin

**Justification:**

MariaDB is suitable for BUDGETBITE because the system requires organized storage of related information, including customers, carinderias, food items, reservations, and payments. It supports SQL queries, primary keys, foreign keys, and database transactions that help maintain data accuracy and consistency.

**Advantages:**

1. Free and open-source.
2. Supports relational database tables.
3. Provides primary keys and foreign keys.
4. Supports SQL queries and transactions.
5. Easy to manage using phpMyAdmin.

**Limitations:**

1. Requires proper installation and configuration.
2. Needs a running database server to access information.
3. Requires security and backup management.
4. Large databases may require performance optimization.

**Management and Modeling Tools:**

| **Tool**           | **Purpose**                                                     |
| ------------------ | --------------------------------------------------------------- |
| XAMPP              | Provides the local development environment and database server. |
| MariaDB            | Stores and manages project information.                         |
| phpMyAdmin         | Manages databases, tables, and SQL queries.                     |
| Visual Studio Code | Used for writing and editing project files.                     |
| GitHub             | Stores project documentation and source code.                   |
| Postman            | Tests backend API endpoints.                                    |