<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
            <h3 class="fw-bold"><i class="fas fa-plus-circle me-2 text-primary"></i>Add New Book</h3>
            <a href="<%= request.getContextPath() %>/ViewBooksServlet" class="btn btn-outline-secondary"><i class="fas fa-list me-1"></i>View Books</a>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (successMessage != null) { %>
            <div class="alert alert-success shadow-sm"><i class="fas fa-check-circle me-2"></i><%= successMessage %></div>
        <% } %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <div class="glass-card">
            <form action="<%= request.getContextPath() %>/AddBookServlet" method="post">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Book Title</label>
                        <input type="text" name="title" class="form-control" required placeholder="e.g. Introduction to Algorithms">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Author</label>
                        <input type="text" name="author" class="form-control" required placeholder="e.g. Thomas H. Cormen">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Category</label>
                        <select name="category" id="categorySelect" class="form-select" required onchange="toggleCustomCategory()">
                            <option value="">Select Category</option>
                            <option value="Programming">Programming</option>
                            <option value="Computer Science">Computer Science</option>
                            <option value="Database">Database</option>
                            <option value="Networking">Networking</option>
                            <option value="AI / Machine Learning">AI / Machine Learning</option>
                            <option value="Mathematics">Mathematics</option>
                            <option value="Physics">Physics</option>
                            <option value="Chemistry">Chemistry</option>
                            <option value="Electronics">Electronics</option>
                            <option value="Mechanical">Mechanical</option>
                            <option value="Civil">Civil</option>
                            <option value="English">English</option>
                            <option value="Commerce">Commerce</option>
                            <option value="Finance">Finance</option>
                            <option value="Management">Management</option>
                            <option value="Fiction">Fiction</option>
                            <option value="Non-Fiction">Non-Fiction</option>
                            <option value="Biography">Biography</option>
                            <option value="Reference">Reference</option>
                            <option value="Competitive Exam">Competitive Exam</option>
                            <option value="Other">Other</option>
                        </select>
                        <div id="customCategoryDiv" class="mt-2" style="display: none;">
                            <input type="text" name="customCategory" id="customCategory" class="form-control" placeholder="Enter custom category">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">ISBN (13 Digits)</label>
                        <input type="text" name="isbn" class="form-control" placeholder="e.g. 9780262033848" 
                               pattern="\d{13}" maxlength="13" title="ISBN must be exactly 13 digits" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Rack No</label>
                        <input type="text" name="rack_no" class="form-control" placeholder="e.g. A-12">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Price (₹)</label>
                        <input type="number" step="0.01" min="0" name="price" class="form-control" required placeholder="e.g. 500.00">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Quantity</label>
                        <input type="number" min="1" name="quantity" class="form-control" required placeholder="e.g. 5">
                    </div>
                </div>

                <div class="mt-4 pt-3 border-top d-flex gap-2">
                    <button type="submit" class="btn btn-primary-custom px-4"><i class="fas fa-save me-1"></i> Save Book</button>
                    <a href="<%= request.getContextPath() %>/DashboardServlet" class="btn btn-light border"><i class="fas fa-times me-1"></i> Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function toggleCustomCategory() {
        const select = document.getElementById('categorySelect');
        const customDiv = document.getElementById('customCategoryDiv');
        const customInput = document.getElementById('customCategory');
        
        if (select.value === 'Other') {
            customDiv.style.display = 'block';
            customInput.setAttribute('required', 'required');
        } else {
            customDiv.style.display = 'none';
            customInput.removeAttribute('required');
        }
    }
</script>
<jsp:include page="includes/footer.jsp" />
