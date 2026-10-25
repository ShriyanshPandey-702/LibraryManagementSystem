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

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header" style="max-width: 720px; margin: 0 auto 24px;">
        <div>
            <h1 class="page-title">Book Reservation Process</h1>
            <p class="page-subtitle">Understand how to request library titles for physical loan checkout.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary">
                <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
            </a>
        </div>
    </header>

    <div class="panel text-center" style="max-width: 720px; margin: 0 auto 32px;">
        <div class="panel-body py-5 px-4">
            <div class="mb-4">
                <div class="d-inline-flex align-items-center justify-content-center bg-light text-primary rounded-1 border"
                     style="width: 64px; height: 64px; font-size: 1.75rem;">
                    <i class="fas fa-book-open"></i>
                </div>
            </div>
            <h2 class="h4 fw-bold mb-2">How to Request a Book</h2>
            <p class="text-muted mb-4 mx-auto" style="max-width: 540px; line-height: 1.6;">
                Books must be requested directly from the real-time catalog. If a book has available copies in stock and you are within your active borrowing quota, click <strong>Request</strong> on that book to send a reservation request to the librarian.
            </p>
            <div class="d-flex justify-content-center gap-2 flex-wrap">
                <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary">
                    <i class="fas fa-magnifying-glass me-1"></i> Open Book Catalog
                </a>
                <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn-lib-secondary">
                    Back to Dashboard
                </a>
            </div>
        </div>
    </div>

</main>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Student Self-Service</span>
    </div>
</footer>

<jsp:include page="includes/footer.jsp" />
