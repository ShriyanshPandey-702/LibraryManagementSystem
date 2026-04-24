<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%
    Student student = (Student) session.getAttribute("studentUser");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold"><i class="fas fa-paper-plane me-2 text-primary"></i>Request a Book</h3>
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn btn-outline-secondary">
                <i class="fas fa-arrow-left me-1"></i>Browse Catalog
            </a>
        </div>

        <div class="glass-card" style="max-width: 600px; margin: 0 auto;">
            <div class="text-center mb-4">
                <i class="fas fa-book fa-3x text-primary mb-3"></i>
                <h5 class="fw-bold">Can't find the book you need?</h5>
                <p class="text-muted">Browse the available catalog and use the <strong>Request</strong> button next to any book. Your request will be reviewed by the admin and issued to you.</p>
            </div>
            <hr>
            <div class="text-center">
                <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn btn-primary-custom px-5 fw-bold">
                    <i class="fas fa-search me-2"></i>Browse & Request Books
                </a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

