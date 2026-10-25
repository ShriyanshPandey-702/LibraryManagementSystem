<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    List<Book> books = (List<Book>) request.getAttribute("books");
    String keyword = request.getParameter("keyword");
    int totalCount = books != null ? books.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Library Catalog</h1>
            <p class="page-subtitle">Inspect, edit, and manage all physical titles in the collection.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/ExportBooksServlet" class="btn-lib-secondary">
                <i class="fas fa-file-csv text-success"></i> Export CSV
            </a>
            <a href="<%= request.getContextPath() %>/AddBookServlet" class="btn-lib-primary">
                <i class="fas fa-plus"></i> Add New Book
            </a>
        </div>
    </header>

    <% if ("1".equals(request.getParameter("deleted"))) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i> Book removed from active catalog successfully.
        </div>
    <% } %>

    <!-- Advanced Search / Filter Panel -->
    <div class="panel mb-4">
        <div class="panel-header py-2 d-flex justify-content-between align-items-center">
            <span class="font-mono small text-muted">// ADVANCED CATALOG SEARCH &amp; FILTERS</span>
            <span class="text-muted small"><%= totalCount %> <%= totalCount == 1 ? "Record" : "Records" %></span>
        </div>
        <div class="panel-body py-3">
            <form method="get" action="<%= request.getContextPath() %>/ViewBooksServlet" class="row g-2 align-items-end">
                <div class="col-md-3">
                    <label class="form-label font-mono small mb-1">// KEYWORD</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-magnifying-glass"></i></span>
                        <input type="text" name="keyword" class="form-control"
                               placeholder="Title, author, ISBN, desc..."
                               value="<%= keyword != null ? keyword : "" %>">
                    </div>
                </div>

                <div class="col-md-2">
                    <label class="form-label font-mono small mb-1">// CATEGORY</label>
                    <select name="category" class="form-select">
                        <option value="ALL">All Categories</option>
                        <%
                            List<String> categories = (List<String>) request.getAttribute("categories");
                            String selectedCat = (String) request.getAttribute("category");
                            if (categories != null) {
                                for (String c : categories) {
                        %>
                        <option value="<%= c %>" <%= c.equalsIgnoreCase(selectedCat) ? "selected" : "" %>><%= c %></option>
                        <%      }
                            }
                        %>
                    </select>
                </div>

                <div class="col-md-2">
                    <label class="form-label font-mono small mb-1">// AVAILABILITY</label>
                    <% String selectedAvail = (String) request.getAttribute("availability"); %>
                    <select name="availability" class="form-select">
                        <option value="all" <%= "all".equalsIgnoreCase(selectedAvail) ? "selected" : "" %>>All Statuses</option>
                        <option value="available" <%= "available".equalsIgnoreCase(selectedAvail) ? "selected" : "" %>>Available (>0)</option>
                        <option value="out" <%= "out".equalsIgnoreCase(selectedAvail) ? "selected" : "" %>>Out of Stock (0)</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <label class="form-label font-mono small mb-1">// SORT BY</label>
                    <% String selectedSort = (String) request.getAttribute("sortBy"); %>
                    <select name="sortBy" class="form-select">
                        <option value="recent" <%= "recent".equalsIgnoreCase(selectedSort) ? "selected" : "" %>>Recently Added</option>
                        <option value="title" <%= "title".equalsIgnoreCase(selectedSort) ? "selected" : "" %>>Title (A–Z)</option>
                        <option value="author" <%= "author".equalsIgnoreCase(selectedSort) ? "selected" : "" %>>Author (A–Z)</option>
                        <option value="rating" <%= "rating".equalsIgnoreCase(selectedSort) ? "selected" : "" %>>Highest Rating</option>
                        <option value="year" <%= "year".equalsIgnoreCase(selectedSort) ? "selected" : "" %>>Publication Year</option>
                    </select>
                </div>

                <div class="col-md-3 d-flex gap-2">
                    <button type="submit" class="btn-lib-primary flex-grow-1">
                        <i class="fas fa-filter me-1"></i> Apply
                    </button>
                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary" title="Clear all filters">
                        <i class="fas fa-rotate-left"></i>
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Catalog Table Panel -->
    <div class="panel">
        <div class="panel-header">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Catalog Inventory</h2>
                <span class="badge-status badge-neutral"><%= totalCount %> <%= totalCount == 1 ? "Book" : "Books" %></span>
            </div>
            <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                <span class="text-muted small">Filtered by "<strong><%= keyword %></strong>"</span>
            <% } %>
        </div>

        <div class="table-responsive">
            <table class="table-lib mb-0">
                <thead>
                    <tr>
                        <th style="width: 50px;">Cover</th>
                        <th>Book Title &amp; Details</th>
                        <th>Author</th>
                        <th>Category</th>
                        <th>ISBN / Shelf</th>
                        <th class="text-center">Rating</th>
                        <th class="text-end">Price</th>
                        <th class="text-center">Stock</th>
                        <th class="text-end" style="width: 130px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (books != null && !books.isEmpty()) {
                            for (Book book : books) {
                                boolean isLowStock = book.getQuantity() > 0 && book.getQuantity() <= 2;
                                boolean outOfStock = book.getQuantity() <= 0;
                    %>
                    <tr>
                        <td>
                            <% if (book.getCoverImage() != null && !book.getCoverImage().trim().isEmpty()) { %>
                                <img src="<%= request.getContextPath() %>/<%= book.getCoverImage() %>" alt="Cover" class="book-cover-thumb" style="width: 40px; height: 52px; object-fit: cover; border-radius: 4px; border: 1px solid var(--color-border);">
                            <% } else { %>
                                <div class="book-cover-placeholder" style="width: 40px; height: 52px; display: flex; align-items: center; justify-content: center; background: var(--color-border); border-radius: 4px; color: var(--color-ink-muted);">
                                    <i class="fas fa-book"></i>
                                </div>
                            <% } %>
                        </td>
                        <td>
                            <strong class="book-title"><%= book.getTitle() %></strong>
                            <div class="text-muted small">
                                ID #<%= book.getBookId() %>
                                <% if (book.getPublisher() != null && !book.getPublisher().trim().isEmpty()) { %>
                                    &bull; <%= book.getPublisher() %>
                                <% } %>
                                <% if (book.getPublicationYear() != null && book.getPublicationYear() > 0) { %>
                                    (<%= book.getPublicationYear() %>)
                                <% } %>
                            </div>
                        </td>
                        <td class="book-author"><%= book.getAuthor() %></td>
                        <td>
                            <span class="badge-status badge-neutral">
                                <%= book.getCategory() != null && !book.getCategory().isEmpty() ? book.getCategory() : "General" %>
                            </span>
                        </td>
                        <td class="text-muted font-monospace small">
                            <div><%= book.getIsbn() != null && !book.getIsbn().isEmpty() ? book.getIsbn() : "—" %></div>
                            <div class="text-subtle"><%= book.getRackNo() != null && !book.getRackNo().isEmpty() ? "Rack: " + book.getRackNo() : "" %></div>
                        </td>
                        <td class="text-center">
                            <% if (book.getReviewCount() > 0) { %>
                                <div class="rating-stars text-accent" title="<%= String.format("%.1f", book.getAverageRating()) %> out of 5 stars">
                                    <i class="fas fa-star text-warning"></i>
                                    <strong><%= String.format("%.1f", book.getAverageRating()) %></strong>
                                    <span class="text-muted small">(<%= book.getReviewCount() %>)</span>
                                </div>
                            <% } else { %>
                                <span class="text-muted small">—</span>
                            <% } %>
                        </td>
                        <td class="text-end fw-semibold">₹<%= String.format("%.2f", book.getPrice()) %></td>
                        <td class="text-center">
                            <% if (outOfStock) { %>
                                <span class="badge-status badge-danger">Out of stock</span>
                            <% } else if (isLowStock) { %>
                                <span class="badge-status badge-warning"><%= book.getQuantity() %> left</span>
                            <% } else { %>
                                <span class="badge-status badge-success"><%= book.getQuantity() %> copies</span>
                            <% } %>
                        </td>
                        <td class="text-end">
                            <div class="d-inline-flex gap-1">
                                <a href="<%= request.getContextPath() %>/AdminBookCopiesServlet?bookId=<%= book.getBookId() %>"
                                   class="btn-icon" title="View physical copies &amp; barcodes" aria-label="Physical copies for #<%= book.getBookId() %>">
                                    <i class="fas fa-barcode"></i>
                                </a>
                                <a href="<%= request.getContextPath() %>/EditBookServlet?id=<%= book.getBookId() %>"
                                   class="btn-icon" title="Edit book details" aria-label="Edit book #<%= book.getBookId() %>">
                                    <i class="fas fa-pen-to-square"></i>
                                </a>
                                <form id="deleteForm-<%= book.getBookId() %>" action="<%= request.getContextPath() %>/DeleteBookServlet" method="post" class="d-inline m-0">
                                    <input type="hidden" name="id" value="<%= book.getBookId() %>">
                                    <button type="button" class="btn-icon text-danger" title="Remove book from active catalog" aria-label="Delete book #<%= book.getBookId() %>"
                                            onclick="confirmDeleteBook(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>')">
                                        <i class="fas fa-trash-can"></i>
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
                        <td colspan="9">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-book-open"></i>
                                </div>
                                <h3 class="empty-state-title">No books found</h3>
                                <p class="empty-state-text">
                                    <%= keyword != null && !keyword.trim().isEmpty() ? "No catalog titles match your search criteria." : "There are currently no active books registered in the catalog." %>
                                </p>
                                <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary btn-sm">
                                        Clear Search
                                    </a>
                                <% } else { %>
                                    <a href="<%= request.getContextPath() %>/AddBookServlet" class="btn-lib-primary btn-sm">
                                        <i class="fas fa-plus me-1"></i> Add First Book
                                    </a>
                                <% } %>
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
function confirmDeleteBook(id, title) {
    sweetConfirm('Remove Book?', 'Are you sure you want to remove "' + title + '" from the active library catalog?', 'Yes, Remove', function() {
        document.getElementById('deleteForm-' + id).submit();
    });
}
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />