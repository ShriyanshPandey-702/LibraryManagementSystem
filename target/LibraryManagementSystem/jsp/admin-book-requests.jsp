<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.BookRequest" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold"><i class="fas fa-clipboard-list me-2 text-warning"></i>Book Requests</h3>
            <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-1"></i>Back to Dashboard</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if ("1".equals(request.getParameter("rejected"))) { %>
            <div class="alert alert-info shadow-sm"><i class="fas fa-times-circle me-2"></i>Request rejected successfully.</div>
        <% } %>

        <div class="glass-card p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">Student Name</th>
                            <th>Course / Year</th>
                            <th>Requested Book</th>
                            <th>Date Requested</th>
                            <th class="text-end pe-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        List<BookRequest> pendingRequests = (List<BookRequest>) request.getAttribute("pendingRequests");
                        if (pendingRequests != null && !pendingRequests.isEmpty()) {
                            for (BookRequest req : pendingRequests) {
                                String details = "Student: " + req.getStudentName()
                                        + " | Course: " + req.getCourse()
                                        + " | Year: " + req.getYear()
                                        + " | Book: " + req.getBookTitle()
                                        + " | Date: " + req.getRequestDate();
                    %>
                        <tr>
                            <td class="ps-3 fw-bold"><i class="fas fa-user-graduate me-2 text-muted"></i><%= req.getStudentName() %></td>
                            <td>
                                <span class="badge bg-secondary"><%= req.getCourse() %></span>
                                <span class="badge bg-light text-dark border"><%= req.getYear() %></span>
                            </td>
                            <td class="fw-bold text-primary"><i class="fas fa-book me-1"></i><%= req.getBookTitle() %></td>
                            <td><span class="text-muted small"><i class="fas fa-calendar-alt me-1"></i><%= req.getRequestDate() %></span></td>
                            <td class="text-end pe-3">
                                <a class="btn btn-warning btn-sm shadow-sm fw-bold text-dark me-1" href="<%= request.getContextPath() %>/IssueBookServlet?requestId=<%= req.getId() %>">
                                    <i class="fas fa-hand-holding me-1"></i>Issue
                                </a>
                                <form action="<%= request.getContextPath() %>/AdminBookRequestsServlet" method="post" class="d-inline" onsubmit="return confirm('Reject this request?')">
                                    <input type="hidden" name="action" value="reject">
                                    <input type="hidden" name="requestId" value="<%= req.getId() %>">
                                    <button type="submit" class="btn btn-outline-danger btn-sm shadow-sm">
                                        <i class="fas fa-times me-1"></i>Reject
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <%      }
                        } else {
                    %>
                        <tr>
                            <td colspan="5" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fas fa-check-circle fa-3x mb-3 text-success"></i>
                                    <p class="mb-0 fs-5">No pending book requests.</p>
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

<script>
    function copyDetails(details) {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(details).then(() => {
                alert("Request details copied to clipboard!");
            });
            return;
        }

        const input = document.createElement('textarea');
        input.value = details;
        document.body.appendChild(input);
        input.select();
        document.execCommand('copy');
        document.body.removeChild(input);
        alert("Request details copied to clipboard!");
    }
</script>

<jsp:include page="includes/footer.jsp" />
