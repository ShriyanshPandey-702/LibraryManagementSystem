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
            <h3 class="fw-bold"><i class="fas fa-coins me-2 text-warning"></i>Fine Status</h3>
            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-1"></i>Back to Dashboard</a>
        </div>

        <%
            List<IssueRecord> records = (List<IssueRecord>) request.getAttribute("issuedBooks");
            double totalFine = 0.0;
            if (records != null && !records.isEmpty()) {
                for (IssueRecord r : records) {
                    if (r.getFine() > 0) {
                        totalFine += r.getFine();
                    }
                }
            }
        %>
        
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="glass-card bg-white border-start border-warning border-4 shadow-sm p-4 h-100">
                    <h5 class="text-muted fw-bold mb-3">Total Outstanding Fine</h5>
                    <h2 class="<%= totalFine > 0 ? "text-danger" : "text-success" %> fw-bold">
                        ₹<%= String.format("%.2f", totalFine) %>
                    </h2>
                    <% if (totalFine > 0) { %>
                        <p class="text-muted small mt-2 mb-0"><i class="fas fa-exclamation-triangle me-1 text-warning"></i> Please pay fines to the librarian.</p>
                    <% } else { %>
                        <p class="text-muted small mt-2 mb-0"><i class="fas fa-check-circle me-1 text-success"></i> Your account is in good standing.</p>
                    <% } %>
                </div>
            </div>
            <div class="col-md-8">
                <div class="glass-card p-0 overflow-hidden h-100">
                    <div class="table-responsive h-100">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th class="ps-3">Book Title</th>
                                    <th>Status</th>
                                    <th>Due Date</th>
                                    <th class="text-end pe-3">Fine Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                if (records != null && !records.isEmpty()) {
                                    for (IssueRecord r : records) {
                                        boolean hasFine = r.getFine() > 0;
                            %>
                                <tr class="<%= hasFine ? "table-danger" : "" %>">
                                    <td class="ps-3 fw-bold"><i class="fas fa-book me-2 text-muted"></i><%= r.getBookTitle() %></td>
                                    <td>
                                        <% if ("Issued".equalsIgnoreCase(r.getStatus())) { %>
                                            <span class="badge bg-warning text-dark"><i class="fas fa-clock me-1"></i>Issued</span>
                                        <% } else if ("Returned".equalsIgnoreCase(r.getStatus())) { %>
                                            <span class="badge bg-success"><i class="fas fa-check me-1"></i>Returned</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary"><%= r.getStatus() %></span>
                                        <% } %>
                                    </td>
                                    <td><span class="text-muted"><%= r.getDueDate() %></span></td>
                                    <td class="text-end pe-3 <%= hasFine ? "text-danger fw-bold" : "text-success" %>">
                                        <% if (hasFine) { %>
                                            ₹<%= String.format("%.2f", r.getFine()) %>
                                        <% } else { %>
                                            <i class="fas fa-check"></i> ₹0.00
                                        <% } %>
                                    </td>
                                </tr>
                            <%      }
                                } else {
                            %>
                                <tr>
                                    <td colspan="4" class="text-center py-5">
                                        <div class="text-muted">
                                            <i class="fas fa-shield-alt fa-3x mb-3 text-success"></i>
                                            <p class="mb-0 fs-5">No fine records found.</p>
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
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
