<div align="center">
  <h1>📚 Library Management System</h1>
  <p><strong>A Modern, Secure, and Scalable Full Stack Java Web Application</strong></p>

  [![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)](https://java.com/)
  [![JSP](https://img.shields.io/badge/JSP-007396?style=for-the-badge&logo=java&logoColor=white)](#)
  [![Servlet](https://img.shields.io/badge/Servlet-007396?style=for-the-badge&logo=java&logoColor=white)](#)
  [![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
  [![Bootstrap](https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)](https://getbootstrap.com/)
  [![Maven](https://img.shields.io/badge/Maven-C71A22?style=for-the-badge&logo=apachemaven&logoColor=white)](https://maven.apache.org/)
  [![Tomcat](https://img.shields.io/badge/Apache_Tomcat-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black)](https://tomcat.apache.org/)
</div>

<br>

## 📖 1. Project Overview

The **Library Management System** is an industry-grade, college-level full-stack web application designed to digitalize and streamline library operations. Built with robust Java EE technologies, it provides a comprehensive digital platform for both administrators and students.

The system features a highly responsive, modern "glass-card" UI and robust back-end session management. It effortlessly handles inventory management, book issuance and returns, dynamic fine calculation, and student book requests while enforcing strict data validation and security protocols.

---

## ✨ 2. Key Features

### 🛡️ Admin Features
* **Secure Admin Login:** Role-based authentication and session tracking.
* **Dashboard Analytics:** Real-time metrics for total books, active issues, low stock, and pending requests.
* **Add / Edit / Delete Books:** Full CRUD operations on inventory with strict 13-digit ISBN uniqueness validation.
* **Search Books:** Dynamic global search across title, author, category, and ISBN.
* **Issue Book:** Streamlined issuance workflow that updates real-time stock and tracks due dates.
* **Return Book:** One-click return processing with automated fine calculation based on dynamic settings.
* **Manage Book Requests:** Review, approve (auto-issue), or reject incoming student book requests.
* **Fine Settings:** Configurable daily fine rates stored persistently.
* **Student Monitoring:** Centralized view of all registered students.
* **Inventory / Low Stock Alerts:** Visual indicators for books requiring restocking.

### 🎓 Student Features
* **Registration:** Secure account creation with email normalization and duplicate prevention.
* **Login:** Dedicated student portal access.
* **Dashboard:** Personalized overview of borrowed books, accumulated fines, and pending requests.
* **Browse Books:** Access to the complete library catalog.
* **Search Books:** Find books quickly using keywords.
* **Request Book:** Digital request submission for books currently unavailable or needed.
* **View Issued Books:** Track currently borrowed items and their due dates.
* **Fine Status:** Transparent breakdown of any active fines.
* **Profile Management:** View personal account details and academic tracking.

---

## 🛠️ 3. Tech Stack

| Component | Technology |
| :--- | :--- |
| **Frontend** | HTML5, CSS3, Bootstrap 5, JavaScript, FontAwesome |
| **Backend** | Java 17, Servlets, JSP (JavaServer Pages) |
| **Database** | MySQL |
| **Data Access** | JDBC (Java Database Connectivity) |
| **Build Tool** | Apache Maven |
| **Server** | Apache Tomcat 10+ (10.1 / 11) / Eclipse Jetty 12 |
| **Architecture** | 3-Tier MVC Architecture |

---

## 🏛️ 4. System Architecture

The project adheres to a standard **3-Tier Architecture** ensuring separation of concerns, scalability, and maintainability:

1. **Presentation Layer (JSP/HTML/CSS/Bootstrap):**
   Handles the user interface. JSP pages process dynamic data provided by the controllers and render it using a modern, responsive Bootstrap grid and custom CSS styling.
2. **Business Logic Layer (Servlets / Controllers):**
   Java Servlets act as the bridge between the UI and the database. They intercept HTTP requests, validate input, enforce session security, and orchestrate application logic.
3. **Data Access Layer (DAO + JDBC):**
   Data Access Object (DAO) classes encapsulate all SQL queries. They use JDBC to communicate securely with the database, handling CRUD operations and complex table joins.
4. **Database Layer (MySQL):**
   The relational database storing all persistent data with enforced foreign key constraints and unique indexes.

---

## 🗄️ 5. Database Design

The system relies on a well-structured relational schema consisting of the following core tables:

*   **`admin`**: Stores administrator credentials for secure access.
*   **`students`**: Contains student profiles, academic details, and secure login credentials.
*   **`books`**: The primary inventory table storing titles, authors, categories, ISBNs, pricing, and current stock quantity.
*   **`issued_books`**: A transactional table linking students to books, tracking issue dates, due dates, and return status.
*   **`book_requests`**: Manages the queue of student requests, linking the student, requested book, and current status (Pending/Approved/Rejected).
*   **`fine_settings`**: A configuration table storing the global, dynamic "fine per day" rate.

---

## 🔄 6. Full Workflow of Website

### 👨‍💼 Admin Workflow
1. **Authentication:** Admin logs in via `/LoginServlet`. Session is created.
2. **Dashboard:** Lands on the dashboard viewing real-time library stats.
3. **Inventory Management:** Navigates to **Add Book** to register new inventory (ISBN validated). Uses **View Books** to search, edit, or delete existing stock.
4. **Circulation:** Navigates to **Issue Book**, selects a student and an available book, and confirms. Stock decreases.
5. **Returns & Fines:** Uses **Return Book** to process returns. The system calculates overdue days against the `fine_settings` and alerts the admin of the total fine. Stock increases.
6. **Requests:** Monitors **Book Requests** to approve (issues book automatically) or reject student requests.

### 👨‍🎓 Student Workflow
1. **Onboarding:** New student registers. Email is normalized to lowercase and checked for duplicates.
2. **Authentication:** Student logs in via `/StudentLoginServlet`.
3. **Exploration:** Lands on the student dashboard showing active borrowed counts. Navigates to **Browse Catalog** to view available books.
4. **Action:** Finds a desired book and clicks **Request**. The request is sent to the admin queue.
5. **Tracking:** Checks **Issued Books** to monitor due dates and **Fine Status** for any penalties.

### 📖 Book Issue Lifecycle
1. **Request/Direct Issue:** Student requests a book, or Admin initiates issue.
2. **Validation:** System verifies the book has `quantity > 0`.
3. **Execution:** 
   * A record is inserted into `issued_books` with `issue_date` (today) and `due_date` (+14 days).
   * The `quantity` in the `books` table is decremented by 1.
4. **Return:** Admin processes return.
5. **Reconciliation:** 
   * System calculates `(Current Date - Due Date) * Fine Rate`.
   * Record in `issued_books` is marked returned/deleted.
   * The `quantity` in the `books` table is incremented by 1.

---

## 🔌 7. API / Servlet Endpoints

| Endpoint | Method | Purpose |
| :--- | :--- | :--- |
| `/LoginServlet` | GET, POST | Admin authentication and session initialization |
| `/LogoutServlet` | GET | Terminates admin session and redirects |
| `/DashboardServlet` | GET | Aggregates and displays admin analytics |
| `/AddBookServlet` | GET, POST | Handles UI rendering and DB insertion for new books |
| `/ViewBooksServlet` | GET | Fetches and filters the library inventory |
| `/IssueBookServlet` | GET, POST | Processes book issuance and stock reduction |
| `/ReturnBookServlet` | GET, POST | Processes returns and calculates fines |
| `/FineSettingsServlet` | GET, POST | Manages dynamic daily fine rate |
| `/StudentLoginServlet` | GET, POST | Student authentication |
| `/StudentRegisterServlet` | GET, POST | Handles new student registration and validation |
| `/StudentDashboardServlet` | GET | Aggregates student-specific metrics |
| `/StudentViewBooksServlet` | GET | Displays catalog for students with search |
| `/StudentRequestBookServlet` | GET | Renders the book request landing page |
| `/AdminBookRequestsServlet`| GET, POST | Allows admin to view, approve, or reject requests |

---

## 📁 8. Folder Structure

```text
LibraryManagementSystem/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── controller/      # Servlets handling HTTP requests
│   │   │   ├── dao/             # Data Access Objects (JDBC logic)
│   │   │   ├── model/           # POJO/Entity classes
│   │   │   └── util/            # Utility classes (DBConnection, Migrator)
│   │   ├── webapp/
│   │   │   ├── css/             # Custom stylesheets
│   │   │   ├── js/              # Frontend scripts
│   │   │   ├── jsp/
│   │   │   │   ├── includes/    # Reusable headers, footers, navbars
│   │   │   │   └── *.jsp        # View templates
│   │   │   ├── index.jsp        # Landing page
│   │   │   └── WEB-INF/
│   │   │       └── web.xml      # Deployment descriptor
```

---

## 🚀 9. Installation Guide

Follow these steps to run the project locally:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/LibraryManagementSystem.git
   cd LibraryManagementSystem
   ```
2. **Start and Set up MySQL Database:**
   * Ensure MySQL is running on port `3306`.
   * Create the database (or let the app auto-create it):
     ```sql
     CREATE DATABASE IF NOT EXISTS library_management;
     ```
   * *(Optional)* Import the schema dump:
     ```bash
     mysql -u root -p library_management < database/library_management.sql
     ```
     *(Note: The built-in `DatabaseSchemaMigrator` also auto-creates all required tables and default admin credentials upon first connection).*

3. **Configure Database Credentials:**
   * Open `src/main/java/util/DBConnection.java` to set your credentials (defaults: user `root`, password `newmac000`), or simply pass environment variables without modifying source code:
     ```bash
     export DB_USER=root
     export DB_PASSWORD=your_mysql_password
     ```

4. **Run the Application:**
   * **Option A: Quick Start via Maven (Recommended):**
     ```bash
     mvn clean jetty:run
     ```
     *(Starts instantly on port 8080 with Jakarta EE 10 support).*

   * **Option B: Standalone Apache Tomcat 10+:**
     1. Build the WAR:
        ```bash
        mvn clean package
        ```
     2. Copy `target/LibraryManagementSystem.war` to your Tomcat `webapps/` folder.
     3. Start Tomcat using `./bin/startup.sh` (or `startup.bat` on Windows).

5. **Access the Application:**
   * Open your browser and navigate to:
     `http://localhost:8080/LibraryManagementSystem`
   * **Default Admin Credentials:**
     - Username: `admin`
     - Password: `admin123`

---

## 📸 10. Screenshots

*(Replace placeholder links with actual image paths)*

### Admin Dashboard
![Admin Dashboard](https://via.placeholder.com/800x400?text=Admin+Dashboard+Screenshot)

### Student Dashboard
![Student Dashboard](https://via.placeholder.com/800x400?text=Student+Dashboard+Screenshot)

### Add / Edit Book
![Add Book](https://via.placeholder.com/800x400?text=Add+Book+Screenshot)

### Issue Book Workflow
![Issue Book](https://via.placeholder.com/800x400?text=Issue+Book+Screenshot)

### Book Requests
![Book Requests](https://via.placeholder.com/800x400?text=Book+Requests+Screenshot)

---

## 🔒 11. Security & Validation

This project implements industry-standard practices to ensure stability and security:

* **Session Authentication:** Strict `HttpSession` checks on all Servlets and JSP pages prevent direct URL access bypassing login.
* **Input Validation & Normalization:** Emails are `trim().toLowerCase()` formatted before database operations to prevent duplicate accounts caused by casing. Empty inputs are caught and rejected.
* **ISBN Uniqueness:** Books enforce a strict 13-digit ISBN constraint. Database and Java layers prevent duplicate ISBN entries.
* **SQL Injection Prevention:** All DAOs utilize `PreparedStatement` to safely parameterize inputs, neutralizing SQL injection risks.
* **Stock Integrity:** Books cannot be issued if `quantity` is 0. Returning a book safely restores the stock.

---

## 🔮 12. Future Enhancements

* 📧 **Email Notifications:** Auto-send overdue reminders via SMTP.
* 📱 **QR Code Integration:** Issue and return books by scanning generated QR codes.
* 📊 **PDF Reports:** Generate printable PDF reports for monthly fine collections and library usage.
* 🔑 **Role-Based Access Control (RBAC):** Expand admin roles to include Sub-Librarians with limited permissions.
* 🌐 **REST API Version:** Decouple the backend into a Spring Boot REST API for future React/Angular frontend integration.
* ☁️ **Cloud Deployment:** Containerize with Docker and deploy to AWS/Render.

---

<div align="center">
  <p>Created with ❤️ by <strong>Shriyansh</strong></p>
  <p><i>Industrial Practice / Full Stack Web Development</i></p>
</div>
