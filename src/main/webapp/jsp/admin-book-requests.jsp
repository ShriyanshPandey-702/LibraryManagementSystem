<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.BookRequest" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    String successMessage = (String) request.getAttribute("successMessage");
    List<BookRequest> pendingRequests = (List<BookRequest>) request.getAttribute("pendingRequests");
    int count = pendingRequests != null ? pendingRequests.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Student Book Requests</h1>
            <p class="page-subtitle">Review incoming reservation requests from registered students and approve for circulation.</p>
        </div>
        <div class="page-header-actions">
            <span class="badge-status <%= count > 0 ? "badge-warning" : "badge-neutral" %>">
                <i class="fas fa-clock me-1"></i> <%= count %> Pending <%= count == 1 ? "Request" : "Requests" %>
            </span>
        </div>
    </header>

    <!-- Alerts -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= successMessage %>
        </div>
    <% } %>
    <% if ("1".equals(request.getParameter("rejected"))) { %>
        <div class="alert alert-info mb-4" role="alert">
            <i class="fas fa-circle-info me-2"></i> The student reservation request was rejected successfully.
        </div>
    <% } %>

    <!-- Requests Table Panel -->
    <div class="panel">
        <div class="panel-header">
            <h2 class="panel-title">Pending Queue</h2>
            <span class="text-muted small">Requests ordered chronologically</span>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th>Student Borrower</th>
                        <th>Academic Course</th>
                        <th>Year &amp; Section</th>
                        <th>Requested Book Title</th>
                        <th>Request Date</th>
                        <th class="text-end" style="width: 220px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (pendingRequests != null && !pendingRequests.isEmpty()) {
                            for (BookRequest req : pendingRequests) {
                                String studentInitial = req.getStudentName() != null && !req.getStudentName().isEmpty()
                                    ? req.getStudentName().substring(0, 1).toUpperCase() : "S";
                    %>
                    <tr>
                        <td>
                            <div class="d-flex align-items-center gap-2">
                                <span class="d-inline-flex align-items-center justify-content-center bg-light fw-bold rounded-1 border"
                                      style="width: 28px; height: 28px; font-size: 0.8rem;">
                                    <%= studentInitial %>
                                </span>
                                <div>
                                    <strong><%= req.getStudentName() %></strong>
                                    <div class="text-muted small">Student #<%= req.getStudentId() %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span><%= req.getCourse() != null ? req.getCourse() : "—" %></span>
                        </td>
                        <td>
                            <span class="badge-status badge-neutral"><%= req.getYear() != null ? req.getYear() : "N/A" %></span>
                        </td>
                        <td>
                            <div class="fw-semibold">
                                <i class="fas fa-book me-1 text-muted"></i><%= req.getBookTitle() %>
                            </div>
                        </td>
                        <td class="text-muted small">
                            <%= req.getRequestDate() %>
                        </td>
                        <td class="text-end">
                            <div class="d-inline-flex gap-2">
                                <a href="<%= request.getContextPath() %>/IssueBookServlet?requestId=<%= req.getId() %>"
                                   class="btn-lib-primary btn-sm" title="Approve and open loan issue form">
                                    <i class="fas fa-check me-1"></i> Issue Loan
                                </a>
                                <form id="rejectForm-<%= req.getId() %>" action="<%= request.getContextPath() %>/AdminBookRequestsServlet" method="post" class="d-inline m-0">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="requestId" value="<%= req.getId() %>">
                                    <button type="button" class="btn-lib-danger btn-sm"
                                            onclick="confirmReject(<%= req.getId() %>, '<%= req.getStudentName().replace("'", "\\'") %>', '<%= req.getBookTitle().replace("'", "\\'") %>')">
                                        <i class="fas fa-xmark me-1"></i> Reject
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="6">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-inbox"></i>
                                </div>
                                <h3 class="empty-state-title">No pending requests</h3>
                                <p class="empty-state-text">
                                    There are currently no book reservation requests awaiting administrative review.
                                </p>
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
function confirmReject(reqId, studentName, bookTitle) {
    sweetConfirm('Reject Request?', 'Decline the book request for "' + bookTitle + '" submitted by ' + studentName + '?', 'Yes, Reject', function() {
        document.getElementById('rejectForm-' + reqId).submit();
    });
}
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
