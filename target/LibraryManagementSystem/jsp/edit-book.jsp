<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
            <h3 class="fw-bold"><i class="fas fa-edit me-2 text-primary"></i>Edit Book</h3>
            <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn btn-outline-secondary"><i class="fas fa-list me-1"></i>View Books</a>
        </div>

        <%
            Book book = (Book) request.getAttribute("book");
            if (book == null) {
        %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i>Book details not found.</div>
            <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn btn-secondary mt-2">Back to Catalog</a>
        <%
            } else {
        %>

        <div class="glass-card">
            <form action="<%= request.getContextPath() %>/UpdateBookServlet" method="post">
                <input type="hidden" name="id" value="<%= book.getBookId() %>">

                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Book Title</label>
                        <input type="text" name="title" class="form-control" value="<%= book.getTitle() %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Author</label>
                        <input type="text" name="author" class="form-control" value="<%= book.getAuthor() %>" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Category</label>
                        <select name="category" class="form-select" required>
                            <option value="">Select Category</option>
                            <option value="Computer Science" <%= "Computer Science".equals(book.getCategory()) ? "selected" : "" %>>Computer Science</option>
                            <option value="Mathematics" <%= "Mathematics".equals(book.getCategory()) ? "selected" : "" %>>Mathematics</option>
                            <option value="Physics" <%= "Physics".equals(book.getCategory()) ? "selected" : "" %>>Physics</option>
                            <option value="Fiction" <%= "Fiction".equals(book.getCategory()) ? "selected" : "" %>>Fiction</option>
                            <option value="Non-Fiction" <%= "Non-Fiction".equals(book.getCategory()) ? "selected" : "" %>>Non-Fiction</option>
                            <option value="Reference" <%= "Reference".equals(book.getCategory()) ? "selected" : "" %>>Reference</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">ISBN</label>
                        <input type="text" name="isbn" class="form-control" value="<%= book.getIsbn() != null ? book.getIsbn() : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Rack No</label>
                        <input type="text" name="rack_no" class="form-control" value="<%= book.getRackNo() != null ? book.getRackNo() : "" %>">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Price (₹)</label>
                        <input type="number" step="0.01" min="0" name="price" class="form-control" value="<%= book.getPrice() %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Quantity</label>
                        <input type="number" min="1" name="quantity" class="form-control" value="<%= book.getQuantity() %>" required>
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top d-flex gap-2">
                    <button type="submit" class="btn btn-primary-custom px-4"><i class="fas fa-save me-1"></i> Update Book</button>
                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn btn-light border"><i class="fas fa-times me-1"></i> Cancel</a>
                </div>
            </form>
        </div>

        <%
            }
        %>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
