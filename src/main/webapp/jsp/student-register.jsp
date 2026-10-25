<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-container">
    <div class="auth-card wide">
        <div class="auth-header">
            <div class="auth-header-icon">
                <i class="fas fa-user-plus"></i>
            </div>
            <h1 class="auth-title">Student Registration</h1>
            <p class="auth-sub">Register your academic library account to borrow books and submit requests</p>
        </div>

        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger mb-3" role="alert">
                <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/StudentRegisterServlet" method="post">
            <div class="row g-3">
                <div class="col-md-6">
                    <label for="regName" class="form-label">Full Name</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                        <input type="text" id="regName" name="name" class="form-control" required placeholder="e.g. Alex Morgan">
                    </div>
                </div>
                <div class="col-md-6">
                    <label for="regEmail" class="form-label">Email Address</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                        <input type="email" id="regEmail" name="email" class="form-control" required placeholder="student@example.edu" autocomplete="email">
                    </div>
                </div>
                <div class="col-md-6">
                    <label for="regMobile" class="form-label">Mobile Number</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-phone"></i></span>
                        <input type="tel" id="regMobile" name="mobile" class="form-control" required placeholder="10-digit mobile number">
                    </div>
                </div>
                <div class="col-md-6">
                    <label for="regPassword" class="form-label">Account Password</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" id="regPassword" name="password" class="form-control" required placeholder="Minimum 6 characters" autocomplete="new-password">
                    </div>
                </div>
                <div class="col-md-4">
                    <label for="regCourse" class="form-label">Course / Degree</label>
                    <input type="text" id="regCourse" name="course" class="form-control" required placeholder="e.g. B.Tech Computer Science">
                </div>
                <div class="col-md-4">
                    <label for="regYear" class="form-label">Academic Year</label>
                    <select id="regYear" name="year" class="form-select" required>
                        <option value="1st">1st Year</option>
                        <option value="2nd" selected>2nd Year</option>
                        <option value="3rd">3rd Year</option>
                        <option value="4th">4th Year</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label for="regSection" class="form-label">Section</label>
                    <input type="text" id="regSection" name="section" class="form-control" required placeholder="e.g. A">
                </div>
                <div class="col-md-12">
                    <label for="regAddress" class="form-label">Residential Address</label>
                    <textarea id="regAddress" name="address" class="form-control" rows="2" required placeholder="Hostel block or residential mailing address"></textarea>
                </div>
            </div>

            <div class="mt-4">
                <button type="submit" class="btn-lib-primary w-100 py-2">
                    <i class="fas fa-id-card me-1"></i> Register Student Account
                </button>
            </div>
        </form>

        <div class="auth-footer">
            <p class="mb-2">Already registered? <a href="<%= request.getContextPath() %>/StudentLoginServlet" class="fw-semibold">Sign in here</a></p>
            <a href="<%= request.getContextPath() %>/" class="text-decoration-none small text-muted">
                <i class="fas fa-arrow-left me-1"></i> Return to Homepage
            </a>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
