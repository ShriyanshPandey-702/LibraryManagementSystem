<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.IssueRecord" %>
<%
    if (session.getAttribute("studentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/jsp/student-login.jsp");
        return;
    }
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<div class="main-content bg-light">
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold"><i class="fas fa-book-reader me-2 text-success"></i>My Issued Books</h3>
            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-1"></i>Back to Dashboard</a>
        </div>

        <div class="glass-card p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">Issue ID</th>
                            <th>Book Title</th>
                            <th>Issue Date</th>
                            <th>Due Date</th>
                            <th>Fine Status</th>
                            <th class="text-end pe-3">Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        List<IssueRecord> records = (List<IssueRecord>) request.getAttribute("issuedBooks");
                        if (records != null && !records.isEmpty()) {
                            for (IssueRecord r : records) {
                                boolean hasFine = r.getFine() > 0;
                    %>
                        <tr>
                            <td class="ps-3 text-muted fw-bold">#<%= r.getIssueId() %></td>
                            <td class="fw-bold text-primary"><i class="fas fa-book me-2 text-muted"></i><%= r.getBookTitle() %></td>
                            <td><span class="text-muted"><i class="fas fa-calendar-alt me-1"></i><%= r.getIssueDate() %></span></td>
                            <td><span class="badge <%= hasFine ? "bg-danger" : "bg-light text-dark border" %>"><%= r.getDueDate() %></span></td>
                            <td class="<%= hasFine ? "text-danger fw-bold" : "text-success" %>">
                                <% if (hasFine) { %>
                                    <i class="fas fa-exclamation-circle me-1"></i> ₹<%= String.format("%.2f", r.getFine()) %>
                                <% } else { %>
                                    <i class="fas fa-check-circle me-1"></i> No Fine
                                <% } %>
                            </td>
                            <td class="text-end pe-3">
                                <% if ("Issued".equalsIgnoreCase(r.getStatus())) { %>
                                    <span class="badge bg-warning text-dark"><i class="fas fa-clock me-1"></i>Currently Issued</span>
                                <% } else if ("Returned".equalsIgnoreCase(r.getStatus())) { %>
                                    <span class="badge bg-success"><i class="fas fa-check me-1"></i>Returned</span>
                                <% } else { %>
                                    <span class="badge bg-secondary"><%= r.getStatus() %></span>
                                <% } %>
                            </td>
                        </tr>
                    <%      }
                        } else {
                    %>
                        <tr>
                            <td colspan="6" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fas fa-book fa-3x mb-3 text-secondary"></i>
                                    <p class="mb-0 fs-5">You have no active issued books.</p>
                                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn btn-outline-primary mt-3">Browse Books to Request</a>
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

<jsp:include page="includes/footer.jsp" />
