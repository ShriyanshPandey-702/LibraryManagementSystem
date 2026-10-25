<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.IssueRecord" %>
<%
    if (session.getAttribute("studentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    List<IssueRecord> records = (List<IssueRecord>) request.getAttribute("issuedBooks");
    List<IssueRecord> pendingList = (List<IssueRecord>) request.getAttribute("pendingConfirmations");

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int count = records != null ? records.size() : 0;
    int pendingCount = pendingList != null ? pendingList.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">My Borrowed Books</h1>
            <p class="page-subtitle">Track your circulation history, verify due dates, and apply for loan extensions.</p>
        </div>
        <div class="page-header-actions d-flex gap-2">
            <a href="<%= request.getContextPath() %>/StudentBorrowingHistoryServlet" class="btn-lib-secondary">
                <i class="fas fa-clock-rotate-left me-1"></i> Lifetime History
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

    <!-- Pending Issue Confirmations Panel -->
    <% if (pendingList != null && !pendingList.isEmpty()) { %>
        <div class="panel mb-4" style="border: 2px solid #f59e0b; background-color: var(--color-surface);">
            <div class="panel-header" style="background-color: rgba(245, 158, 11, 0.08); border-bottom: 1px solid rgba(245, 158, 11, 0.2);">
                <div class="d-flex align-items-center gap-2">
                    <i class="fas fa-bell text-warning"></i>
                    <h2 class="panel-title text-warning-emphasis">Pending Book Issue Confirmations</h2>
                    <span class="badge bg-warning text-dark px-2"><%= pendingCount %> Action Required</span>
                </div>
                <span class="text-muted small">Please confirm whether you accept or decline each issued book before it is finalized.</span>
            </div>
            <div class="panel-body p-0">
                <div class="table-responsive">
                    <table class="table-lib mb-0">
                        <thead>
                            <tr style="background-color: rgba(245, 158, 11, 0.04);">
                                <th>Book Title &amp; Details</th>
                                <th>Assigned By Admin</th>
                                <th>Expected Due Date</th>
                                <th class="text-center">Status</th>
                                <th class="text-end" style="width: 220px;">Confirmation</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (IssueRecord p : pendingList) { %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-3">
                                            <% if (p.getBookCoverImage() != null && !p.getBookCoverImage().isBlank()) { %>
                                                <img src="<%= request.getContextPath() %>/<%= p.getBookCoverImage() %>" alt="Cover" style="width: 36px; height: 50px; object-fit: cover; border-radius: 4px; border: 1px solid var(--color-border);">
                                            <% } else { %>
                                                <div style="width: 36px; height: 50px; background-color: var(--color-surface-muted); border-radius: 4px; display: flex; align-items: center; justify-content: center; color: var(--color-ink-muted); font-size: 0.8rem; border: 1px solid var(--color-border);">
                                                    <i class="fas fa-book"></i>
                                                </div>
                                            <% } %>
                                            <div>
                                                <strong class="book-title text-dark d-block"><%= p.getBookTitle() %></strong>
                                                <span class="text-muted small">
                                                    <%= p.getBookAuthor() != null && !p.getBookAuthor().isBlank() ? "By " + p.getBookAuthor() : "" %>
                                                    <%= p.getBookIsbn() != null && !p.getBookIsbn().isBlank() ? " &bull; ISBN: " + p.getBookIsbn() : "" %>
                                                </span>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="small text-muted">
                                        <%= p.getAdminIssuedAt() != null ? p.getAdminIssuedAt().toString().substring(0, 16) : (p.getIssueDate() != null ? p.getIssueDate().toString() : "Recent") %>
                                    </td>
                                    <td>
                                        <span class="loan-due-date"><%= p.getDueDate() %></span>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-warning text-dark">
                                            <i class="fas fa-hourglass-half me-1"></i> Awaiting Your Confirmation
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <div class="d-flex align-items-center justify-content-end gap-2">
                                            <form action="<%= request.getContextPath() %>/StudentConfirmIssueServlet" method="post" class="d-inline m-0">
                                                <input type="hidden" name="issueId" value="<%= p.getIssueId() %>">
                                                <input type="hidden" name="action" value="accept">
                                                <button type="submit" class="btn-lib-primary btn-sm px-3" title="Accept and finalize loan">
                                                    <i class="fas fa-check me-1"></i> Accept
                                                </button>
                                            </form>
                                            <button type="button" class="btn btn-outline-danger btn-sm px-2"
                                                    onclick="openRejectIssueModal(<%= p.getIssueId() %>, '<%= p.getBookTitle().replace("'", "\\'") %>')"
                                                    title="Decline this book issue assignment">
                                                <i class="fas fa-xmark me-1"></i> Decline
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <% } %>

    <!-- Loans Panel -->
    <div class="panel">
        <div class="panel-header">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Active Borrowed Books</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Active Loan" : "Active Loans" %></span>
            </div>
            <span class="text-muted small">Extensions subject to 2-renewal cap and zero overdue penalties</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 80px;">Loan ID</th>
                        <th>Book Title</th>
                        <th>Issue Date</th>
                        <th>Due Date</th>
                        <th class="text-end">Overdue Fines</th>
                        <th class="text-center">Loan Status</th>
                        <th class="text-center">Extensions</th>
                        <th class="text-end" style="width: 150px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (records != null && !records.isEmpty()) {
                        for (IssueRecord r : records) {
                            boolean isIssued = "Issued".equalsIgnoreCase(r.getStatus());
                            boolean hasFine = r.getFine() > 0;
                            boolean canRenew = isIssued && !hasFine && r.getRenewCount() < 2;
                %>
                    <tr>
                        <td class="text-muted small">#<%= r.getIssueId() %></td>
                        <td>
                            <strong class="book-title"><%= r.getBookTitle() %></strong>
                        </td>
                        <td class="small text-muted"><%= r.getIssueDate() %></td>
                        <td>
                            <% if (hasFine) { %>
                                <span class="badge-status badge-danger">
                                    <i class="fas fa-circle-exclamation me-1"></i> <%= r.getDueDate() %>
                                </span>
                            <% } else { %>
                                <span class="loan-due-date"><%= r.getDueDate() %></span>
                            <% } %>
                        </td>
                        <td class="text-end">
                            <% if (hasFine) { %>
                                <span class="fw-bold text-danger">₹<%= String.format("%.2f", r.getFine()) %></span>
                            <% } else { %>
                                <span class="text-muted small">₹0.00</span>
                            <% } %>
                        </td>
                        <td class="text-center">
                            <% if (isIssued) { %>
                                <span class="badge-status badge-warning">Active Loan</span>
                            <% } else { %>
                                <span class="badge-status badge-success">Returned</span>
                            <% } %>
                        </td>
                        <td class="text-center">
                            <span class="badge-status badge-neutral">
                                <%= r.getRenewCount() %>/2
                            </span>
                        </td>
                        <td class="text-end">
                            <div class="d-flex align-items-center justify-content-end gap-1 flex-wrap">
                                <% if (isIssued) { %>
                                    <!-- Return Book Early -->
                                    <form id="returnForm-<%= r.getIssueId() %>" action="<%= request.getContextPath() %>/StudentReturnBookServlet" method="post" class="d-inline m-0">
                                        <input type="hidden" name="issueId" value="<%= r.getIssueId() %>">
                                        <button type="button" class="btn-lib-secondary btn-sm"
                                                onclick="confirmReturnBook(<%= r.getIssueId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')"
                                                title="Return this book before or on the due date">
                                            <i class="fas fa-arrow-turn-down me-1"></i> Return
                                        </button>
                                    </form>

                                    <!-- Renew Book -->
                                    <% if (canRenew) { %>
                                        <form id="renewForm-<%= r.getIssueId() %>" action="<%= request.getContextPath() %>/StudentRenewBookServlet" method="post" class="d-inline m-0">
                                            <input type="hidden" name="issueId" value="<%= r.getIssueId() %>">
                                            <button type="button" class="btn-lib-primary btn-sm"
                                                    onclick="confirmRenewBook(<%= r.getIssueId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')"
                                                    title="Extend due date">
                                                <i class="fas fa-rotate-right me-1"></i> Renew
                                            </button>
                                        </form>
                                    <% } %>

                                    <!-- Report Lost or Damaged -->
                                    <button type="button" class="btn-lib-secondary btn-sm text-danger"
                                            onclick="openReportModal(<%= r.getIssueId() %>, <%= r.getBookId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')"
                                            title="Report as lost or damaged">
                                        <i class="fas fa-triangle-exclamation"></i> Report
                                    </button>
                                <% } %>

                                <!-- Review Book -->
                                <button type="button" class="btn-lib-secondary btn-sm"
                                        onclick="openReviewModal(<%= r.getBookId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')"
                                        title="Write or edit review">
                                    <i class="fas fa-star text-accent"></i> Review
                                </button>
                            </div>
                        </td>
                    </tr>
                <%      }
                    } else {
                %>
                    <tr>
                        <td colspan="8">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-book"></i>
                                </div>
                                <h3 class="empty-state-title">No borrowed books</h3>
                                <p class="empty-state-text">
                                    You currently have no active or historical loans recorded on your student account.
                                </p>
                                <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-primary btn-sm">
                                    <i class="fas fa-magnifying-glass me-1"></i> Browse Catalog
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

<!-- Report Lost/Damaged Modal -->
<div class="modal fade" id="reportModal" tabindex="-1" aria-labelledby="reportModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
            <form action="<%= request.getContextPath() %>/StudentReportBookServlet" method="post">
                <input type="hidden" name="issueId" id="reportIssueId">
                <input type="hidden" name="bookId" id="reportBookId">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title font-display" id="reportModalLabel">
                        <i class="fas fa-triangle-exclamation text-danger me-2"></i>Report Lost or Damaged Book
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted small mb-3">
                        Reporting book: <strong id="reportBookTitleText" class="text-dark"></strong>
                    </p>
                    <div class="mb-3">
                        <label for="reportTypeSelect" class="form-label font-mono small">// INCIDENT TYPE</label>
                        <select name="reportType" id="reportTypeSelect" class="form-control" required>
                            <option value="Damaged">Damaged Physical Copy</option>
                            <option value="Lost">Lost / Unrecoverable Book</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="reportDesc" class="form-label font-mono small">// DESCRIPTION OF ISSUE</label>
                        <textarea name="description" id="reportDesc" rows="3" class="form-control" placeholder="Provide details regarding the damage or circumstances of loss..." required></textarea>
                    </div>
                    <div class="alert alert-warning small mb-0">
                        <i class="fas fa-info-circle me-1"></i> Library administrators will inspect this incident. Any replacement or repair assessment fee will be reflected in your Overdue Fines &amp; Settlements page.
                    </div>
                </div>
                <div class="modal-footer border-top">
                    <button type="button" class="btn-lib-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-lib-primary btn-sm">Submit Incident Report</button>
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

<!-- Decline Issue Confirmation Modal -->
<div class="modal fade" id="rejectIssueModal" tabindex="-1" aria-labelledby="rejectIssueModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content" style="background-color: var(--color-surface); border: 1px solid var(--color-border);">
            <form action="<%= request.getContextPath() %>/StudentConfirmIssueServlet" method="post">
                <input type="hidden" name="action" value="reject">
                <input type="hidden" name="issueId" id="rejectIssueId">
                <div class="modal-header border-bottom">
                    <h5 class="modal-title font-display text-danger" id="rejectIssueModalLabel">
                        <i class="fas fa-xmark me-2"></i>Decline Book Loan Assignment
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="small mb-3">
                        Are you sure you want to decline this book loan for: <strong id="rejectIssueTitleText" class="text-dark"></strong>?
                    </p>
                    <div class="mb-3">
                        <label for="rejectReasonInput" class="form-label font-mono small">// REASON FOR DECLINING (OPTIONAL)</label>
                        <textarea name="reason" id="rejectReasonInput" rows="3" class="form-control" placeholder="e.g., Requested by mistake, schedule conflict, no longer needed..."></textarea>
                    </div>
                    <div class="alert alert-secondary small mb-0">
                        <i class="fas fa-info-circle me-1"></i> The library will be notified and this book copy will be returned to the open catalog for other students.
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

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Circulation Ledger</span>
    </div>
</footer>

<script>
function openRejectIssueModal(issueId, title) {
    document.getElementById('rejectIssueId').value = issueId;
    document.getElementById('rejectIssueTitleText').textContent = title;
    new bootstrap.Modal(document.getElementById('rejectIssueModal')).show();
}

function confirmRenewBook(id, title) {
    sweetConfirm('Renew Book Loan?', 'Extend the scheduled due date for "' + title + '" according to institutional policy?', 'Yes, Extend Loan', function() {
        document.getElementById('renewForm-' + id).submit();
    });
}

function confirmReturnBook(id, title) {
    sweetConfirm('Return Book Now?', 'Return "' + title + '" today? Any accrued fine will be finalized and the physical copy returned to circulation.', 'Yes, Return Book', function() {
        document.getElementById('returnForm-' + id).submit();
    });
}

function openReportModal(issueId, bookId, title) {
    document.getElementById('reportIssueId').value = issueId;
    document.getElementById('reportBookId').value = bookId;
    document.getElementById('reportBookTitleText').textContent = title;
    new bootstrap.Modal(document.getElementById('reportModal')).show();
}

function openReviewModal(bookId, title) {
    document.getElementById('reviewBookId').value = bookId;
    document.getElementById('reviewBookTitleText').textContent = title;
    new bootstrap.Modal(document.getElementById('reviewModal')).show();
}
</script>

<jsp:include page="includes/footer.jsp" />
