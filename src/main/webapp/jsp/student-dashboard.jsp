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

    int pendingConfirmations = 0;
    Object pcObj = request.getAttribute("pendingConfirmations");
    if (pcObj instanceof Integer) pendingConfirmations = (Integer) pcObj;
    else if (pcObj != null) {
        try { pendingConfirmations = Integer.parseInt(pcObj.toString()); } catch (Exception ignored) {}
    }

    int quotaMax = 5;
    Object qObj = request.getAttribute("quotaMax");
    if (qObj instanceof Integer) quotaMax = (Integer) qObj;
    else {
        quotaMax = new dao.IssueDAO().getMaxBorrowLimit();
    }
    int quotaPct = Math.min(100, (int) Math.round(((double) borrowedCount / Math.max(1, quotaMax)) * 100));
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
            <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet" class="btn-lib-secondary me-2">
                <i class="fas fa-clock-rotate-left me-1"></i> Lifetime History
            </a>
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary">
                <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
            </a>
        </div>
    </header>

    <% if (pendingConfirmations > 0) { %>
        <!-- Urgent Pending Issue Confirmations Banner -->
        <div class="alert alert-warning mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3 shadow-sm" role="alert" style="border-left: 4px solid #f59e0b; background-color: rgba(245, 158, 11, 0.1);">
            <div class="d-flex align-items-center gap-3">
                <div style="font-size: 1.75rem; color: #d97706;">
                    <i class="fas fa-bell"></i>
                </div>
                <div>
                    <h5 class="alert-heading mb-1 fw-bold text-dark">Action Required: <%= pendingConfirmations %> Book Loan <%= pendingConfirmations == 1 ? "Assignment" : "Assignments" %> Awaiting Confirmation</h5>
                    <p class="mb-0 text-muted small">The library administrator has assigned a book to you. Please confirm whether you accept or decline this issue.</p>
                </div>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="btn-lib-primary btn-sm px-3 py-2">
                    <i class="fas fa-check-double me-1"></i> Review &amp; Confirm Now
                </a>
            </div>
        </div>
    <% } %>

    <!-- Borrowing Quota Panel -->
    <div class="panel mb-4">
        <div class="panel-body">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <div>
                    <strong class="small text-uppercase" style="letter-spacing: 0.5px;">Borrowing Quota</strong>
                    <span class="text-muted small ms-2">(Maximum <%= quotaMax %> books per student)</span>
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
                <span>Limit: <%= quotaMax %> concurrent loans</span>
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
                <div class="col-sm-6 col-md-4">
                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-magnifying-glass fa-2x text-primary mb-1"></i>
                        <span class="fw-semibold text-dark">Browse Catalog</span>
                        <span class="text-muted small">Search books and check physical copy availability</span>
                    </a>
                </div>
                <div class="col-sm-6 col-md-4">
                    <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-book fa-2x text-primary mb-1"></i>
                        <span class="fw-semibold text-dark">My Borrowed Books</span>
                        <span class="text-muted small">Check active loans, extensions &amp; confirm issue assignments</span>
                    </a>
                </div>
                <div class="col-sm-6 col-md-4">
                    <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-clock-rotate-left fa-2x text-info mb-1"></i>
                        <span class="fw-semibold text-dark">Borrowing History</span>
                        <span class="text-muted small">Lifetime archive of all issued, returned &amp; confirmed books</span>
                    </a>
                </div>
                <div class="col-sm-6 col-md-4">
                    <a href="<%= request.getContextPath() %>/StudentReservationsServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-calendar-check fa-2x text-success mb-1"></i>
                        <span class="fw-semibold text-dark">My Reservations</span>
                        <span class="text-muted small">Track waitlist position and pickup availability</span>
                    </a>
                </div>
                <div class="col-sm-6 col-md-4">
                    <a href="<%= request.getContextPath() %>/StudentFineStatusServlet" class="btn-lib-secondary w-100 d-flex flex-column align-items-center py-4 text-center gap-2">
                        <i class="fas fa-receipt fa-2x text-warning mb-1"></i>
                        <span class="fw-semibold text-dark">Overdue Fines</span>
                        <span class="text-muted small">Review itemized penalty fees and record settlements</span>
                    </a>
                </div>
                <div class="col-sm-6 col-md-4">
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
