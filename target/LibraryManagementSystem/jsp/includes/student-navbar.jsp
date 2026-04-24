<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<nav class="navbar navbar-expand-lg custom-navbar sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center fw-bold" href="<%= request.getContextPath() %>/StudentDashboardServlet">
            <i class="fas fa-book-reader me-2"></i>
            Student Portal
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#studentNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="studentNavbar">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath() %>/StudentDashboardServlet"><i class="fas fa-home me-1"></i> Dashboard</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath() %>/StudentViewBooksServlet"><i class="fas fa-search me-1"></i> Browse Books</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath() %>/StudentIssuedBooksServlet"><i class="fas fa-book-open me-1"></i> My Books</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath() %>/StudentFineStatusServlet"><i class="fas fa-coins me-1"></i> Fine Status</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="<%= request.getContextPath() %>/StudentProfileServlet"><i class="fas fa-user-circle me-1"></i> My Profile</a>
                </li>
            </ul>
            <div class="d-flex align-items-center gap-3">
                <span class="text-light d-none d-lg-block"><i class="fas fa-user-circle me-1"></i> Welcome, <strong><%= session.getAttribute("studentName") != null ? session.getAttribute("studentName") : "Student" %></strong></span>
                <a href="<%= request.getContextPath() %>/StudentLogoutServlet" class="btn btn-outline-light btn-sm fw-bold px-3">
                    <i class="fas fa-sign-out-alt me-1"></i> Logout
                </a>
            </div>
        </div>
    </div>
</nav>
