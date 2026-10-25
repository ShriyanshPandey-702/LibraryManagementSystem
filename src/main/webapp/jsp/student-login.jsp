<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <div class="auth-header-icon">
                <i class="fas fa-user-graduate"></i>
            </div>
            <h1 class="auth-title">Student Sign In</h1>
            <p class="auth-sub">Access your library account, borrowed books, and requests</p>
        </div>

        <% String successMessage = (String) request.getAttribute("successMessage"); %>
        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success mb-3" role="alert">
                <i class="fas fa-check-circle me-2"></i><%= successMessage %>
            </div>
        <% } %>

        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger mb-3" role="alert">
                <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/StudentLoginServlet" method="post">
            <div class="mb-3">
                <label for="studentEmail" class="form-label">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                    <input type="email" id="studentEmail" name="email" class="form-control" required placeholder="student@example.com" autocomplete="email">
                </div>
            </div>

            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="studentPassword" class="form-label mb-0">Password</label>
                    <a href="<%= request.getContextPath() %>/ForgotPasswordServlet?userType=student" class="small text-decoration-none">Forgot password?</a>
                </div>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password" id="studentPassword" name="password" class="form-control" required placeholder="Enter student password" autocomplete="current-password">
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('studentPassword', this)" title="Show/hide password" aria-label="Toggle password visibility">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-lib-primary w-100 py-2">
                <i class="fas fa-right-to-bracket me-1"></i> Sign In to Student Portal
            </button>
        </form>

        <div class="auth-footer">
            <p class="mb-2">New student? <a href="<%= request.getContextPath() %>/StudentRegisterServlet" class="fw-semibold">Create an account</a></p>
            <a href="<%= request.getContextPath() %>/" class="text-decoration-none small text-muted">
                <i class="fas fa-arrow-left me-1"></i> Return to Homepage
            </a>
        </div>
    </div>
</div>

<script>
function togglePassword(inputId, btn) {
    const input = document.getElementById(inputId);
    const icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}
</script>

<jsp:include page="includes/footer.jsp" />
