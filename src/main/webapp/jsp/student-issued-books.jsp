<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.IssueRecord" %>
<%
    if (session.getAttribute("studentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    List<IssueRecord> records = (List<IssueRecord>) request.getAttribute("issuedBooks");

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");

    int count = records != null ? records.size() : 0;
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
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary">
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

    <!-- Loans Panel -->
    <div class="panel">
        <div class="panel-header">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Borrowing Records</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Record" : "Records" %></span>
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
                            <strong class="text-dark"><%= r.getBookTitle() %></strong>
                        </td>
                        <td class="text-secondary small"><%= r.getIssueDate() %></td>
                        <td>
                            <% if (hasFine) { %>
                                <span class="badge-status badge-danger">
                                    <i class="fas fa-circle-exclamation me-1"></i> <%= r.getDueDate() %>
                                </span>
                            <% } else { %>
                                <span class="text-dark"><%= r.getDueDate() %></span>
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
                            <% if (canRenew) { %>
                                <form id="renewForm-<%= r.getIssueId() %>" action="<%= request.getContextPath() %>/StudentRenewBookServlet" method="post" class="d-inline m-0">
                                    <input type="hidden" name="issueId" value="<%= r.getIssueId() %>">
                                    <button type="button" class="btn-lib-primary btn-sm"
                                            onclick="confirmRenewBook(<%= r.getIssueId() %>, '<%= r.getBookTitle().replace("'", "\\'") %>')">
                                        <i class="fas fa-rotate-right me-1"></i> Renew (+7d)
                                    </button>
                                </form>
                            <% } else if (isIssued && hasFine) { %>
                                <span class="text-danger small" title="Overdue penalty must be settled before renewal">
                                    <i class="fas fa-lock me-1"></i> Fine Pending
                                </span>
                            <% } else if (isIssued && r.getRenewCount() >= 2) { %>
                                <span class="text-muted small" title="Maximum extensions reached (2)">
                                    Max Renewals
                                </span>
                            <% } else { %>
                                <span class="text-muted small">—</span>
                            <% } %>
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

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Circulation Ledger</span>
    </div>
</footer>

<script>
function confirmRenewBook(id, title) {
    sweetConfirm('Renew Book Loan?', 'Extend the scheduled due date for "' + title + '" by an additional 7 calendar days?', 'Yes, Extend Loan', function() {
        document.getElementById('renewForm-' + id).submit();
    });
}
</script>

<jsp:include page="includes/footer.jsp" />
