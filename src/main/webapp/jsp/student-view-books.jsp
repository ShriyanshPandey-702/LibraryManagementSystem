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
        errorMessage = "Unable to submit book request. You may have reached your 3-book limit or the book is out of stock.";
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

    <!-- Search Panel -->
    <div class="panel mb-4">
        <div class="panel-body py-3">
            <form method="get" action="<%= request.getContextPath() %>/StudentViewBooksServlet" class="row g-2 align-items-center">
                <div class="col-md-8">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-magnifying-glass"></i></span>
                        <input type="text" name="keyword" class="form-control"
                               placeholder="Search catalog by title, author, category, or ISBN..."
                               value="<%= keyword != null ? keyword : "" %>" aria-label="Search catalog">
                    </div>
                </div>
                <div class="col-md-2 d-grid">
                    <button type="submit" class="btn-lib-primary">
                        <i class="fas fa-magnifying-glass me-1"></i> Search
                    </button>
                </div>
                <div class="col-md-2 d-grid">
                    <a href="<%= request.getContextPath() %>/StudentViewBooksServlet" class="btn-lib-secondary text-center">
                        <i class="fas fa-rotate-left me-1"></i> Reset
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
                        <th style="width: 70px;">ID</th>
                        <th>Book Title</th>
                        <th>Author</th>
                        <th>Category</th>
                        <th>ISBN</th>
                        <th>Shelf Rack</th>
                        <th class="text-center">Availability</th>
                        <th class="text-end" style="width: 130px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (books != null && !books.isEmpty()) {
                        for (Book book : books) {
                            boolean inStock = book.getQuantity() > 0;
                %>
                    <tr>
                        <td class="text-muted small">#<%= book.getBookId() %></td>
                        <td>
                            <strong class="text-dark"><%= book.getTitle() %></strong>
                        </td>
                        <td class="text-secondary"><%= book.getAuthor() %></td>
                        <td>
                            <span class="badge-status badge-neutral">
                                <%= book.getCategory() != null && !book.getCategory().isEmpty() ? book.getCategory() : "General" %>
                            </span>
                        </td>
                        <td class="text-muted font-monospace small"><%= book.getIsbn() != null ? book.getIsbn() : "—" %></td>
                        <td class="text-muted small"><%= book.getRackNo() != null ? book.getRackNo() : "—" %></td>
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
                                <button type="button" class="btn-lib-secondary btn-sm disabled" disabled title="All physical copies currently checked out">
                                    Unavailable
                                </button>
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
</script>

<jsp:include page="includes/footer.jsp" />
