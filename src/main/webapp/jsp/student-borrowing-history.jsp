<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="model.IssueRecord" %>
<%@ page import="model.Student" %>
<%@ page import="dao.IssueDAO" %>
<%
    Student student = (Student) session.getAttribute("studentUser");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }

    List<IssueRecord> historyList = (List<IssueRecord>) request.getAttribute("historyList");
    IssueDAO.LifetimeStats stats = (IssueDAO.LifetimeStats) request.getAttribute("stats");
    if (stats == null) stats = new IssueDAO.LifetimeStats();

    String currentSearch = (String) request.getAttribute("currentSearch");
    if (currentSearch == null) currentSearch = "";

    String currentStatus = (String) request.getAttribute("currentStatus");
    if (currentStatus == null || currentStatus.isEmpty()) currentStatus = "ALL";

    String currentStartDate = (String) request.getAttribute("currentStartDate");
    if (currentStartDate == null) currentStartDate = "";

    String currentEndDate = (String) request.getAttribute("currentEndDate");
    if (currentEndDate == null) currentEndDate = "";

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int displayedCount = (historyList != null) ? historyList.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header mb-4">
        <div>
            <div class="d-flex align-items-center gap-2 mb-1">
                <span class="badge bg-primary-subtle text-primary font-mono small px-2 py-1">LIFETIME ARCHIVE</span>
                <span class="text-muted small">&bull; Student ID #<%= student.getId() %></span>
            </div>
            <h1 class="page-title">Borrowing History &amp; Circulation Archive</h1>
            <p class="page-subtitle">A permanent lifetime record of all library books assigned, confirmed, borrowed, and returned throughout your academic tenure.</p>
        </div>
        <div class="page-header-actions d-flex gap-2">
            <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="btn-lib-secondary">
                <i class="fas fa-book me-1"></i> Active Loans
            </a>
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary">
                <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
            </a>
        </div>
    </header>

    <!-- Flash Alerts -->
    <% if (flashSuccess != null && !flashSuccess.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= flashSuccess %>
        </div>
    <% } %>
    <% if (flashError != null && !flashError.isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= flashError %>
        </div>
    <% } %>

    <!-- Lifetime Summary Metrics Grid -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-md-3">
            <div class="metric-card">
                <div class="metric-label">Lifetime Books</div>
                <div class="metric-value"><%= stats.totalCount %></div>
                <div class="metric-sub"><i class="fas fa-landmark me-1"></i> Total circulation assignments</div>
            </div>
        </div>
        <div class="col-sm-6 col-md-3">
            <div class="metric-card">
                <div class="metric-label">Currently Borrowed</div>
                <div class="metric-value text-primary"><%= stats.activeCount %></div>
                <div class="metric-sub"><i class="fas fa-book-open me-1"></i> Active loans in possession</div>
            </div>
        </div>
        <div class="col-sm-6 col-md-3">
            <div class="metric-card">
                <div class="metric-label">Pending Confirmation</div>
                <div class="metric-value <%= stats.pendingCount > 0 ? "text-warning" : "" %>"><%= stats.pendingCount %></div>
                <div class="metric-sub"><i class="fas fa-hourglass-half me-1"></i> Awaiting your accept/decline</div>
            </div>
        </div>
        <div class="col-sm-6 col-md-3">
            <div class="metric-card">
                <div class="metric-label">Returned Titles</div>
                <div class="metric-value text-success"><%= stats.returnedCount %></div>
                <div class="metric-sub"><i class="fas fa-circle-check me-1"></i> Safely returned to catalog</div>
            </div>
        </div>
    </div>

    <!-- Search & Filter Controls Panel -->
    <div class="panel mb-4">
        <div class="panel-body p-3">
            <form action="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet" method="get" class="row g-2 align-items-center">
                <!-- Search text -->
                <div class="col-md-4">
                    <div class="input-group">
                        <span class="input-group-text bg-transparent border-end-0 text-muted">
                            <i class="fas fa-magnifying-glass"></i>
                        </span>
                        <input type="text" name="search" class="form-control border-start-0" 
                               placeholder="Search title, author, or ISBN..." 
                               value="<%= currentSearch %>">
                    </div>
                </div>

                <!-- Status Filter -->
                <div class="col-md-3">
                    <select name="status" class="form-select">
                        <option value="ALL" <%= "ALL".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>All Statuses (<%= stats.totalCount %>)</option>
                        <option value="ISSUED" <%= "ISSUED".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Currently Borrowed (<%= stats.activeCount %>)</option>
                        <option value="PENDING" <%= "PENDING".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Pending Confirmation (<%= stats.pendingCount %>)</option>
                        <option value="RETURNED" <%= "RETURNED".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Returned Books (<%= stats.returnedCount %>)</option>
                        <option value="OVERDUE" <%= "OVERDUE".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Overdue Loans (<%= stats.overdueCount %>)</option>
                        <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Declined / Cancelled (<%= stats.rejectedCount %>)</option>
                    </select>
                </div>

                <!-- Start Date -->
                <div class="col-sm-6 col-md-2">
                    <input type="date" name="startDate" class="form-control" title="Issue Date From" value="<%= currentStartDate %>" placeholder="From date">
                </div>

                <!-- End Date -->
                <div class="col-sm-6 col-md-2">
                    <input type="date" name="endDate" class="form-control" title="Issue Date To" value="<%= currentEndDate %>" placeholder="To date">
                </div>

                <!-- Filter Actions -->
                <div class="col-12 col-md-1 d-flex gap-1">
                    <button type="submit" class="btn-lib-primary btn-sm w-100" title="Apply filter">
                        Filter
                    </button>
                    <% if (!currentSearch.isEmpty() || !"ALL".equalsIgnoreCase(currentStatus) || !currentStartDate.isEmpty() || !currentEndDate.isEmpty()) { %>
                        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet" class="btn btn-outline-secondary btn-sm" title="Clear all filters">
                            <i class="fas fa-xmark"></i>
                        </a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <!-- Quick Status Navigation Tabs -->
    <div class="d-flex align-items-center gap-2 mb-3 overflow-x-auto pb-1">
        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet?status=ALL" 
           class="badge text-decoration-none px-3 py-2 <%= "ALL".equalsIgnoreCase(currentStatus) ? "bg-dark text-white" : "bg-light text-dark border" %>">
            All Records (<%= stats.totalCount %>)
        </a>
        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet?status=ISSUED" 
           class="badge text-decoration-none px-3 py-2 <%= "ISSUED".equalsIgnoreCase(currentStatus) ? "bg-primary text-white" : "bg-light text-dark border" %>">
            <i class="fas fa-book-open me-1"></i> Active Loans (<%= stats.activeCount %>)
        </a>
        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet?status=PENDING" 
           class="badge text-decoration-none px-3 py-2 <%= "PENDING".equalsIgnoreCase(currentStatus) ? "bg-warning text-dark" : "bg-light text-dark border" %>">
            <i class="fas fa-hourglass-half me-1"></i> Pending Confirmation (<%= stats.pendingCount %>)
        </a>
        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet?status=RETURNED" 
           class="badge text-decoration-none px-3 py-2 <%= "RETURNED".equalsIgnoreCase(currentStatus) ? "bg-success text-white" : "bg-light text-dark border" %>">
            <i class="fas fa-circle-check me-1"></i> Returned (<%= stats.returnedCount %>)
        </a>
        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet?status=OVERDUE" 
           class="badge text-decoration-none px-3 py-2 <%= "OVERDUE".equalsIgnoreCase(currentStatus) ? "bg-danger text-white" : "bg-light text-dark border" %>">
            <i class="fas fa-triangle-exclamation me-1"></i> Overdue (<%= stats.overdueCount %>)
        </a>
        <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet?status=REJECTED" 
           class="badge text-decoration-none px-3 py-2 <%= "REJECTED".equalsIgnoreCase(currentStatus) ? "bg-secondary text-white" : "bg-light text-dark border" %>">
            <i class="fas fa-ban me-1"></i> Declined (<%= stats.rejectedCount %>)
        </a>
    </div>

    <!-- History Table Panel -->
    <div class="panel">
        <div class="panel-header d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Circulation Records</h2>
                <span class="badge-status badge-neutral"><%= displayedCount %> <%= displayedCount == 1 ? "Record" : "Records" %></span>
            </div>
            <span class="text-muted small">Sorted with most recent records first &bull; Lifetime records preserved even if titles are withdrawn</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0 align-middle">
                <thead>
                    <tr>
                        <th style="width: 60px;">ID</th>
                        <th style="min-width: 240px;">Book Information</th>
                        <th style="min-width: 170px;">Lifecycle Dates</th>
                        <th style="min-width: 140px;">Due / Return Date</th>
                        <th class="text-center" style="width: 110px;">Duration</th>
                        <th class="text-center" style="width: 140px;">Loan Status</th>
                        <th class="text-end" style="width: 110px;">Fines</th>
                        <th class="text-end" style="width: 130px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (historyList != null && !historyList.isEmpty()) {
                        LocalDate today = LocalDate.now();
                        for (IssueRecord r : historyList) {
                            boolean isPending = "Pending".equalsIgnoreCase(r.getStatus());
                            boolean isIssued = "Issued".equalsIgnoreCase(r.getStatus());
                            boolean isReturned = "Returned".equalsIgnoreCase(r.getStatus());
                            boolean isRejected = "Rejected".equalsIgnoreCase(r.getStatus());
                            boolean isOverdue = isIssued && r.getDueDate() != null && r.getDueDate().toLocalDate().isBefore(today);
                            long daysBorrowed = r.getDaysBorrowed();
                %>
                    <tr>
                        <!-- ID -->
                        <td class="text-muted small font-mono">
                            #<%= r.getIssueId() %>
                        </td>

                        <!-- Book Information -->
                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <% if (r.getBookCoverImage() != null && !r.getBookCoverImage().isBlank()) { %>
                                    <img src="<%= request.getContextPath() %>/<%= r.getBookCoverImage() %>" alt="Cover" 
                                         style="width: 42px; height: 58px; object-fit: cover; border-radius: 4px; border: 1px solid var(--color-border); flex-shrink: 0;">
                                <% } else { %>
                                    <div style="width: 42px; height: 58px; background-color: var(--color-surface-muted); border-radius: 4px; display: flex; align-items: center; justify-content: center; color: var(--color-ink-muted); font-size: 0.9rem; border: 1px solid var(--color-border); flex-shrink: 0;">
                                        <i class="fas fa-book"></i>
                                    </div>
                                <% } %>
                                <div>
                                    <strong class="book-title text-dark d-block"><%= r.getBookTitle() %></strong>
                                    <div class="small text-muted">
                                        <% if (r.getBookAuthor() != null && !r.getBookAuthor().isBlank()) { %>
                                            <span>By <%= r.getBookAuthor() %></span>
                                        <% } %>
                                        <% if (r.getBookIsbn() != null && !r.getBookIsbn().isBlank()) { %>
                                            <span class="ms-1 font-mono">&bull; ISBN: <%= r.getBookIsbn() %></span>
                                        <% } %>
                                    </div>
                                    <div class="small text-muted font-mono" style="font-size: 0.75rem;">
                                        Catalog ID: #<%= r.getBookId() %>
                                    </div>
                                </div>
                            </div>
                        </td>

                        <!-- Lifecycle Dates -->
                        <td class="small">
                            <div class="d-flex flex-column gap-1">
                                <% if (r.getRequestDate() != null) { %>
                                    <div class="text-muted">
                                        <i class="fas fa-inbox me-1" title="Request Date"></i> Req: <%= r.getRequestDate() %>
                                    </div>
                                <% } %>
                                <% if (r.getAdminIssuedAt() != null) { %>
                                    <div class="text-muted">
                                        <i class="fas fa-user-shield me-1" title="Admin Assigned"></i> Assigned: <%= r.getAdminIssuedAt().toString().substring(0, 10) %>
                                    </div>
                                <% } %>
                                <% if (r.getConfirmedAt() != null) { %>
                                    <div class="text-success">
                                        <i class="fas fa-check-double me-1" title="Student Accepted"></i> Confirmed: <%= r.getConfirmedAt().toString().substring(0, 10) %>
                                    </div>
                                <% } %>
                                <div>
                                    <strong><i class="fas fa-calendar-day me-1 text-primary" title="Official Issue Date"></i> Issued: <%= r.getIssueDate() != null ? r.getIssueDate().toString() : "Pending" %></strong>
                                </div>
                            </div>
                        </td>

                        <!-- Due / Return Date -->
                        <td class="small">
                            <div>Due: <span class="fw-semibold <%= isOverdue ? "text-danger" : "" %>"><%= r.getDueDate() %></span></div>
                            <% if (isReturned && r.getReturnDate() != null) { %>
                                <div class="text-success mt-1">
                                    <i class="fas fa-arrow-turn-down me-1"></i> Returned: <%= r.getReturnDate() %>
                                </div>
                            <% } else if (isIssued) { %>
                                <div class="mt-1">
                                    <% if (isOverdue) { %>
                                        <span class="badge bg-danger-subtle text-danger"><i class="fas fa-circle-exclamation me-1"></i> Overdue</span>
                                    <% } else { %>
                                        <span class="badge bg-info-subtle text-info"><i class="fas fa-clock me-1"></i> In Possession</span>
                                    <% } %>
                                </div>
                            <% } else if (isPending) { %>
                                <div class="text-warning mt-1">
                                    <i class="fas fa-hourglass-start me-1"></i> Awaiting accept
                                </div>
                            <% } else if (isRejected) { %>
                                <div class="text-muted mt-1" title="<%= r.getRejectionReason() != null ? r.getRejectionReason() : "Declined" %>">
                                    <i class="fas fa-ban me-1"></i> Declined
                                </div>
                            <% } %>
                        </td>

                        <!-- Duration -->
                        <td class="text-center font-mono small">
                            <% if (isPending) { %>
                                <span class="text-muted">&mdash;</span>
                            <% } else if (isRejected) { %>
                                <span class="text-muted">0 d</span>
                            <% } else { %>
                                <span class="badge bg-light text-dark border">
                                    <%= daysBorrowed %> <%= daysBorrowed == 1 ? "day" : "days" %>
                                </span>
                            <% } %>
                        </td>

                        <!-- Loan Status -->
                        <td class="text-center">
                            <% if (isPending) { %>
                                <span class="badge bg-warning text-dark">
                                    <i class="fas fa-hourglass-half me-1"></i> Pending Confirm
                                </span>
                            <% } else if (isOverdue) { %>
                                <span class="badge bg-danger text-white">
                                    <i class="fas fa-circle-exclamation me-1"></i> Overdue
                                </span>
                            <% } else if (isIssued) { %>
                                <span class="badge bg-primary text-white">
                                    <i class="fas fa-book-open me-1"></i> Active Loan
                                </span>
                            <% } else if (isReturned) { %>
                                <span class="badge bg-success text-white">
                                    <i class="fas fa-circle-check me-1"></i> Returned
                                </span>
                            <% } else if (isRejected) { %>
                                <span class="badge bg-secondary text-white" title="<%= r.getRejectionReason() != null ? r.getRejectionReason() : "" %>">
                                    <i class="fas fa-ban me-1"></i> Declined
                                </span>
                            <% } else { %>
                                <span class="badge bg-secondary"><%= r.getStatus() %></span>
                            <% } %>
                        </td>

                        <!-- Fines -->
                        <td class="text-end small">
                            <% if (r.getFine() > 0) { %>
                                <span class="fw-bold <%= r.isFinePaid() ? "text-success" : "text-danger" %>">
                                    ₹<%= String.format("%.2f", r.getFine()) %>
                                </span>
                                <div class="small text-muted" style="font-size: 0.7rem;">
                                    <%= r.isFinePaid() ? "Settled" : "Outstanding" %>
                                </div>
                            <% } else { %>
                                <span class="text-muted">₹0.00</span>
                            <% } %>
                        </td>

                        <!-- Actions -->
                        <td class="text-end">
                            <div class="d-flex align-items-center justify-content-end gap-1 flex-wrap">
                                <% if (isPending) { %>
                                    <!-- Accept Button -->
                                    <form action="<%= request.getContextPath() %>/StudentConfirmIssueServlet" method="post" class="d-inline m-0">
                                        <input type="hidden" name="issueId" value="<%= r.getIssueId() %>">
                                        <input type="hidden" name="action" value="accept">
                                        <input type="hidden" name="redirect" value="history">
                                        <button type="submit" class="btn-lib-primary btn-sm px-2 py-1" title="Accept book loan assignment">
                                            <i class="fas fa-check"></i> Accept
                                        </button>
                                    </form>
                                    <!-- Decline Button -->
                                    <button type="button" class="btn btn-outline-danger btn-sm px-2 py-1"
                                            onclick="openRejectIssueModal(<%= r.getIssueId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')"
                                            title="Decline book loan assignment">
                                        <i class="fas fa-xmark"></i>
                                    </button>
                                <% } else if (isIssued) { %>
                                    <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="btn-lib-secondary btn-sm px-2 py-1" title="Manage active loan">
                                        Manage
                                    </a>
                                <% } %>

                                <!-- Review Book (if returned or issued) -->
                                <% if (!isPending && !isRejected) { %>
                                    <button type="button" class="btn-lib-secondary btn-sm px-2 py-1"
                                            onclick="openReviewModal(<%= r.getBookId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')"
                                            title="Rate &amp; review this book">
                                        <i class="fas fa-star text-accent"></i>
                                    </button>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="8" class="text-center py-5">
                            <div class="text-muted">
                                <i class="fas fa-book-bookmark fa-3x mb-3 text-secondary" style="opacity: 0.5;"></i>
                                <h5 class="fw-bold mb-1">No Borrowing Records Found</h5>
                                <p class="small mb-3">
                                    <% if (!currentSearch.isEmpty() || !"ALL".equalsIgnoreCase(currentStatus) || !currentStartDate.isEmpty() || !currentEndDate.isEmpty()) { %>
                                        No loan records match your current filter parameters. Try clearing the search query or status filter.
                                    <% } else { %>
                                        You have not borrowed any books from the library yet.
                                    <% } %>
                                </p>
                                <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary btn-sm">
                                    <i class="fas fa-magnifying-glass me-1"></i> Browse Library Catalog
                                </a>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

</main>

<!-- Decline Issue Confirmation Modal -->
<div class="modal fade" id="rejectIssueModal" tabindex="-1" aria-labelledby="rejectIssueModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
            <form action="<%= request.getContextPath() %>/StudentConfirmIssueServlet" method="post">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="issueId" id="rejectIssueId">
                <input type="hidden" name="redirect" value="history">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title font-display text-danger" id="rejectIssueModalLabel">
                        <i class="fas fa-xmark me-2"></i>Decline Book Loan Assignment
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="small mb-3">
                        Are you sure you want to decline this book loan assignment for: <strong id="rejectIssueTitleText" class="text-dark"></strong>?
                    </p>
                    <div class="mb-3">
                        <label for="rejectReasonInput" class="form-label font-mono small">// REASON FOR DECLINING (OPTIONAL)</label>
                        <textarea name="reason" id="rejectReasonInput" rows="3" class="form-control" placeholder="e.g., Schedule change, course dropped, requested in error..."></textarea>
                    </div>
                    <div class="alert alert-secondary small mb-0">
                        <i class="fas fa-info-circle me-1"></i> Declining will release this book copy back into the open library catalog.
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn-lib-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger btn-sm px-3">Confirm Decline</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Review Book Modal -->
<div class="modal fade" id="reviewModal" tabindex="-1" aria-labelledby="reviewModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
            <form action="<%= request.getContextPath() %>/ReviewServlet" method="post">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="bookId" id="reviewBookId">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title font-display" id="reviewModalLabel">
                        <i class="fas fa-star text-accent me-2"></i>Rate &amp; Review Book
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted small mb-3">
                        Reviewing: <strong id="reviewBookTitleText" class="text-dark"></strong>
                    </p>
                    <div class="mb-3">
                        <label class="form-label font-mono small">// YOUR RATING (1 TO 5 STARS)</label>
                        <select name="rating" id="reviewRatingSelect" class="form-control" required>
                            <option value="5">★★★★★ (5 Stars - Exceptional)</option>
                            <option value="4">★★★★☆ (4 Stars - Very Good)</option>
                            <option value="3" selected>★★★☆☆ (3 Stars - Average)</option>
                            <option value="2">★★☆☆☆ (2 Stars - Below Average)</option>
                            <option value="1">★☆☆☆☆ (1 Star - Poor)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="reviewComments" class="form-label font-mono small">// WRITTEN FEEDBACK</label>
                        <textarea name="reviewText" id="reviewComments" rows="3" class="form-control" placeholder="Share your perspective, highlights, or critique of this book..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn-lib-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-lib-primary btn-sm">Save Rating &amp; Review</button>
                </div>
            </form>
        </div>
    </div>
</div>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Student Lifetime Circulation Archive</span>
    </div>
</footer>

<script>
function openRejectIssueModal(issueId, title) {
    document.getElementById('rejectIssueId').value = issueId;
    document.getElementById('rejectIssueTitleText').textContent = title;
    new bootstrap.Modal(document.getElementById('rejectIssueModal')).show();
}

function openReviewModal(bookId, title) {
    document.getElementById('reviewBookId').value = bookId;
    document.getElementById('reviewBookTitleText').textContent = title;
    new bootstrap.Modal(document.getElementById('reviewModal')).show();
}
</script>

<jsp:include page="includes/footer.jsp" />
