<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
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
            <h3 class="fw-bold"><i class="fas fa-book-open me-2 text-primary"></i>Library Catalog</h3>
            <a href="<%= request.getContextPath() %>/AddBookServlet" class="btn btn-primary-custom"><i class="fas fa-plus me-1"></i>Add Book</a>
        </div>

        <div class="glass-card mb-4 p-3">
            <form method="get" action="<%= request.getContextPath() %>/ViewBooksServlet" class="row g-2 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="keyword" class="form-control border-start-0" placeholder="Search by title, author, category or ISBN..." value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
                    </div>
                </div>
                <div class="col-md-2 d-grid">
                    <button type="submit" class="btn btn-primary-custom"><i class="fas fa-search me-1"></i>Search</button>
                </div>
                <div class="col-md-2 d-grid">
                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn btn-light border"><i class="fas fa-sync-alt me-1"></i>Reset</a>
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
                            <th>Price</th>
                            <th>Qty</th>
                            <th class="text-end pe-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Book> books = (List<Book>) request.getAttribute("books");
                            if (books != null && !books.isEmpty()) {
                                for (Book book : books) {
                                    boolean isLowStock = book.getQuantity() <= 2;
                        %>
                        <tr class="<%= isLowStock ? "table-warning" : "" %>">
                            <td class="ps-3 fw-bold text-muted">#<%= book.getBookId() %></td>
                            <td class="fw-bold"><%= book.getTitle() %></td>
                            <td><%= book.getAuthor() %></td>
                            <td><span class="badge bg-secondary"><%= book.getCategory() != null ? book.getCategory() : "N/A" %></span></td>
                            <td class="text-muted small"><%= book.getIsbn() != null ? book.getIsbn() : "N/A" %></td>
                            <td class="text-muted small"><%= book.getRackNo() != null ? book.getRackNo() : "N/A" %></td>
                            <td class="fw-bold text-success">₹<%= String.format("%.2f", book.getPrice()) %></td>
                            <td>
                                <% if (isLowStock) { %>
                                    <span class="badge bg-danger rounded-pill"><%= book.getQuantity() %> Left</span>
                                <% } else { %>
                                    <span class="badge bg-success rounded-pill"><%= book.getQuantity() %></span>
                                <% } %>
                            </td>
                            <td class="text-end pe-3">
                                <a href="<%= request.getContextPath() %>/EditBookServlet?id=<%= book.getBookId() %>" class="btn btn-sm btn-outline-primary shadow-sm" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="<%= request.getContextPath() %>/DeleteBookServlet?id=<%= book.getBookId() %>" class="btn btn-sm btn-outline-danger shadow-sm ms-1" title="Delete" onclick="return confirm('Are you sure you want to delete <%= book.getTitle() %>?')">
                                    <i class="fas fa-trash-alt"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fas fa-book-open fa-3x mb-3"></i>
                                    <p class="mb-0 fs-5">No books found in the catalog.</p>
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