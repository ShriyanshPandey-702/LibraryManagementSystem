<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginServlet");
        return;
    }
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage   = (String) request.getAttribute("errorMessage");
%>
<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/admin-navbar.jsp" />

<div class="page-content">

    <!-- Page Header -->
    <header class="page-header">
        <div>
            <h1 class="page-title">Add New Book</h1>
            <p class="page-subtitle">Register a new physical title into the active library catalog.</p>
        </div>
        <div class="page-header-actions">
            <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary">
                <i class="fas fa-arrow-left me-1"></i> Back to Catalog
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

    <!-- Add Book Form Panel -->
    <div class="panel" style="max-width: 900px;">
        <div class="panel-header d-flex justify-content-between align-items-center">
            <h2 class="panel-title">Book Metadata &amp; Inventory Details</h2>
            <span class="text-muted small">Fields with <span class="text-danger">*</span> are mandatory</span>
        </div>
        <div class="panel-body">
            <form action="<%= request.getContextPath() %>/AddBookServlet" method="post" enctype="multipart/form-data">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label for="bookTitle" class="form-label font-mono small">// TITLE <span class="text-danger">*</span></label>
                        <input type="text" id="bookTitle" name="title" class="form-control" required
                               placeholder="e.g. Introduction to Algorithms">
                    </div>
                    <div class="col-md-6">
                        <label for="bookAuthor" class="form-label font-mono small">// AUTHOR <span class="text-danger">*</span></label>
                        <input type="text" id="bookAuthor" name="author" class="form-control" required
                               placeholder="e.g. Thomas H. Cormen, Charles E. Leiserson">
                    </div>

                    <div class="col-md-4">
                        <label for="bookQty" class="form-label font-mono small">// INITIAL COPIES <span class="text-danger">*</span></label>
                        <input type="number" id="bookQty" min="1" name="quantity" class="form-control"
                               required value="1" placeholder="e.g. 5">
                        <div class="form-text small">Physical copies &amp; barcodes will be automatically generated.</div>
                    </div>
                    <div class="col-md-4">
                        <label for="bookPrice" class="form-label font-mono small">// UNIT PRICE (₹) <span class="text-muted">(Optional)</span></label>
                        <div class="input-group">
                            <span class="input-group-text">₹</span>
                            <input type="number" id="bookPrice" step="0.01" min="0" name="price" class="form-control"
                                   placeholder="0.00">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label for="categorySelect" class="form-label font-mono small">// CATEGORY / GENRE <span class="text-muted">(Optional)</span></label>
                        <select name="category" id="categorySelect" class="form-select" onchange="toggleCustomCategory()">
                            <option value="">-- Optional Category --</option>
                            <option>Programming</option>
                            <option>Computer Science</option>
                            <option>Database</option>
                            <option>Networking</option>
                            <option>AI / Machine Learning</option>
                            <option>Mathematics</option>
                            <option>Physics</option>
                            <option>Chemistry</option>
                            <option>Electronics</option>
                            <option>Mechanical</option>
                            <option>Civil</option>
                            <option>English</option>
                            <option>Commerce</option>
                            <option>Finance</option>
                            <option>Management</option>
                            <option>Fiction</option>
                            <option>Non-Fiction</option>
                            <option>Biography</option>
                            <option>Reference</option>
                            <option>Competitive Exam</option>
                            <option value="Other">Other (specify)</option>
                        </select>
                        <div id="customCategoryDiv" class="mt-2" style="display:none;">
                            <input type="text" name="customCategory" id="customCategory"
                                   class="form-control" placeholder="Enter custom category name">
                        </div>
                    </div>

                    <div class="col-md-4">
                        <label for="bookIsbn" class="form-label font-mono small">// ISBN <span class="text-muted">(Optional)</span></label>
                        <input type="text" id="bookIsbn" name="isbn" class="form-control"
                               placeholder="e.g. 9780262033848" maxlength="20">
                    </div>
                    <div class="col-md-4">
                        <label for="bookPublisher" class="form-label font-mono small">// PUBLISHER <span class="text-muted">(Optional)</span></label>
                        <input type="text" id="bookPublisher" name="publisher" class="form-control"
                               placeholder="e.g. MIT Press">
                    </div>
                    <div class="col-md-4">
                        <label for="bookYear" class="form-label font-mono small">// PUBLICATION YEAR <span class="text-muted">(Optional)</span></label>
                        <input type="number" id="bookYear" name="publication_year" class="form-control"
                               min="1000" max="2099" placeholder="e.g. 2022">
                    </div>

                    <div class="col-md-6">
                        <label for="bookRack" class="form-label font-mono small">// SHELF RACK LOCATION <span class="text-muted">(Optional)</span></label>
                        <input type="text" id="bookRack" name="rack_no" class="form-control" placeholder="e.g. CS-04-A">
                    </div>
                    <div class="col-md-6">
                        <label for="coverFile" class="form-label font-mono small">// BOOK COVER IMAGE <span class="text-muted">(Optional, JPG/PNG/WebP, max 5MB)</span></label>
                        <input type="file" id="coverFile" name="cover_file" class="form-control" accept="image/jpeg,image/png,image/webp">
                    </div>

                    <div class="col-12">
                        <label for="bookDesc" class="form-label font-mono small">// DESCRIPTION / SYNOPSIS <span class="text-muted">(Optional)</span></label>
                        <textarea id="bookDesc" name="description" rows="3" class="form-control"
                                  placeholder="Brief summary, preface, or bibliographic notes for students..."></textarea>
                    </div>
                </div>

                <div class="d-flex gap-2 mt-4 pt-3 border-top">
                    <button type="submit" class="btn-lib-primary px-4">
                        <i class="fas fa-check me-1"></i> Save to Catalog
                    </button>
                    <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn-lib-secondary">
                        Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

</div><!-- /.page-content -->

<script>
function toggleCustomCategory() {
    const sel = document.getElementById('categorySelect');
    const div = document.getElementById('customCategoryDiv');
    const inp = document.getElementById('customCategory');
    if (sel.value === 'Other') {
        div.style.display = 'block';
        inp.setAttribute('required', 'required');
    } else {
        div.style.display = 'none';
        inp.removeAttribute('required');
    }
}
</script>

<jsp:include page="includes/admin-footer.jsp" />
<jsp:include page="includes/footer.jsp" />
