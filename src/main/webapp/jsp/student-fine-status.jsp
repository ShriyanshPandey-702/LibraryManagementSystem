<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.IssueRecord" %>
<%
    if (session.getAttribute("studentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    List<IssueRecord> records = (List<IssueRecord>) request.getAttribute("issuedBooks");
    double totalFine = 0.0;
    if (records != null && !records.isEmpty()) {
        for (IssueRecord r : records) {
            if (r.getFine() > 0 && !r.isFinePaid()) {
                totalFine += r.getFine();
            }
        }
    }

    String flashSuccess = (String) session.getAttribute("flashSuccess");
    if (flashSuccess != null) session.removeAttribute("flashSuccess");

    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Overdue Fines &amp; Settlements</h1>
            <p class="page-subtitle">Review accrued late return charges, verify itemized amounts, and record fine settlements.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn-lib-secondary">
                <i class="fas fa-arrow-left me-1"></i> Dashboard
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

    <div class="row g-4 mb-4">
        <!-- Summary Panel -->
        <div class="col-lg-4">
            <div class="panel h-100">
                <div class="panel-header">
                    <h2 class="panel-title">Account Balance</h2>
                </div>
                <div class="panel-body">
                    <div class="mb-3">
                        <span class="text-muted small text-uppercase fw-bold" style="letter-spacing: 0.5px;">Current Outstanding</span>
                        <div class="h2 fw-bold mb-1 <%= totalFine > 0 ? "text-danger" : "text-success" %>">
                            ₹<%= String.format("%.2f", totalFine) %>
                        </div>
                    </div>
                    <div class="border-top pt-3 text-secondary small">
                        <% if (totalFine > 0) { %>
                            <p class="mb-2 text-danger">
                                <i class="fas fa-circle-exclamation me-1"></i> You have pending overdue charges. Settle dues to retain full borrowing privileges.
                            </p>
                        <% } else { %>
                            <p class="mb-2 text-success">
                                <i class="fas fa-circle-check me-1"></i> Your library circulation account is in good standing with zero outstanding dues.
                            </p>
                        <% } %>
                        <div class="text-muted">
                            Fines accrue based on the institutional daily rate for each calendar day beyond the scheduled due date.
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Itemized Records Table Panel -->
        <div class="col-lg-8">
            <div class="panel h-100 mb-0">
                <div class="panel-header">
                    <h2 class="panel-title">Itemized Loan Charges</h2>
                    <span class="text-muted small">All current and historical loans</span>
                </div>

                <div class="table-responsive">
                    <table class="table-lib mb-0">
                        <thead>
                            <tr>
                                <th>Book Title</th>
                                <th>Due Date</th>
                                <th class="text-center">Status</th>
                                <th class="text-end">Fine Amount</th>
                                <th class="text-end" style="width: 160px;">Settlement</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            if (records != null && !records.isEmpty()) {
                                for (IssueRecord r : records) {
                                    boolean hasFine = r.getFine() > 0;
                                    boolean isPaid = r.isFinePaid();
                        %>
                            <tr>
                                <td>
                                    <strong class="book-title"><%= r.getBookTitle() %></strong>
                                    <div class="text-muted small">Loan #<%= r.getIssueId() %></div>
                                </td>
                                <td class="text-muted small"><%= r.getDueDate() %></td>
                                <td class="text-center">
                                    <% if ("Issued".equalsIgnoreCase(r.getStatus())) { %>
                                        <span class="badge-status badge-warning">Active Loan</span>
                                    <% } else { %>
                                        <span class="badge-status badge-neutral">Returned</span>
                                    <% } %>
                                </td>
                                <td class="text-end fw-semibold <%= hasFine && !isPaid ? "text-danger" : "text-muted" %>">
                                    <% if (hasFine) { %>
                                        ₹<%= String.format("%.2f", r.getFine()) %>
                                    <% } else { %>
                                        ₹0.00
                                    <% } %>
                                </td>
                                <td class="text-end">
                                    <% if (hasFine && !isPaid) { %>
                                        <form id="payForm-<%= r.getIssueId() %>" action="<%= request.getContextPath() %>/StudentPayFineServlet" method="post" class="d-inline m-0">
                                            <input type="hidden" name="issueId" value="<%= r.getIssueId() %>">
                                            <button type="button" class="btn-lib-primary btn-sm"
                                                    onclick="confirmSettleFine(<%= r.getIssueId() %>, '<%= String.format("%.2f", r.getFine()) %>', '<%= r.getBookTitle().replace("'", "\\'") %>')">
                                                <i class="fas fa-receipt me-1"></i> Settle Fine
                                            </button>
                                        </form>
                                    <% } else if (hasFine && isPaid) { %>
                                        <span class="badge-status badge-success">
                                            <i class="fas fa-check me-1"></i> Paid
                                        </span>
                                    <% } else { %>
                                        <span class="badge-status badge-neutral">No charge</span>
                                    <% } %>
                                </td>
                            </tr>
                        <%      }
                            } else {
                        %>
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <div class="empty-state-icon">
                                            <i class="fas fa-receipt"></i>
                                        </div>
                                        <h3 class="empty-state-title">No fines on record</h3>
                                        <p class="empty-state-text">
                                            You have no overdue penalties registered across your circulation history.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

</main>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Account Statements</span>
    </div>
</footer>

<script>
function confirmSettleFine(issueId, amount, title) {
    sweetConfirm('Settle Overdue Fine?', 'Record settlement payment of ₹' + amount + ' for "' + title + '"?', 'Yes, Record Payment', function() {
        document.getElementById('payForm-' + issueId).submit();
    });
}
</script>

<jsp:include page="includes/footer.jsp" />
