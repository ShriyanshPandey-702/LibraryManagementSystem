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

    <div class="panel" style="max-width: 900px;">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <h2 class="panel-title">Update Catalog Information</h2>
            <span class="text-muted small">Fields with <span class="text-danger">*</span> are mandatory</span>
        </div>
        <div class="panel-body">
            <form action="<%= request.getContextPath() %>/UpdateBookServlet" method="post" enctype="multipart/form-data">
                <input type="hidden" name="id" value="<%= book.getBookId() %>">

                <div class="row g-3">
                    <div class="col-md-6">
                        <label for="editTitle" class="form-label font-mono small">// TITLE <span class="text-danger">*</span></label>
                        <input type="text" id="editTitle" name="title" class="form-control"
                               value="<%= book.getTitle() %>" required>
                    </div>
                    <div class="col-md-6">
                        <label for="editAuthor" class="form-label font-mono small">// AUTHOR <span class="text-danger">*</span></label>
                        <input type="text" id="editAuthor" name="author" class="form-control"
                               value="<%= book.getAuthor() %>" required>
                    </div>

                    <div class="col-md-4">
                        <label for="editQuantity" class="form-label font-mono small">// PHYSICAL COPIES <span class="text-danger">*</span></label>
                        <input type="number" id="editQuantity" min="0" name="quantity" class="form-control"
                               value="<%= book.getQuantity() %>" required>
                    </div>
                    <div class="col-md-4">
                        <label for="editPrice" class="form-label font-mono small">// UNIT PRICE (₹) <span class="text-muted">(Optional)</span></label>
                        <div class="input-group">
                            <span class="input-group-text">₹</span>
                            <input type="number" id="editPrice" step="0.01" min="0" name="price" class="form-control"
                                   value="<%= book.getPrice() %>">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label for="editCategory" class="form-label font-mono small">// CATEGORY / GENRE <span class="text-muted">(Optional)</span></label>
                        <select id="editCategory" name="category" class="form-select">
                            <option value="">-- Optional Category --</option>
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
                        <label for="editIsbn" class="form-label font-mono small">// ISBN <span class="text-muted">(Optional)</span></label>
                        <input type="text" id="editIsbn" name="isbn" class="form-control"
                               value="<%= book.getIsbn() != null ? book.getIsbn() : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label for="editPublisher" class="form-label font-mono small">// PUBLISHER <span class="text-muted">(Optional)</span></label>
                        <input type="text" id="editPublisher" name="publisher" class="form-control"
                               value="<%= book.getPublisher() != null ? book.getPublisher() : "" %>">
                    </div>
                    <div class="col-md-4">
                        <label for="editYear" class="form-label font-mono small">// PUBLICATION YEAR <span class="text-muted">(Optional)</span></label>
                        <input type="number" id="editYear" name="publication_year" class="form-control"
                               min="1000" max="2099"
                               value="<%= book.getPublicationYear() != null && book.getPublicationYear() > 0 ? book.getPublicationYear() : "" %>">
                    </div>

                    <div class="col-md-6">
                        <label for="editRack" class="form-label font-mono small">// SHELF RACK LOCATION <span class="text-muted">(Optional)</span></label>
                        <input type="text" id="editRack" name="rack_no" class="form-control"
                               value="<%= book.getRackNo() != null ? book.getRackNo() : "" %>">
                    </div>
                    <div class="col-md-6">
                        <label for="editCover" class="form-label font-mono small">// COVER IMAGE <span class="text-muted">(Optional, upload new to replace)</span></label>
                        <div class="d-flex align-items-center gap-3">
                            <% if (book.getCoverImage() != null && !book.getCoverImage().trim().isEmpty()) { %>
                                <img src="<%= request.getContextPath() %>/<%= book.getCoverImage() %>" alt="Cover" class="book-cover-thumb" style="width: 48px; height: 60px; object-fit: cover; border: 1px solid var(--color-border); border-radius: 4px;">
                            <% } %>
                            <input type="file" id="editCover" name="cover_file" class="form-control" accept="image/jpeg,image/png,image/webp">
                        </div>
                    </div>

                    <div class="col-12">
                        <label for="editDesc" class="form-label font-mono small">// DESCRIPTION / SYNOPSIS <span class="text-muted">(Optional)</span></label>
                        <textarea id="editDesc" name="description" rows="3" class="form-control"
                                  placeholder="Brief summary or description..."><%= book.getDescription() != null ? book.getDescription() : "" %></textarea>
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
