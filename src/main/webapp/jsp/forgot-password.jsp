<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="includes/header.jsp" />

<%
    String userType = (String) request.getAttribute("userType");
    if (userType == null || userType.trim().isEmpty()) {
        userType = request.getParameter("userType");
    }
    if (userType == null || (!"student".equalsIgnoreCase(userType) && !"admin".equalsIgnoreCase(userType))) {
        userType = "admin";
    }
    String errorMessage = (String) request.getAttribute("errorMessage");
    boolean isStudentUser = "student".equalsIgnoreCase(userType);
%>

<div class="auth-split-container">
    <div class="auth-split-card">
        <!-- Visual Artwork Panel (Left Pane) -->
        <div class="auth-split-visual">
            <img id="forgotArtImg" src="<%= request.getContextPath() %>/images/<%= isStudentUser ? "student-login-art.png" : "admin-login-art.png" %>" alt="Account Security" class="auth-split-visual-img">
            <div class="auth-split-visual-overlay"></div>
            
            <div class="auth-split-visual-top">
                <span class="auth-visual-pill" id="forgotArtBadge">
                    <i class="fas <%= isStudentUser ? "fa-graduation-cap" : "fa-shield-halved" %> me-1"></i> <%= isStudentUser ? "Student Portal" : "Admin Console" %>
                </span>
                <span class="auth-visual-pill">
                    <i class="fas fa-key me-1"></i> Password Reset
                </span>
            </div>

            <div class="auth-split-visual-bottom">
                <div class="auth-visual-author-card">
                    <div class="d-flex align-items-center gap-3">
                        <div class="auth-author-avatar">
                            <i class="fas fa-lock"></i>
                        </div>
                        <div>
                            <div class="auth-author-title">Account Security</div>
                            <div class="auth-author-sub">Credential Recovery Protocol</div>
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
                <a href="<%= request.getContextPath() %>/<%= isStudentUser ? "StudentLoginServlet" : "LoginServlet" %>" class="auth-portal-badge" id="backToLoginBadge" title="Return to Login">
                    <span>Back to <%= isStudentUser ? "Student" : "Admin" %> Login</span>
                    <i class="fas fa-arrow-right ms-1"></i>
                </a>
            </div>

            <div class="auth-form-content">
                <h1 class="auth-split-title">Reset Password</h1>
                <p class="auth-split-subtitle">Enter your account identifier to configure a new password</p>

                <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div class="alert alert-danger mb-3" role="alert">
                        <i class="fas fa-circle-exclamation me-2"></i><%= errorMessage %>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/ForgotPasswordServlet" method="post" onsubmit="return validateResetForm();">
                    <div class="mb-3">
                        <label for="userTypeSelect" class="auth-input-label">Account Role</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-users"></i></span>
                            <select class="form-select" name="userType" id="userTypeSelect" required onchange="updateIdentifierLabel()">
                                <option value="admin" <%= "admin".equals(userType) ? "selected" : "" %>>Administrator</option>
                                <option value="student" <%= "student".equals(userType) ? "selected" : "" %>>Student Member</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="identifierInput" class="auth-input-label" id="identifierLabel"><%= "admin".equals(userType) ? "Admin Username" : "Student Email Address" %></label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-id-card"></i></span>
                            <input type="text" id="identifierInput" class="form-control" name="identifier" required placeholder="<%= "admin".equals(userType) ? "e.g. admin" : "e.g. student@example.edu" %>">
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="resetNewPass" class="auth-input-label">New Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-lock"></i></span>
                            <input type="password" id="resetNewPass" class="form-control" name="newPassword" required placeholder="Minimum 6 characters" autocomplete="new-password">
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="resetConfirmPass" class="auth-input-label">Confirm New Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-shield-halved"></i></span>
                            <input type="password" id="resetConfirmPass" class="form-control" name="confirmPassword" required placeholder="Re-type new password" autocomplete="new-password">
                        </div>
                    </div>

                    <button type="submit" class="auth-submit-btn">
                        <i class="fas fa-key me-2"></i> Update Account Password
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
function updateIdentifierLabel() {
    var select = document.getElementById("userTypeSelect");
    var label = document.getElementById("identifierLabel");
    var input = document.getElementById("identifierInput");
    var img = document.getElementById("forgotArtImg");
    var badge = document.getElementById("forgotArtBadge");
    var backBadge = document.getElementById("backToLoginBadge");
    var contextPath = "<%= request.getContextPath() %>";

    if (select.value === "admin") {
        label.innerText = "Admin Username";
        input.placeholder = "e.g. admin";
        if (img) img.src = contextPath + "/images/admin-login-art.png";
        if (badge) badge.innerHTML = '<i class="fas fa-shield-halved me-1"></i> Admin Console';
        if (backBadge) {
            backBadge.href = contextPath + "/LoginServlet";
            backBadge.innerHTML = '<span>Back to Admin Login</span> <i class="fas fa-arrow-right ms-1"></i>';
        }
    } else {
        label.innerText = "Student Email Address";
        input.placeholder = "e.g. student@example.edu";
        if (img) img.src = contextPath + "/images/student-login-art.png";
        if (badge) badge.innerHTML = '<i class="fas fa-graduation-cap me-1"></i> Student Portal';
        if (backBadge) {
            backBadge.href = contextPath + "/StudentLoginServlet";
            backBadge.innerHTML = '<span>Back to Student Login</span> <i class="fas fa-arrow-right ms-1"></i>';
        }
    }
}

function validateResetForm() {
    var p1 = document.getElementById("resetNewPass").value;
    var p2 = document.getElementById("resetConfirmPass").value;
    if (p1.length < 6) {
        sweetConfirm('Weak Password', 'Password must be at least 6 characters long.', 'OK', function() {});
        return false;
    }
    if (p1 !== p2) {
        sweetConfirm('Passwords Mismatch', 'New password and confirm password do not match.', 'OK', function() {});
        return false;
    }
    return true;
}
</script>

<jsp:include page="includes/footer.jsp" />
