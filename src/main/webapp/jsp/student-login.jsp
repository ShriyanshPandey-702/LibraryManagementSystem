<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<div class="auth-split-container">
    <div class="auth-split-card">
        <!-- Visual Artwork Panel (Left Pane) -->
        <div class="auth-split-visual">
            <img src="<%= request.getContextPath() %>/images/student-login-art.png" alt="Student Knowledge Portal" class="auth-split-visual-img">
            <div class="auth-split-visual-overlay"></div>
            
            <div class="auth-split-visual-top">
                <span class="auth-visual-pill">
                    <i class="fas fa-graduation-cap me-1"></i> Student Portal
                </span>
                <span class="auth-visual-pill">
                    <i class="fas fa-book-reader me-1"></i> Academic Hub
                </span>
            </div>

            <div class="auth-split-visual-bottom">
                <div class="auth-visual-author-card">
                    <div class="d-flex align-items-center gap-3">
                        <div class="auth-author-avatar">
                            <i class="fas fa-user-graduate"></i>
                        </div>
                        <div>
                            <div class="auth-author-title">Student Portal</div>
                            <div class="auth-author-sub">Borrow, Reserve & Research</div>
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
                <a href="<%= request.getContextPath() %>/LoginServlet" class="auth-portal-badge" title="Switch to Administrator Sign In">
                    <span>Admin Console</span>
                    <i class="fas fa-arrow-right ms-1"></i>
                </a>
            </div>

            <div class="auth-form-content">
                <h1 class="auth-split-title">Student Sign In</h1>
                <p class="auth-split-subtitle">Access your library account, borrowed books, and requests</p>

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
                        <label for="studentEmail" class="auth-input-label">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                            <input type="email" id="studentEmail" name="email" class="form-control" required placeholder="student@example.com" autocomplete="email">
                        </div>
                    </div>

                    <div class="mb-4">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <label for="studentPassword" class="auth-input-label mb-0">Password</label>
                            <a href="<%= request.getContextPath() %>/ForgotPasswordServlet?userType=student" class="auth-forgot-link">Forgot password?</a>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" id="studentPassword" name="password" class="form-control" required placeholder="Enter student password" autocomplete="current-password">
                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('studentPassword', this)" title="Show/hide password" aria-label="Toggle password visibility">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="auth-submit-btn">
                        <i class="fas fa-right-to-bracket me-2"></i> Sign In to Student Portal
                    </button>
                </form>
            </div>

            <div class="auth-split-footer">
                <p class="mb-2">New student? <a href="<%= request.getContextPath() %>/StudentRegisterServlet" class="fw-bold">Create an account</a></p>
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
