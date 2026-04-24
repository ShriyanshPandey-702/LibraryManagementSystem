<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="fw-bold text-dark"><i class="fas fa-chart-line me-2 text-primary"></i>Admin Dashboard</h2>
            <div class="text-muted">Welcome, Admin!</div>
        </div>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="stat-card bg-gradient-primary">
                    <i class="fas fa-book icon"></i>
                    <h6 class="text-uppercase fw-bold mb-2">Total Books</h6>
                    <h2 class="display-5 fw-bold mb-0"><%= request.getAttribute("totalBooks") != null ? request.getAttribute("totalBooks") : "0" %></h2>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card bg-gradient-success">
                    <i class="fas fa-layer-group icon"></i>
                    <h6 class="text-uppercase fw-bold mb-2">Total Quantity</h6>
                    <h2 class="display-5 fw-bold mb-0"><%= request.getAttribute("totalQuantity") != null ? request.getAttribute("totalQuantity") : "0" %></h2>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card bg-gradient-warning">
                    <i class="fas fa-exclamation-triangle icon"></i>
                    <h6 class="text-uppercase fw-bold mb-2">Low Stock (≤ 2)</h6>
                    <h2 class="display-5 fw-bold mb-0"><%= request.getAttribute("lowStock") != null ? request.getAttribute("lowStock") : "0" %></h2>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card bg-gradient-info">
                    <i class="fas fa-bell icon"></i>
                    <h6 class="text-uppercase fw-bold mb-2">Pending Requests</h6>
                    <% Integer pendingRequests = (Integer) request.getAttribute("pendingRequests");
                       int pendingCount = pendingRequests == null ? 0 : pendingRequests; %>
                    <h2 class="display-5 fw-bold mb-0"><%= pendingCount %></h2>
                </div>
            </div>
        </div>

        <h4 class="fw-bold mb-3">Quick Actions</h4>
        <div class="row g-3">
            <div class="col-md-2 col-sm-4 col-6">
                <a href="<%= request.getContextPath() %>/AddBookServlet" class="btn btn-outline-primary w-100 py-3 rounded-3 shadow-sm d-flex flex-column align-items-center h-100 justify-content-center">
                    <i class="fas fa-plus-circle fa-2x mb-2"></i>
                    <span class="fw-bold">Add Book</span>
                </a>
            </div>
            <div class="col-md-2 col-sm-4 col-6">
                <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn btn-outline-success w-100 py-3 rounded-3 shadow-sm d-flex flex-column align-items-center h-100 justify-content-center">
                    <i class="fas fa-list fa-2x mb-2"></i>
                    <span class="fw-bold">View Books</span>
                </a>
            </div>
            <div class="col-md-2 col-sm-4 col-6">
                <a href="<%= request.getContextPath() %>/IssueBookServlet" class="btn btn-outline-warning w-100 py-3 rounded-3 shadow-sm d-flex flex-column align-items-center h-100 justify-content-center">
                    <i class="fas fa-hand-holding fa-2x mb-2"></i>
                    <span class="fw-bold">Issue Book</span>
                </a>
            </div>
            <div class="col-md-2 col-sm-4 col-6">
                <a href="<%= request.getContextPath() %>/ReturnBookServlet" class="btn btn-outline-info w-100 py-3 rounded-3 shadow-sm d-flex flex-column align-items-center h-100 justify-content-center">
                    <i class="fas fa-undo fa-2x mb-2"></i>
                    <span class="fw-bold">Return Book</span>
                </a>
            </div>
            <div class="col-md-2 col-sm-4 col-6">
                <a href="<%= request.getContextPath() %>/AdminBookRequestsServlet" class="btn btn-outline-secondary w-100 py-3 rounded-3 shadow-sm d-flex flex-column align-items-center h-100 justify-content-center">
                    <i class="fas fa-bell fa-2x mb-2"></i>
                    <span class="fw-bold">Requests
                    <% if (pendingCount > 0) { %><span class="badge bg-danger ms-1 rounded-pill"><%= pendingCount %></span><% } %></span>
                </a>
            </div>
            <div class="col-md-2 col-sm-4 col-6">
                <a href="<%= request.getContextPath() %>/FineSettingsServlet" class="btn btn-outline-dark w-100 py-3 rounded-3 shadow-sm d-flex flex-column align-items-center h-100 justify-content-center">
                    <i class="fas fa-cog fa-2x mb-2"></i>
                    <span class="fw-bold">Fine Settings</span>
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
