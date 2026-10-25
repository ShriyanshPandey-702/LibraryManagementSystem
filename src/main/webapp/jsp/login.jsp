<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-split-container">
    <div class="auth-split-card">
        <!-- Visual Artwork Panel (Left Pane) -->
        <div class="auth-split-visual">
            <img src="<%= request.getContextPath() %>/images/admin-login-art.png" alt="Library Administrator Workspace" class="auth-split-visual-img">
            <div class="auth-split-visual-overlay"></div>
            
            <div class="auth-split-visual-top">
                <span class="auth-visual-pill">
                    <i class="fas fa-shield-halved me-1"></i> Admin Console
                </span>
                <span class="auth-visual-pill">
                    <i class="fas fa-book-bookmark me-1"></i> Libris LMS
                </span>
            </div>

            <div class="auth-split-visual-bottom">
                <div class="auth-visual-author-card">
                    <div class="d-flex align-items-center gap-3">
                        <div class="auth-author-avatar">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <div>
                            <div class="auth-author-title">Libris Admin Console</div>
                            <div class="auth-author-sub">Catalog, Circulation & Control</div>
                        </div>
                    </div>
                    <div class="auth-visual-status">
                        <span class="status-dot"></span> Active
                    </div>
                </div>
            </div>
        </div>

        <!-- Form Panel (Right Pane) -->
        <div class="auth-split-form">
            <div class="auth-split-header">
                <a href="<%= request.getContextPath() %>/" class="auth-split-brand">
                    <i class="fas fa-book-journal-whills me-2" style="color: var(--color-primary);"></i>libris<span style="color: var(--color-accent);">.</span>
                </a>
                <a href="<%= request.getContextPath() %>/StudentLoginServlet" class="auth-portal-badge" title="Switch to Student Sign In">
                    <span>Student Portal</span>
                    <i class="fas fa-arrow-right ms-1"></i>
                </a>
            </div>

            <div class="auth-form-content">
                <h1 class="auth-split-title">Administrator Sign In</h1>
                <p class="auth-split-subtitle">Access catalog controls, circulation records, and configuration</p>

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
                        <label for="adminUsername" class="auth-input-label">Username</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-user"></i></span>
                            <input type="text" id="adminUsername" name="username" class="form-control" required placeholder="admin" autocomplete="username">
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label for="adminPassword" class="auth-input-label mb-0">Password</label>
                            <a href="<%= request.getContextPath() %>/ForgotPasswordServlet?userType=admin" class="auth-forgot-link">Forgot password?</a>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" id="adminPassword" name="password" class="form-control" required placeholder="Enter admin password" autocomplete="current-password">
                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('adminPassword', this)" title="Show/hide password" aria-label="Toggle password visibility">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="auth-submit-btn">
                        <i class="fas fa-right-to-bracket me-2"></i> Sign In to Console
                    </button>
                </form>
            </div>

            <div class="auth-split-footer">
                <a href="<%= request.getContextPath() %>/" class="auth-return-link">
                    <i class="fas fa-arrow-left me-1"></i> Return to Homepage
                </a>
            </div>
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
