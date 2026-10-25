<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Book" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    Book book = (Book) request.getAttribute("book");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <header class="page-header">
        <div>
            <h1 class="page-title">Edit Book</h1>
            <% if (book != null) { %>
                <p class="page-subtitle">Modifying metadata for: <strong><%= book.getTitle() %></strong> (ID #<%= book.getBookId() %>)</p>
            <% } else { %>
                <p class="page-subtitle">Update catalog record details.</p>
            <% } %>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary">
                <i class="fas fa-arrow-left me-1"></i> Back to Catalog
            </a>
        </div>
    </header>

    <% if (book == null) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i> Book details could not be retrieved from the database.
        </div>
    <% } else { %>

    <div class="panel" style="max-width: 860px;">
        <div class="panel-header">
            <h2 class="panel-title">Update Catalog Information</h2>
        </div>
        <div class="panel-body">
            <form action="<%= request.getContextPath() %>/UpdateBookServlet" method="post">
                <input type="hidden" name="id" value="<%= book.getBookId() %>">

                <div class="row g-3">
                    <div class="col-md-6">
                        <label for="editTitle" class="form-label">Book Title <span class="text-danger">*</span></label>
                        <input type="text" id="editTitle" name="title" class="form-control"
                               value="<%= book.getTitle() %>" required>
                    </div>
                    <div class="col-md-6">
                        <label for="editAuthor" class="form-label">Author <span class="text-danger">*</span></label>
                        <input type="text" id="editAuthor" name="author" class="form-control"
                               value="<%= book.getAuthor() %>" required>
                    </div>
                    <div class="col-md-4">
                        <label for="editCategory" class="form-label">Category <span class="text-danger">*</span></label>
                        <select id="editCategory" name="category" class="form-select" required>
                            <option value="">-- Select Category --</option>
                            <%
                                String[] cats = {"Programming","Computer Science","Database","Networking",
                                    "AI / Machine Learning","Mathematics","Physics","Chemistry",
                                    "Electronics","Mechanical","Civil","English","Commerce","Finance",
                                    "Management","Fiction","Non-Fiction","Biography","Reference","Competitive Exam"};
                                for (String cat : cats) {
                            %>
                            <option value="<%= cat %>" <%= cat.equals(book.getCategory()) ? "selected" : "" %>><%= cat %></option>
                            <% } %>
                            <% if (book.getCategory() != null && !java.util.Arrays.asList(cats).contains(book.getCategory())) { %>
                            <option value="<%= book.getCategory() %>" selected><%= book.getCategory() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label for="editIsbn" class="form-label">ISBN</label>
                        <input type="text" id="editIsbn" name="isbn" class="form-control"
                               value="<%= book.getIsbn() != null ? book.getIsbn() : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label for="editRack" class="form-label">Shelf Rack Location</label>
                        <input type="text" id="editRack" name="rack_no" class="form-control"
                               value="<%= book.getRackNo() != null ? book.getRackNo() : "" %>">
                    </div>
                    <div class="col-md-6">
                        <label for="editPrice" class="form-label">Price (₹) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text">₹</span>
                            <input type="number" id="editPrice" step="0.01" min="0" name="price" class="form-control"
                                   value="<%= book.getPrice() %>" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label for="editQuantity" class="form-label">Available Physical Copies <span class="text-danger">*</span></label>
                        <input type="number" id="editQuantity" min="0" name="quantity" class="form-control"
                               value="<%= book.getQuantity() %>" required>
                    </div>
                </div>

                <div class="d-flex gap-2 mt-4 pt-3 border-top">
                    <button type="submit" class="btn-lib-primary px-4">
                        <i class="fas fa-check me-1"></i> Update Book Details
                    </button>
                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <% } %>

</div><!-- /.page-content -->

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
