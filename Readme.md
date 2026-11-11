BudgetBite: Budget-Based Meal Recommendation and Scheduled Food Reservation System for Local Carinderias with Web and Mobile Integration

Find meals that fit your budget, reserve them ahead, and pick them up on time, while carinderias manage menus, reservations, and payments in one place.

Project Overview

BudgetBite is a web and mobile integrated system that connects customers with participating local carinderias. Customers enter their available budget, browse matching meals, reserve food, choose an expected pickup time, and pay online (e.g., GCash) or through cash-on-pickup. Sellers manage menus, reservations, payments, and preparation schedules through a web dashboard, and administrators oversee the platform.

Problem Statement. Customers of carinderias often struggle to find meals within a limited budget, wait long during peak hours, and cannot tell whether a dish is still available. Sellers usually handle orders and reservations manually, which causes confusion, missed orders, and scheduling difficulty. Few carinderias offer an organized option for advance reservation or digital payment.

Purpose of the System. To make meal selection, reservation, payment, and food preparation more convenient for customers and better organized for local carinderias, using a centralized backend and database that keep the mobile app and web platform synchronized.

Intended Users

User	Interface	Description
Customer	Mobile application	Browses meals by budget, reserves, pays, and tracks orders
Carinderia Seller	Web dashboard	Manages menu, availability, reservations, payments, and preparation schedule
Administrator	Web dashboard	Manages accounts, verifies carinderias, monitors activity and reports

Current Project Status: Requirements and Database Design Phase (Day 1: system identification, database planning, and GitHub repository setup).

Project Objectives
General Objective

To develop BudgetBite, a budget-based meal recommendation and scheduled food reservation system with web and mobile integration that allows customers to find affordable meals, reserve food in advance, select their expected arrival time, and pay online through supported payment methods, while helping local carinderias manage their menus, reservations, payments, and preparation schedules efficiently.

Specific Objectives
Develop a mobile application that allows customers to register, log in, and manage their accounts.
Provide a budget-based meal recommendation feature that displays available meals according to the customer's budget.
Allow customers to view food details, including pictures, descriptions, prices, and availability.
Enable customers to select meals, quantities, and preferred pickup or arrival times.
Develop a reservation management feature that allows sellers to accept or reject reservations.
Provide a suggested food preparation schedule based on expected arrival time and estimated preparation duration.
Develop a web dashboard for sellers to manage menus, prices, availability, reservations, and order statuses.
Integrate an online payment feature for reservations using supported digital payment methods.
Provide payment verification, transaction records, and digital receipts for successful online payments.
Provide an alternative cash-on-pickup payment option.
Implement notifications for reservation confirmations, payment updates, and order status changes.
Evaluate the system based on functionality, usability, reliability, performance, and compatibility.
Expected Outcomes
A customer mobile app, a seller web dashboard, and an administrator dashboard sharing one centralized database.
A normalized relational database with documented ERD, data dictionary, and schema scripts.
Verified payment records, digital receipts, and order tracking for every reservation.
Sales and reservation reports for sellers and monitoring tools for administrators.
System Features and Functionalities
Main System Modules
Module	Features
User Account Management	Registration, login, profile management, role-based access
Carinderia Management	Admin verification and management of participating carinderias
Food Menu Management	Add, update, remove food items; pictures, descriptions, prices, availability
Budget-Based Meal Recommendation	Budget input, meal filtering, total cost and remaining budget calculation
Scheduled Food Reservation	Meal and quantity selection, pickup time selection, accept/reject reservations
Food Preparation Scheduling	Suggested preparation schedule, upcoming reservation view, status updates
Order Tracking and Notifications	Reservation progress tracking, confirmation, payment, and ready-for-pickup notifications
Pickup Verification	Verification by order number or QR code before releasing orders
Online Payment and Payment Management	Gateway payment (e.g., GCash), backend verification, pending/successful/failed/refunded statuses, digital receipts, payment history, cash-on-pickup
Reports and Monitoring	Sales and reservation summaries, administrator activity monitoring
Web and Mobile Synchronization	Centralized backend and database shared by all interfaces
User Roles and Permissions
Function	Customer	Seller	Administrator
Register / log in / manage own profile	C R U	C R U	C R U
Manage customer and seller accounts	-	-	C R U D
Verify and manage carinderias	-	R (own) U (own profile)	C R U D
Manage food items and availability	R	C R U D (own)	R
Enter budget and view matching meals	R	-	-
Submit reservations	C R	-	R
Accept / reject reservations	-	R U	R
View preparation schedule	-	R	-
Update order status	R	U	R
Choose payment method and pay	C R	-	-
View payment records	R (own)	R (own carinderia)	R (all)
Verify pickup and confirm cash collection	-	U	-
View sales and reservation reports	-	R (own)	R (all)
Monitor system activity	-	-	R

C = Create, R = Read, U = Update, D = Delete.

Technology Stack
Stack Component	Selected Technology / Tool	Purpose / Justification in Project
Frontend Technology	Mobile app (customer) and web dashboards (seller/admin); framework to be finalized	Customer interface and seller/admin management interface
Backend Technology	Centralized backend API; framework to be finalized	Business logic, reservation/payment processing, synchronization
Programming Language	To be finalized	Core language across the codebase
DBMS	MySQL	Primary relational database for menus, reservations, orders, and payments
Database Modeling Tool	To be finalized	Conceptual, logical, and physical ERDs
Local Dev Environment	To be finalized	Local runtime for debugging and server execution
Cloud Database Provider	To be finalized	Hosting for the remote database instance, if used
Hosting Platform	To be finalized	Application deployment
Payment Gateway	GCash or another supported provider	Online payment of accepted reservations
Version Control Tool	Git & GitHub	Distributed version control and team repository management

Rows marked "to be finalized" will be updated as the team confirms its choices during the term.

Database Information
Selected DBMS & Paradigm: MySQL, Relational (SQL).
Database Name: budgetbite_db (proposed).
Database Hosting Environment: To be finalized (local server during early development).
Core Entities (draft, subject to normalization): users, roles, carinderias, food_items, reservations, reservation_items, payments, receipts, notifications, preparation_schedules.
Relationships & Referential Integrity (draft):
roles 1:N users
users (seller) 1:N carinderias
carinderias 1:N food_items
users (customer) 1:N reservations; carinderias 1:N reservations
reservations M:N food_items, resolved through reservation_items (stores quantity and unit price at time of order)
reservations 1:N payments (to allow retries after failed payments); payments 1:1 receipts (successful payments only)
reservations 1:1 preparation_schedules
users 1:N notifications
Cascade rules will be defined in the logical design (e.g., reservation_items cascade on reservation deletion; restrict on deleting a carinderia with reservations).
Data Validation & Constraints (planned): NOT NULL on required fields; UNIQUE on email and order number; CHECK for price > 0 and quantity > 0; ENUM/lookup values for reservation status (pending, accepted, rejected, preparing, ready, completed, cancelled) and payment status (pending, successful, failed, refunded); payment method (online, cash-on-pickup).
Security & Privilege Management (planned): Separate database user for the application with least privilege (no DROP/ALTER); hashed passwords; prepared statements; payment confirmation verified through the backend with the gateway, not only by the customer's return to the app.
Backup & Recovery Strategy (planned): Regular mysqldump exports with restore tested against an empty database.

This section will be updated as normalization and table design progress.

Database Architecture
HTTPS / REST JSON
HTTPS / REST JSON
Connection pool, TCP 3306
HTTPS API + webhookverification
Scheduled dumps
Customer Mobile App
Backend API Server
Seller and Admin WebDashboards
MySQL Database
Payment Gateway, e.g.GCash
Backup Storage

The final high-resolution diagram will be stored at day-02/architecture/database_architecture.png:

Database Architecture

Clients never connect to the database directly; all access goes through the backend over HTTPS, and the backend reaches MySQL through a pooled connection.

ERD and Database Design Documentation
Document	Link	Status
Entity Relationship Diagram (ERD)	database-design/erd	Draft
Conceptual Database Design	database-design/conceptual-design.md	Draft
Logical Database Design	database-design/logical-design.md	Draft
Physical Design & Schema	database/schema.sql	Draft
Data Dictionary	database-design/data-dictionary.md	Draft
Normalization Documentation	database-design/normalization.md	Draft
System Architecture and Workflow
User Interaction: Customers use the mobile app to enter a budget, choose meals, and submit a reservation with a pickup time. Sellers and administrators use the web dashboards to review reservations, update statuses, and monitor activity.
Component Communication: Clients send requests to the backend over HTTPS as RESTful JSON APIs, authenticated by role.
Database Access Layer: The backend uses an ORM or query builder with a connection pool to access MySQL.
Persistence & Retrieval: Reservations and their items are written in a single transaction. Budget filtering is a parameterized query on available food items priced within the budget. For online payments, the backend verifies the transaction with the gateway, records the payment status, and then updates the reservation so the seller receives the order for preparation. Results return as JSON to the client.

Reservation flow: Customer submits reservation → Seller accepts/rejects → Customer selects payment (online or cash-on-pickup) → Backend verifies online payment → Preparation schedule generated → Seller prepares and updates status → Customer notified → Pickup verified by order number or QR code → Order completed.

Repository Structure
DBMS-FINAL-2026-GROUPNAME/
├── README.md                      # Primary project documentation and setup manual
├── day-01/                        # Milestone 1: Approved proposal & problem statements
├── day-02/                        # Milestone 2: Functional requirements & architecture
│   └── architecture/              # Architecture diagrams (.png/.svg)
├── day-03/                        # Milestone 3: Initial schema design and modeling
├── database-design/               # Data dictionary, ERD files, normalization docs
├── database/                      # DDL scripts, seeders, and migrations
├── screenshots/                   # UI captures, database views, query results
└── progress-reports/              # Weekly summaries and instructor review logs

Update this tree as folders such as src/, backend/, or tests/ are added.

Installation and Setup Guide

To be completed once the team's stack is finalized and the setup has been tested from scratch.

Prerequisites: Git, MySQL, and the runtime required by the chosen backend and frontend.
Clone:
bash
   git clone https://github.com/YourOrg/YourRepo.git
   cd YourRepo
Database provisioning: Create the database and import the schema:
bash
   mysql -u root -p -e "CREATE DATABASE budgetbite_db;"
   mysql -u root -p budgetbite_db < database/schema.sql
Environment configuration: cp .env.example .env, then fill in your local values.
Install and run: Commands depend on the final stack and will be listed here.
Environment Variables and Security

Never commit passwords, API keys, tokens, or private connection strings. Copy .env.example to .env and make sure .env is listed in .gitignore.

env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=budgetbite_db
DB_USER=app_user
DB_PASSWORD=your_secure_password
APP_PORT=3000
PAYMENT_GATEWAY_SECRET_KEY=your_gateway_secret_key
Variable	Required	Description
DB_HOST	Yes	Database server host
DB_PORT	Yes	Database port (MySQL default 3306)
DB_NAME	Yes	Database name
DB_USER	Yes	Least-privilege application database user
DB_PASSWORD	Yes	Password for the application database user
APP_PORT	Yes	Port the backend listens on
PAYMENT_GATEWAY_SECRET_KEY	Yes, for online payment	Secret key for the payment gateway (use sandbox/test keys in development)
Screenshots and Project Preview

Screenshots will be added in screenshots/ as development progresses (authentic captures only):

Customer mobile app and seller/admin dashboard interfaces
Database schema, tables, and records in the DB management tool
Rendered ERD
Testing and Validation
Test Area	Planned Verification	Status
Connection Testing	Reliable connectivity; graceful error handling on timeout or host failure	Pending
CRUD Operations	Create, read, update, delete for menus, reservations, and accounts	Pending
Referential Integrity	Invalid foreign keys rejected; cascade and check constraints behave as designed	Pending
Security Testing	Prepared statements prevent SQL injection; payment verified through backend	Pending
Backup/Recovery	Export and restore to an empty database	Pending
Project Development Progress
 Project proposal and problem statement (Day 1)
 Functional and non-functional requirements documented
 GitHub repository setup
 Database architecture diagram
 Conceptual, logical, and physical database design
 ERD, data dictionary, and normalization documentation
 schema.sql and seed data
 Backend API, mobile app, and web dashboards
 Payment gateway integration (sandbox)
 Testing and validation
 System evaluation (functionality, usability, reliability, performance, compatibility)

Track work through the repository's GitHub Issues and Milestones.

Limitations
Pickup only; no delivery service in the initial version.
Internet connection required for online features.
Menu, price, and availability accuracy depends on seller updates.
Preparation schedules are suggestions, not guarantees.
Online payments depend on the gateway's availability, fees, and processing delays.
No nutritional or medical dietary advice, and no advanced AI-based recommendations.
Limited to participating local carinderias.
Group Members and Contributions
Member Name	Assigned Role	Primary Contributions & Managed Modules
(Miles malooy) (groupleader/Project Coordinator)
(Jane nicole Gomez) (System Analyst / Documentation)
(Netchelle Talledo) (Database Designer)
(Jeward Benlot)(UI/UX Designer / Frontend Developer)
(John Aaron Ogaob)(backend Developer / GitHub Manager)
License and Acknowledgments
License: To be confirmed (e.g., MIT or Academic use only). Add a matching LICENSE file to the repository root.
Acknowledgments: Database Management Systems course and instructor, and the open-source tools used in this project.