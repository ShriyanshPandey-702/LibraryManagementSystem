<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="container d-flex align-items-center justify-content-center min-vh-100 py-5">
    <div class="glass-card" style="max-width: 600px; width: 100%;">
        <div class="text-center mb-4">
            <i class="fas fa-user-plus fa-3x text-info mb-3"></i>
            <h3 class="fw-bold">Student Registration</h3>
            <p class="text-muted">Join our digital library platform.</p>
        </div>

        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (errorMessage != null) { %>
            <div class="alert alert-danger shadow-sm"><i class="fas fa-exclamation-circle me-2"></i><%= errorMessage %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/StudentRegisterServlet" method="post">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold">Full Name</label>
                    <input type="text" class="form-control" name="name" required placeholder="John Doe">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Email Address</label>
                    <input type="email" class="form-control" name="email" required placeholder="john@student.com">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Mobile</label>
                    <input type="text" class="form-control" name="mobile" required placeholder="1234567890">
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Password</label>
                    <input type="password" class="form-control" name="password" required placeholder="********">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Course</label>
                    <input type="text" class="form-control" name="course" required placeholder="e.g. B.Tech">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Year</label>
                    <input type="text" class="form-control" name="year" required placeholder="e.g. 2nd">
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold">Section</label>
                    <input type="text" class="form-control" name="section" required placeholder="e.g. A">
                </div>
                <div class="col-md-12">
                    <label class="form-label fw-bold">Address</label>
                    <textarea class="form-control" name="address" rows="2" required placeholder="Your full address"></textarea>
                </div>
            </div>

            <button type="submit" class="btn btn-primary-custom w-100 mt-4 py-2">Create Account</button>
        </form>

        <div class="text-center mt-4">
            <p class="mb-0">Already registered? <a href="<%= request.getContextPath() %>/jsp/student-login.jsp" class="fw-bold text-info text-decoration-none">Login Here</a></p>
            <a href="<%= request.getContextPath() %>/" class="text-muted text-decoration-none small d-block mt-2"><i class="fas fa-arrow-left me-1"></i> Back to Home</a>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
