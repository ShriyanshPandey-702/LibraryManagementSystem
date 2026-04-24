<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.IssueRecord" %>
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
            <h3 class="fw-bold"><i class="fas fa-undo me-2 text-info"></i>Return Book</h3>
            <a href="<%= request.getContextPath() %>/IssueBookServlet" class="btn btn-outline-warning"><i class="fas fa-hand-holding me-1"></i>Issue Book</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% String fineMessage = (String) request.getAttribute("fineMessage"); %>

        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if (fineMessage != null) { %>
            <div class="alert alert-warning shadow-sm"><i class="fas fa-coins me-2"></i><%= fineMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <div class="glass-card p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">Issue ID</th>
                            <th>Book Title</th>
                            <th>Student Name</th>
                            <th>Contact</th>
                            <th>Issue Date</th>
                            <th>Due Date</th>
                            <th>Current Fine</th>
                            <th class="text-end pe-3">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<IssueRecord> issuedBooks = (List<IssueRecord>) request.getAttribute("issuedBooks");
                            if (issuedBooks != null && !issuedBooks.isEmpty()) {
                                for (IssueRecord record : issuedBooks) {
                                    boolean hasFine = record.getFine() > 0;
                        %>
                        <tr class="<%= hasFine ? "table-danger" : "" %>">
                            <td class="ps-3 fw-bold text-muted">#<%= record.getIssueId() %></td>
                            <td class="fw-bold"><%= record.getBookTitle() %></td>
                            <td><i class="fas fa-user-graduate me-1 text-muted"></i><%= record.getStudentName() %></td>
                            <td><%= record.getStudentContact() %></td>
                            <td><span class="badge bg-light text-dark border"><%= record.getIssueDate() %></span></td>
                            <td><span class="badge <%= hasFine ? "bg-danger" : "bg-light text-dark border" %>"><%= record.getDueDate() %></span></td>
                            <td class="<%= hasFine ? "text-danger fw-bold" : "text-success" %>">
                                ₹<%= String.format("%.2f", record.getFine()) %>
                            </td>
                            <td class="text-end pe-3">
                                <form action="<%= request.getContextPath() %>/ReturnBookServlet" method="post" class="m-0" onsubmit="return confirm('Confirm return for <%= record.getBookTitle().replace("'", "\\'") %>?');">
                                    <input type="hidden" name="issueId" value="<%= record.getIssueId() %>">
                                    <button class="btn btn-sm btn-success shadow-sm" type="submit">
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
                            <td colspan="8" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fas fa-check-circle fa-3x mb-3 text-success"></i>
                                    <p class="mb-0 fs-5">All issued books have been returned.</p>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mt-4">
            <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn btn-secondary"><i class="fas fa-arrow-left me-1"></i> Back to Dashboard</a>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
