<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%
    Student student = (Student) session.getAttribute("studentUser");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    int borrowedCount = 0;
    Object bObj = request.getAttribute("borrowedCount");
    if (bObj instanceof Integer) borrowedCount = (Integer) bObj;
    else if (bObj != null) {
        try { borrowedCount = Integer.parseInt(bObj.toString()); } catch (Exception ignored) {}
    }

    double totalFine = 0.0;
    Object fObj = request.getAttribute("totalFine");
    if (fObj instanceof Double) totalFine = (Double) fObj;
    else if (fObj != null) {
        try { totalFine = Double.parseDouble(fObj.toString()); } catch (Exception ignored) {}
    }

    int pendingRequests = 0;
    Object pObj = request.getAttribute("pendingRequests");
    if (pObj instanceof Integer) pendingRequests = (Integer) pObj;
    else if (pObj != null) {
        try { pendingRequests = Integer.parseInt(pObj.toString()); } catch (Exception ignored) {}
    }

    int quotaMax = 3;
    int quotaPct = Math.min(100, (int) Math.round(((double) borrowedCount / quotaMax) * 100));
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Student Dashboard</h1>
            <p class="page-subtitle">
                Welcome back, <%= student.getName() %> &bull; 
                <%= student.getCourse() != null && !student.getCourse().isBlank() ? student.getCourse() : "Academic Member" %>
                <% if (student.getYear() != null && !student.getYear().isBlank()) { %> &bull; <%= student.getYear() %> Year<% } %>
                <% if (student.getSection() != null && !student.getSection().isBlank()) { %> (Sec <%= student.getSection() %>)<% } %>
            </p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary">
                <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
            </a>
        </div>
    </header>

    <!-- Borrowing Quota Panel -->
    <div class="panel mb-4">
        <div class="panel-body">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <div>
                    <strong class="text-dark small text-uppercase" style="letter-spacing: 0.5px;">Borrowing Quota</strong>
                    <span class="text-muted small ms-2">(Maximum 3 books per student)</span>
                </div>
                <span class="badge-status <%= borrowedCount >= quotaMax ? "badge-danger" : "badge-neutral" %>">
                    <%= borrowedCount %> of <%= quotaMax %> Active Books Used
                </span>
            </div>
            <div class="progress mb-2" style="height: 8px; background-color: var(--color-surface-muted);">
                <div class="progress-bar <%= borrowedCount >= quotaMax ? "bg-danger" : "bg-dark" %>"
                     role="progressbar" style="width: <%= quotaPct %>%;" aria-valuenow="<%= quotaPct %>" aria-valuemin="0" aria-valuemax="100"></div>
            </div>
            <div class="d-flex justify-content-between align-items-center small text-muted">
                <span><%= quotaMax - borrowedCount > 0 ? "You may borrow " + (quotaMax - borrowedCount) + " more book(s) from the catalog." : "Borrowing limit reached. Please return an existing loan to borrow new titles." %></span>
                <span>Limit: 3 concurrent loans</span>
            </div>
        </div>
    </div>

    <!-- Metrics Grid -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="metric-card">
                <div class="metric-label">Active Loans</div>
                <div class="metric-value"><%= borrowedCount %></div>
                <div class="metric-sub"><i class="fas fa-book me-1"></i> Books currently checked out</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="metric-card">
                <div class="metric-label">Outstanding Fines</div>
                <div class="metric-value <%= totalFine > 0 ? "text-danger" : "" %>">
                    ₹<%= String.format("%.2f", totalFine) %>
                </div>
                <div class="metric-sub">
                    <i class="fas fa-receipt me-1"></i>
                    <%= totalFine > 0 ? "Overdue penalty due for settlement" : "No overdue charges on account" %>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="metric-card">
                <div class="metric-label">Pending Requests</div>
                <div class="metric-value"><%= pendingRequests %></div>
                <div class="metric-sub"><i class="fas fa-inbox me-1"></i> Reservation requests awaiting review</div>
            </div>
        </div>
    </div>

    <!-- Quick Navigation Services Panel -->
    <div class="panel">
        <div class="panel-header">
            <h2 class="panel-title">Library Services</h2>
        </div>
        <div class="panel-body">
            <div class="row g-3">
                <div class="col-sm-6 col-lg-3">
                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-magnifying-glass fa-2x text-primary mb-1"></i>
                        <span class="fw-semibold text-dark">Browse Catalog</span>
                        <span class="text-muted small">Search books and check physical copy availability</span>
                    </a>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-book fa-2x text-primary mb-1"></i>
                        <span class="fw-semibold text-dark">My Borrowed Books</span>
                        <span class="text-muted small">Check due dates and apply for +7 day loan renewals</span>
                    </a>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <a href="<%= request.getContextPath() %>/StudentFineStatusServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-receipt fa-2x text-warning mb-1"></i>
                        <span class="fw-semibold text-dark">Overdue Fines</span>
                        <span class="text-muted small">Review itemized penalty fees and record settlements</span>
                    </a>
                </div>
                <div class="col-sm-6 col-lg-3">
                    <a href="<%= request.getContextPath() %>/StudentProfileServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-id-card fa-2x text-primary mb-1"></i>
                        <span class="fw-semibold text-dark">Profile &amp; Security</span>
                        <span class="text-muted small">View academic records and update account password</span>
                    </a>
                </div>
            </div>
        </div>
    </div>

</main>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Student Self-Service Portal</span>
    </div>
</footer>

<jsp:include page="includes/footer.jsp" />
