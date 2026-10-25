<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.IssueRecord" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage   = (String) request.getAttribute("errorMessage");
    String fineMessage    = (String) request.getAttribute("fineMessage");
    List<IssueRecord> issuedBooks = (List<IssueRecord>) request.getAttribute("issuedBooks");
    int count = issuedBooks != null ? issuedBooks.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Return Book</h1>
            <p class="page-subtitle">Inspect active loans, calculate overdue fees, and check in returned copies.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/IssueBookServlet" class="btn-lib-secondary">
                <i class="fas fa-arrow-right-arrow-left me-1"></i> Issue Book
            </a>
        </div>
    </header>

    <!-- Alerts -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= successMessage %>
        </div>
    <% } %>
    <% if (fineMessage != null && !fineMessage.isEmpty()) { %>
        <div class="alert alert-warning mb-4" role="alert">
            <i class="fas fa-receipt me-2"></i><%= fineMessage %>
        </div>
    <% } %>
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
        </div>
    <% } %>

    <!-- Active Loans Panel -->
    <div class="panel">
        <div class="panel-header">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Active Borrowed Loans</h2>
                <span class="badge-status badge-neutral"><%= count %> Active</span>
            </div>
            <span class="text-muted small">Real-time status based on current fine settings</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 80px;">Loan ID</th>
                        <th>Book Title</th>
                        <th>Student Name</th>
                        <th>Contact</th>
                        <th>Issue Date</th>
                        <th>Due Date</th>
                        <th class="text-end">Overdue Fine</th>
                        <th class="text-end" style="width: 130px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (issuedBooks != null && !issuedBooks.isEmpty()) {
                            for (IssueRecord record : issuedBooks) {
                                boolean hasFine = record.getFine() > 0;
                    %>
                    <tr>
                        <td class="text-muted small">#<%= record.getIssueId() %></td>
                        <td><strong class="text-dark"><%= record.getBookTitle() %></strong></td>
                        <td>
                            <span class="fw-semibold text-secondary"><%= record.getStudentName() %></span>
                        </td>
                        <td class="text-muted small"><%= record.getStudentContact() != null ? record.getStudentContact() : "—" %></td>
                        <td class="text-muted small"><%= record.getIssueDate() %></td>
                        <td>
                            <% if (hasFine) { %>
                                <span class="badge-status badge-danger">
                                    <i class="fas fa-circle-exclamation me-1"></i> Due <%= record.getDueDate() %>
                                </span>
                            <% } else { %>
                                <span class="badge-status badge-neutral">
                                    Due <%= record.getDueDate() %>
                                </span>
                            <% } %>
                        </td>
                        <td class="text-end">
                            <% if (hasFine) { %>
                                <span class="fw-bold text-danger">₹<%= String.format("%.2f", record.getFine()) %></span>
                            <% } else { %>
                                <span class="text-muted small">₹0.00</span>
                            <% } %>
                        </td>
                        <td class="text-end">
                            <form id="returnForm-<%= record.getIssueId() %>" action="<%= request.getContextPath() %>/ReturnBookServlet" method="post" class="d-inline m-0">
                                <input type="hidden" name="issueId" value="<%= record.getIssueId() %>">
                                <button type="button" class="btn-lib-primary btn-sm"
                                        onclick="confirmReturn(<%= record.getIssueId() %>, '<%= record.getBookTitle().replace("'", "\\'") %>', <%= record.getFine() %>)">
                                    <i class="fas fa-check me-1"></i> Return
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="8">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-box-open"></i>
                                </div>
                                <h3 class="empty-state-title">No active loans</h3>
                                <p class="empty-state-text">
                                    All issued books have been checked back into the catalog. There are no outstanding loans currently.
                                </p>
                                <a href="<%= request.getContextPath() %>/IssueBookServlet" class="btn-lib-primary btn-sm">
                                    <i class="fas fa-arrow-right-arrow-left me-1"></i> Issue a Book
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /.page-content -->

<script>
function confirmReturn(issueId, title, fine) {
    let msg = 'Process check-in return for "' + title + '"?';
    if (fine > 0) {
        msg += ' An overdue fine of ₹' + fine.toFixed(2) + ' will be registered for this return.';
    }
    sweetConfirm('Confirm Book Return', msg, 'Yes, Return Book', function() {
        document.getElementById('returnForm-' + issueId).submit();
    });
}
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
