<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
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
            <h3 class="fw-bold"><i class="fas fa-book me-2 text-primary"></i>Available Books</h3>
            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-1"></i>Back to Dashboard</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <!-- Search Form -->
        <div class="glass-card mb-4 p-3">
            <form method="get" action="<%= request.getContextPath() %>/StudentViewBooksServlet" class="row g-2 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="keyword" class="form-control border-start-0" placeholder="Search books by title, author, category or ISBN..." value="<%= request.getAttribute("keyword") != null ? request.getAttribute("keyword") : "" %>">
                    </div>
                </div>
                <div class="col-md-2 d-grid">
                    <button type="submit" class="btn btn-primary-custom"><i class="fas fa-search me-1"></i>Search</button>
                </div>
                <div class="col-md-2 d-grid">
                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn btn-light border"><i class="fas fa-sync-alt me-1"></i>Clear</a>
                </div>
            </form>
        </div>

        <div class="glass-card p-0 overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">ID</th>
                            <th>Title</th>
                            <th>Author</th>
                            <th>Category</th>
                            <th>ISBN</th>
                            <th>Rack No</th>
                            <th>Status</th>
                            <th class="text-end pe-3">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        List<Book> books = (List<Book>) request.getAttribute("books");
                        if (books != null && !books.isEmpty()) {
                            for (Book book : books) {
                                boolean inStock = book.getQuantity() > 0;
                    %>
                        <tr>
                            <td class="ps-3 text-muted fw-bold">#<%= book.getBookId() %></td>
                            <td class="fw-bold"><%= book.getTitle() %></td>
                            <td><%= book.getAuthor() %></td>
                            <td><span class="badge bg-secondary"><%= book.getCategory() != null ? book.getCategory() : "N/A" %></span></td>
                            <td class="text-muted small"><%= book.getIsbn() != null ? book.getIsbn() : "N/A" %></td>
                            <td class="text-muted small"><%= book.getRackNo() != null ? book.getRackNo() : "N/A" %></td>
                            <td>
                                <% if (inStock) { %>
                                    <span class="badge bg-success rounded-pill"><i class="fas fa-check me-1"></i>Available</span>
                                <% } else { %>
                                    <span class="badge bg-danger rounded-pill"><i class="fas fa-times me-1"></i>Out of Stock</span>
                                <% } %>
                            </td>
                            <td class="text-end pe-3">
                                <% if (inStock) { %>
                                <form action="<%= request.getContextPath() %>/StudentBookRequestServlet" method="post" class="m-0" onsubmit="return confirm('Do you want to request <%= book.getTitle().replace("'", "\\'") %>?');">
                                    <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                                    <button type="submit" class="btn btn-primary-custom btn-sm shadow-sm"><i class="fas fa-hand-paper me-1"></i> Request</button>
                                </form>
                                <% } else { %>
                                    <button class="btn btn-secondary btn-sm disabled"><i class="fas fa-ban me-1"></i> Unavailable</button>
                                <% } %>
                            </td>
                        </tr>
                    <%      }
                        } else {
                    %>
                        <tr>
                            <td colspan="8" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fas fa-book-open fa-3x mb-3"></i>
                                    <p class="mb-0 fs-5">No books match your search or the catalog is empty.</p>
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
