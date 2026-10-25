<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentUri = request.getRequestURI();
    String ctx = request.getContextPath();
    String studentName = (String) session.getAttribute("studentName");
    if (studentName == null || studentName.isBlank()) studentName = "Student";
    String initial = studentName.substring(0, 1).toUpperCase();
%>
<nav class="navbar navbar-expand-lg student-navbar sticky-top" aria-label="Student Navigation">
    <div class="container-xl">
        <a class="navbar-brand" href="<%= ctx %>/StudentDashboardServlet">
            <i class="fas fa-book-bookmark"></i>
            <span>libris<span style="color: var(--color-accent); font-weight: 700;">.</span> <span style="font-size: 0.75rem; font-family: var(--font-mono); color: var(--color-ink-muted); font-weight: 400; text-transform: uppercase; margin-left: 4px;">Student</span></span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#studentNavbar" aria-controls="studentNavbar" aria-expanded="false" aria-label="Toggle navigation">
            <i class="fas fa-bars"></i>
        </button>
        <div class="collapse navbar-collapse" id="studentNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-3">
                <li class="nav-item">
                    <a class="nav-link <%= currentUri.contains("StudentDashboard") ? "active" : "" %>" href="<%= ctx %>/StudentDashboardServlet">
                        <i class="fas fa-gauge-high"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= currentUri.contains("StudentViewBooks") ? "active" : "" %>" href="<%= ctx %>/StudentViewBooksServlet">
                        <i class="fas fa-magnifying-glass"></i> Browse Catalog
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= currentUri.contains("StudentIssuedBooks") ? "active" : "" %>" href="<%= ctx %>/StudentIssuedBooksServlet">
                        <i class="fas fa-book"></i> My Loans
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= currentUri.contains("StudentFineStatus") ? "active" : "" %>" href="<%= ctx %>/StudentFineStatusServlet">
                        <i class="fas fa-receipt"></i> Overdue Fines
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <%= currentUri.contains("StudentProfile") ? "active" : "" %>" href="<%= ctx %>/StudentProfileServlet">
                        <i class="fas fa-id-card"></i> Profile &amp; Security
                    </a>
                </li>
            </ul>
            <div class="d-flex align-items-center gap-3">
                <div class="student-user-pill" title="Signed in as <%= studentName %>">
                    <span class="student-user-avatar"><%= initial %></span>
                    <span><%= studentName %></span>
                </div>
                <a href="<%= ctx %>/StudentLogoutServlet" class="btn-lib-secondary btn-sm" title="Sign out of Student Portal">
                    <i class="fas fa-arrow-right-from-bracket"></i> Sign Out
                </a>
            </div>
        </div>
    </div>
</nav>
