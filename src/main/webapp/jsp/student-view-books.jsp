<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Book" %>
<%
    if (session.getAttribute("studentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/StudentLoginServlet");
        return;
    }
    List<Book> books = (List<Book>) request.getAttribute("books");
    String keyword = (String) request.getAttribute("keyword");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    if ("1".equals(request.getParameter("requested"))) {
        successMessage = "Book reservation request submitted successfully! Awaiting librarian approval.";
    }
    if ("1".equals(request.getParameter("requestError"))) {
        errorMessage = "Unable to submit book request. You may have reached your borrowing quota limit or the book is out of stock.";
    }
    int count = books != null ? books.size() : 0;
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/student-navbar.jsp" />

<main class="page-content py-4">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Library Catalog</h1>
            <p class="page-subtitle">Search the academic collection, verify shelf availability, and submit loan requests.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/StudentIssuedBooksServlet" class="btn-lib-secondary">
                <i class="fas fa-book me-1"></i> My Borrowed Books
            </a>
        </div>
    </header>

    <!-- Alerts -->
    <% if (successMessage != null && !successMessage.isEmpty()) { %>
        <div class="alert alert-success mb-4" role="alert">
            <i class="fas fa-check-circle me-2"></i><%= successMessage %>
        </div>
    <% } %>
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="alert alert-danger mb-4" role="alert">
            <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
        </div>
    <% } %>

    <!-- Advanced Search Panel -->
    <div class="panel mb-4">
        <div class="panel-header py-2 d-flex justify-content-between align-items-center">
            <span class="font-mono small text-muted">// ADVANCED CATALOG EXPLORER &amp; FILTERS</span>
            <span class="text-muted small"><%= count %> <%= count == 1 ? "Title" : "Titles" %> Found</span>
        </div>
        <div class="panel-body py-3">
            <form method="get" action="<%= request.getContextPath() %>/StudentViewBooksServlet" class="row g-2 align-items-end">
                <div class="col-md-3">
                    <label class="form-label font-mono small mb-1">// KEYWORD</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-magnifying-glass"></i></span>
                        <input type="text" name="keyword" class="form-control"
                               placeholder="Title, author, ISBN..."
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
                        <option value="all" <%= "all".equalsIgnoreCase(selectedAvail) ? "selected" : "" %>>All Books</option>
                        <option value="available" <%= "available".equalsIgnoreCase(selectedAvail) ? "selected" : "" %>>In Stock</option>
                        <option value="out" <%= "out".equalsIgnoreCase(selectedAvail) ? "selected" : "" %>>Out of Stock</option>
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
                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary" title="Clear all filters">
                        <i class="fas fa-rotate-left"></i>
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Catalog Inventory Panel -->
    <div class="panel">
        <div class="panel-header">
            <div class="d-flex align-items-center gap-2">
                <h2 class="panel-title">Available Titles</h2>
                <span class="badge-status badge-neutral"><%= count %> <%= count == 1 ? "Book" : "Books" %></span>
            </div>
            <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                <span class="text-muted small">Search query: "<strong><%= keyword %></strong>"</span>
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
                        <th>ISBN / Rack</th>
                        <th class="text-center">Rating</th>
                        <th class="text-center">Availability</th>
                        <th class="text-end" style="width: 150px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (books != null && !books.isEmpty()) {
                        for (Book book : books) {
                            boolean inStock = book.getQuantity() > 0;
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
                            <% if (book.getDescription() != null && !book.getDescription().trim().isEmpty()) { %>
                                <div class="text-muted small text-truncate" style="max-width: 320px;" title="<%= book.getDescription() %>">
                                    <%= book.getDescription() %>
                                </div>
                            <% } %>
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
                        <td class="text-center">
                            <% if (inStock) { %>
                                <span class="badge-status badge-success">
                                    <i class="fas fa-check me-1"></i> <%= book.getQuantity() %> In Stock
                                </span>
                            <% } else { %>
                                <span class="badge-status badge-danger">
                                    Out of Stock
                                </span>
                            <% } %>
                        </td>
                        <td class="text-end">
                            <% if (inStock) { %>
                                <form id="reqForm-<%= book.getBookId() %>" action="<%= request.getContextPath() %>/StudentBookRequestServlet" method="post" class="d-inline m-0">
                                    <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                                    <button type="button" class="btn-lib-primary btn-sm"
                                            onclick="confirmBookRequest(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>')">
                                        <i class="fas fa-hand-holding me-1"></i> Request
                                    </button>
                                </form>
                            <% } else { %>
                                <form id="resForm-<%= book.getBookId() %>" action="<%= request.getContextPath() %>/StudentReservationServlet" method="post" class="d-inline m-0">
                                    <input type="hidden" name="action" value="reserve">
                                    <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                                    <button type="button" class="btn-lib-secondary btn-sm"
                                            onclick="confirmReserveBook(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>')"
                                            title="Join waitlist queue; you will be notified when a copy is returned">
                                        <i class="fas fa-calendar-plus me-1"></i> Reserve
                                    </button>
                                </form>
                            <% } %>
                        </td>
                    </tr>
                <%      }
                    } else {
                %>
                    <tr>
                        <td colspan="8">
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="fas fa-book-open"></i>
                                </div>
                                <h3 class="empty-state-title">No books match your query</h3>
                                <p class="empty-state-text">
                                    <%= keyword != null && !keyword.trim().isEmpty() ? "No books in the catalog match \"" + keyword + "\". Try checking author names, categories, or ISBN." : "The catalog is currently empty." %>
                                </p>
                                <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary btn-sm">
                                        Clear Search Filter
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

</main>

<footer class="site-footer">
    <div class="container-xl d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span>&copy; Library Management System &bull; Academic Operations Platform</span>
        <span class="text-muted small">Catalog Explorer</span>
    </div>
</footer>

<script>
function confirmBookRequest(id, title) {
    sweetConfirm('Submit Loan Request?', 'Request a reservation copy for "' + title + '"? The librarian will review and authorize the loan.', 'Yes, Submit Request', function() {
        document.getElementById('reqForm-' + id).submit();
    });
}

function confirmReserveBook(id, title) {
    sweetConfirm('Reserve Unavailable Book?', 'All copies of "' + title + '" are currently checked out. Do you want to join the waiting list queue? You will receive a notification as soon as a copy is returned.', 'Yes, Place Reservation', function() {
        document.getElementById('resForm-' + id).submit();
    });
}
</script>

<jsp:include page="includes/footer.jsp" />
