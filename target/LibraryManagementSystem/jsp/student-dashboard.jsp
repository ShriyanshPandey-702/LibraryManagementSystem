<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%
    Student student = (Student) session.getAttribute("studentUser");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/student-login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <!-- Welcome Section -->
        <div class="welcome-section glass-card p-4 mb-4 text-white d-flex justify-content-between align-items-center" style="background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%); border-radius: 15px; border: none;">
            <div>
                <h2 class="fw-bold mb-1">Welcome back, <%= student.getName() %>!</h2>
                <p class="mb-0 opacity-75">Member ID: #STUD-<%= student.getId() %> | <%= student.getCourse() %> - <%= student.getYear() %> Year</p>
            </div>
            <div class="d-none d-md-block">
                <span class="badge bg-white text-primary px-3 py-2 rounded-pill shadow-sm"><i class="fas fa-calendar-alt me-1"></i> <%= new java.text.SimpleDateFormat("EEEE, MMM d").format(new java.util.Date()) %></span>
            </div>
        </div>

        <!-- Stats Overview -->
        <div class="row g-4 mb-5">
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 glass-card p-3" style="border-radius: 15px;">
                    <div class="d-flex align-items-center">
                        <div class="icon-wrapper bg-primary-subtle text-primary me-3" style="width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-book-reader fa-2x"></i>
                        </div>
                        <div>
                            <h6 class="text-muted mb-0 small text-uppercase fw-bold">Active Borrowed</h6>
                            <h3 class="fw-bold mb-0 text-dark"><%= request.getAttribute("borrowedCount") != null ? request.getAttribute("borrowedCount") : "0" %></h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 glass-card p-3" style="border-radius: 15px;">
                    <div class="d-flex align-items-center">
                        <div class="icon-wrapper bg-warning-subtle text-warning me-3" style="width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-coins fa-2x"></i>
                        </div>
                        <div>
                            <h6 class="text-muted mb-0 small text-uppercase fw-bold">Pending Fine</h6>
                            <h3 class="fw-bold mb-0 text-dark">₹<%= String.format("%.2f", request.getAttribute("totalFine") != null ? (Double)request.getAttribute("totalFine") : 0.0) %></h3>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 glass-card p-3" style="border-radius: 15px;">
                    <div class="d-flex align-items-center">
                        <div class="icon-wrapper bg-info-subtle text-info me-3" style="width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center;">
                            <i class="fas fa-paper-plane fa-2x"></i>
                        </div>
                        <div>
                            <h6 class="text-muted mb-0 small text-uppercase fw-bold">Pending Requests</h6>
                            <h3 class="fw-bold mb-0 text-dark"><%= request.getAttribute("pendingRequests") != null ? request.getAttribute("pendingRequests") : "0" %></h3>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <h4 class="fw-bold mb-4"><i class="fas fa-bolt text-warning me-2"></i>Quick Actions</h4>
        <div class="row g-4 text-center">
            <div class="col-md-3">
                <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="text-decoration-none">
                    <div class="card h-100 shadow-sm border-0 glass-card p-4 hover-lift" style="border-radius: 20px; transition: transform 0.2s;">
                        <i class="fas fa-search fa-3x text-primary mb-3"></i>
                        <h5 class="fw-bold text-dark">Browse Books</h5>
                        <p class="text-muted small">Explore library catalog and request new books.</p>
                    </div>
                </a>
            </div>
            <div class="col-md-3">
                <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="text-decoration-none">
                    <div class="card h-100 shadow-sm border-0 glass-card p-4 hover-lift" style="border-radius: 20px; transition: transform 0.2s;">
                        <i class="fas fa-book-open fa-3x text-success mb-3"></i>
                        <h5 class="fw-bold text-dark">My Issued Books</h5>
                        <p class="text-muted small">View your currently borrowed books and due dates.</p>
                    </div>
                </a>
            </div>
            <div class="col-md-3">
                <a href="<%= request.getContextPath() %>/StudentFineStatusServlet" class="text-decoration-none">
                    <div class="card h-100 shadow-sm border-0 glass-card p-4 hover-lift" style="border-radius: 20px; transition: transform 0.2s;">
                        <i class="fas fa-wallet fa-3x text-warning mb-3"></i>
                        <h5 class="fw-bold text-dark">Fine Status</h5>
                        <p class="text-muted small">Check your outstanding fines and payment history.</p>
                    </div>
                </a>
            </div>
            <div class="col-md-3">
                <a href="<%= request.getContextPath() %>/StudentProfileServlet" class="text-decoration-none">
                    <div class="card h-100 shadow-sm border-0 glass-card p-4 hover-lift" style="border-radius: 20px; transition: transform 0.2s;">
                        <i class="fas fa-user-circle fa-3x text-secondary mb-3"></i>
                        <h5 class="fw-bold text-dark">Profile</h5>
                        <p class="text-muted small">Manage your account and personal preferences.</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
