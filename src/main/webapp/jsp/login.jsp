<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <div class="auth-header-icon">
                <i class="fas fa-shield-halved"></i>
            </div>
            <h1 class="auth-title">Administrator Sign In</h1>
            <p class="auth-sub">Access catalog controls, circulation records, and configuration</p>
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

        <form action="<%= request.getContextPath() %>/LoginServlet" method="post">
            <div class="mb-3">
                <label for="adminUsername" class="form-label">Username</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                    <input type="text" id="adminUsername" name="username" class="form-control" required placeholder="admin" autocomplete="username">
                </div>
            </div>

            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label for="adminPassword" class="form-label mb-0">Password</label>
                    <a href="<%= request.getContextPath() %>/ForgotPasswordServlet?userType=admin" class="small text-decoration-none">Forgot password?</a>
                </div>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password" id="adminPassword" name="password" class="form-control" required placeholder="Enter admin password" autocomplete="current-password">
                    <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('adminPassword', this)" title="Show/hide password" aria-label="Toggle password visibility">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-lib-primary w-100 py-2">
                <i class="fas fa-right-to-bracket me-1"></i> Sign In to Console
            </button>
        </form>

        <div class="auth-footer">
            <a href="<%= request.getContextPath() %>/" class="text-decoration-none">
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
